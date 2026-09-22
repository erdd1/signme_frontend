import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/network/dio_client.dart';
import 'package:signme/core/storage/secure_storage.dart';

/// Stockage en mémoire — évite tout appel réel à flutter_secure_storage
/// (canal de plateforme indisponible dans un test unitaire pur).
class _FakeSecureStorage extends SecureStorage {
  String? accessToken = 'expired_token';
  String? refreshToken = 'valid_refresh';
  bool sessionCleared = false;

  @override
  Future<String?> getAccessToken() async => accessToken;

  @override
  Future<void> saveAccessToken(String token) async => accessToken = token;

  @override
  Future<String?> getRefreshToken() async => refreshToken;

  @override
  Future<void> saveRefreshToken(String token) async => refreshToken = token;

  @override
  Future<void> clearSession() async {
    sessionCleared = true;
    accessToken = null;
    refreshToken = null;
  }
}

/// Simule le serveur : la route `/auth/refresh` reste bloquée tant que
/// [unblockRefresh] n'a pas été appelé, pour garantir que plusieurs 401
/// concurrents arrivent bien PENDANT qu'un refresh est déjà en vol. Les
/// autres routes renvoient 401 sauf si le Bearer envoyé est "fresh_token".
class _FakeAdapter implements HttpClientAdapter {
  int refreshCallCount = 0;
  final _refreshGate = Completer<void>();

  void unblockRefresh() {
    if (!_refreshGate.isCompleted) _refreshGate.complete();
  }

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final headers = {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    };

    if (options.path.contains('/auth/refresh')) {
      refreshCallCount++;
      await _refreshGate.future;
      return ResponseBody.fromString(
        '{"success": true, "data": {"access_token": "fresh_token"}}',
        200,
        headers: headers,
      );
    }

    final auth = options.headers['Authorization'] as String?;
    if (auth == 'Bearer fresh_token') {
      return ResponseBody.fromString('{"ok": true}', 200, headers: headers);
    }
    return ResponseBody.fromString(
      '{"message": "Unauthenticated"}',
      401,
      headers: headers,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'plusieurs 401 concurrents (widgets chargés en parallèle avec un token '
    'expiré) partagent UN SEUL refresh et sont tous retentés avec succès',
    () async {
      final storage = _FakeSecureStorage();
      final adapter = _FakeAdapter();
      var sessionExpiredCalls = 0;
      final dio = buildDioClient(
        storage,
        onSessionExpired: () async {
          sessionExpiredCalls++;
        },
      )..httpClientAdapter = adapter;

      // 3 requêtes "widgets" tirées en parallèle, comme au chargement du Home.
      final requests = Future.wait([
        dio.get<Map<String, dynamic>>('/dashboard/a'),
        dio.get<Map<String, dynamic>>('/dashboard/b'),
        dio.get<Map<String, dynamic>>('/dashboard/c'),
      ]);

      // Laisse le temps aux 3 requêtes de recevoir leur 401 et de déclencher
      // (ou tenter de déclencher) le refresh avant de le débloquer.
      await Future.delayed(const Duration(milliseconds: 50));
      adapter.unblockRefresh();

      final responses = await requests;

      expect(
        adapter.refreshCallCount,
        1,
        reason: 'un seul appel réseau de refresh doit partir, même si 3 '
            'requêtes reçoivent un 401 en même temps',
      );
      for (final r in responses) {
        expect(r.statusCode, 200);
        expect(r.data?['ok'], isTrue);
      }
      expect(storage.accessToken, 'fresh_token');
      expect(sessionExpiredCalls, 0);
    },
  );

  test(
    'un refresh qui échoue déconnecte proprement toutes les requêtes en '
    'attente (pas de refresh en boucle, pas de blocage)',
    () async {
      final storage = _FakeSecureStorage()..refreshToken = null;
      final adapter = _FakeAdapter();
      var sessionExpiredCalls = 0;
      final dio = buildDioClient(
        storage,
        onSessionExpired: () async {
          sessionExpiredCalls++;
        },
      )..httpClientAdapter = adapter;

      await expectLater(
        dio.get('/dashboard/a'),
        throwsA(isA<DioException>()),
      );

      expect(adapter.refreshCallCount, 0);
      expect(sessionExpiredCalls, 1);
      expect(storage.sessionCleared, isTrue);
    },
  );
}
