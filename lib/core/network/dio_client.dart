import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/api_config.dart';
import '../config/app_environment.dart';
import '../errors/exceptions.dart';
import '../storage/secure_storage.dart';

typedef SessionExpiredCallback = Future<void> Function();

/// Construit et configure l'instance Dio avec interceptors Auth + Error
Dio buildDioClient(
  SecureStorage storage, {
  SessionExpiredCallback? onSessionExpired,
}) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  dio.interceptors.addAll([
    _AuthInterceptor(storage, dio, onSessionExpired: onSessionExpired),
    _ErrorInterceptor(),
  ]);

  if (kDebugMode && AppEnvironment.enableApiLogs) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        logPrint: (o) => debugPrint('[HTTP] $o'),
      ),
    );
  }

  return dio;
}

// ── Auth Interceptor ─────────────────────────────────────────────────────────
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(
    this._storage,
    this._dio, {
    this.onSessionExpired,
  });

  final SecureStorage _storage;
  final Dio _dio;
  final SessionExpiredCallback? onSessionExpired;

  /// Regroupe les 401 concurrents (ex. plusieurs widgets du Home qui
  /// appellent l'API en parallèle avec un token expiré) sur UNE SEULE
  /// requête de refresh réseau : avec un simple booléen, seule la première
  /// requête tentait le refresh et toutes celles arrivées en 401 pendant
  /// cette fenêtre échouaient immédiatement (AuthException) même si le
  /// refresh réussissait juste après — l'utilisateur voyait alors certains
  /// widgets se charger normalement et d'autres afficher une erreur
  /// d'authentification, sans raison apparente et sans être réellement
  /// déconnecté.
  Completer<bool?>? _refreshCompleter;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final path = err.requestOptions.path;

    // Ne pas tenter de refresh sur les routes d'authentification et de réinitialisation
    if (path.contains('/auth/login') ||
        path.contains('/auth/google') ||
        path.contains('/auth/refresh') ||
        path.contains('/auth/forgot-password') ||
        path.contains('/auth/verify-password-reset-otp') ||
        path.contains('/auth/resend-password-reset-otp') ||
        path.contains('/auth/confirm-password-reset') ||
        path.contains('/auth/reset-password')) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final refreshed = await _sharedRefresh();
      if (refreshed == true) {
        final token = await _storage.getAccessToken();
        err.requestOptions.headers['Authorization'] = 'Bearer $token';
        final cloneReq = await _dio.fetch(err.requestOptions);
        return handler.resolve(cloneReq);
      }
      // `refreshed == false` : le backend a explicitement rejeté le refresh
      // token (absent, expiré ou révoqué) — la session est vraiment finie.
      // `refreshed == null` : la tentative de refresh a échoué pour une
      // raison transitoire (réseau, timeout, panne serveur ponctuelle) — la
      // session locale reste potentiellement valide, donc on NE déconnecte
      // PAS l'utilisateur ; cette requête échoue simplement, la prochaine
      // retentera le refresh normalement. Avant ce correctif, toute erreur
      // pendant le refresh — même un simple aléa réseau — déconnectait
      // l'utilisateur, ce qui causait des déconnexions inopinées puisque
      // l'access token n'a que 30 min de durée de vie et déclenche donc un
      // refresh très fréquemment en usage normal.
      if (refreshed == false) {
        await _storage.clearSession();
        await onSessionExpired?.call();
      }
    }
    handler.next(err);
  }

  /// Si un refresh est déjà en cours, attend son résultat au lieu d'en
  /// déclencher un second (aussi bien pour éviter la double révocation que
  /// pour ne pas multiplier les allers-retours réseau à grande échelle).
  Future<bool?> _sharedRefresh() {
    final inFlight = _refreshCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<bool?>();
    _refreshCompleter = completer;
    _tryRefresh()
        .then(completer.complete, onError: (_) => completer.complete(null))
        .whenComplete(() => _refreshCompleter = null);
    return completer.future;
  }

  /// Retourne `true` si le refresh a réussi, `false` si le refresh token est
  /// confirmé invalide (absent localement, ou explicitement rejeté par le
  /// backend en 401/403 — session réellement expirée), ou `null` si la
  /// tentative a échoué pour une raison transitoire (réseau, timeout, erreur
  /// serveur) qui ne dit rien sur la validité réelle de la session.
  Future<bool?> _tryRefresh() async {
    final refresh = await _storage.getRefreshToken();
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final resp = await _dio.post(
        ApiConfig.refreshToken,
        data: {'refresh_token': refresh},
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final data = resp.data['data'] as Map<String, dynamic>;
        final access = data['access_token']?.toString() ?? '';
        if (access.isEmpty) return null;
        await _storage.saveAccessToken(access);
        if (data['refresh_token'] != null) {
          await _storage.saveRefreshToken(data['refresh_token'].toString());
        }
        return true;
      }
      return null;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      if (code == 401 || code == 403) return false;
      return null;
    }
  }
}

// ── Error Interceptor ────────────────────────────────────────────────────────
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return handler.reject(
          err.copyWith(error: TimeoutException()),
        );

      case DioExceptionType.connectionError:
        return handler.reject(
          err.copyWith(error: NetworkException()),
        );

      case DioExceptionType.badResponse:
        final code = err.response?.statusCode;
        final responseData = err.response?.data;
        // `responseData` n'est un Map (JSON) que si la requête n'a pas forcé
        // responseType.bytes (ex. téléchargement de PDF) — dans ce cas une
        // erreur serveur arrive quand même sous forme d'octets bruts, pas de
        // JSON, donc jamais indexable par clé.
        final msg = responseData is Map ? responseData['message']?.toString() : null;
        final errs = _parseErrors(responseData);

        switch (code) {
          case 401:
            return handler.reject(
              err.copyWith(
                error: AuthException(
                  message: msg ?? 'Non authentifié. Veuillez vous connecter.',
                ),
              ),
            );
          case 403:
            return handler.reject(
              err.copyWith(
                error: ForbiddenException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
          case 404:
            return handler.reject(
              err.copyWith(
                error: NotFoundException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
          case 422:
            return handler.reject(
              err.copyWith(
                error: ValidationException(
                  message: msg ?? 'Validation échouée',
                  errors: errs,
                ),
              ),
            );
          case 429:
            return handler.reject(
              err.copyWith(
                error: RateLimitException(
                  message: msg ??
                      'Trop de tentatives. Patientez avant de réessayer.',
                  retryAfterSeconds: _parseRetryAfter(err.response),
                ),
              ),
            );
          default:
            return handler.reject(
              err.copyWith(
                error: ServerException(
                  message: msg ?? 'Une erreur s\'est produite.',
                ),
              ),
            );
        }

      default:
        handler.next(err);
    }
  }

  int? _parseRetryAfter(Response<dynamic>? response) {
    if (response == null) return null;
    final header = response.headers.value('retry-after');
    if (header != null) {
      final parsed = int.tryParse(header);
      if (parsed != null) return parsed;
    }
    final data = response.data;
    if (data is Map) {
      final errors = data['errors'];
      if (errors is Map && errors['retry_after'] != null) {
        return int.tryParse(errors['retry_after'].toString());
      }
    }
    return null;
  }

  Map<String, List<String>> _parseErrors(dynamic data) {
    try {
      final raw = data?['errors'] as Map<String, dynamic>?;
      if (raw == null) return {};
      return raw.map(
        (k, v) => MapEntry(
          k,
          (v as List).map((e) => e.toString()).toList(),
        ),
      );
    } catch (_) {
      return {};
    }
  }
}
