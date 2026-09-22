import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dio/dio.dart';
import '../config/app_environment.dart';
import '../storage/secure_storage.dart';
import '../utils/app_logger.dart';

/// Événement reçu depuis le WebSocket Reverb.
class WsEvent {
  const WsEvent({
    required this.channel,
    required this.event,
    required this.data,
  });

  final String channel;
  final String event;

  /// Payload JSON déjà décodé.
  final Map<String, dynamic> data;
}

/// Client WebSocket natif — implémente le protocole Pusher/Reverb.
///
/// Utilise [dart:io WebSocket] directement, évitant tout conflit de
/// dépendances. Implémente le protocole Pusher v7 :
///   1. Connexion WS → réception de `pusher:connection_established`
///   2. Authentification des channels privés via `/broadcasting/auth`
///   3. Abonnement aux channels `private-church.{id}` et `private-user.{id}`
///   4. Ping/pong heartbeat automatique
///   5. Reconnexion automatique avec backoff exponentiel
///
/// Utilisation via [WsProvider] dans Riverpod.
class WsClient {
  WsClient(this._storage);

  final SecureStorage _storage;

  WebSocket? _socket;
  Timer? _pingTimer;
  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;
  int _reconnectAttempts = 0;
  final Random _random = Random();

  int? _churchId;
  int? _userId;
  String? _socketId;

  final StreamController<WsEvent> _controller =
      StreamController<WsEvent>.broadcast();

  // ── Stream public ─────────────────────────────────────────────────────────

  /// Stream des événements reçus depuis Reverb.
  Stream<WsEvent> get events => _controller.stream;

  // ── Connexion ─────────────────────────────────────────────────────────────

  /// Connecte le client au serveur Reverb.
  Future<void> connect({
    required int churchId,
    required int userId,
  }) async {
    _churchId   = churchId;
    _userId     = userId;
    _intentionalDisconnect = false;

    await _connect();
  }

  Future<void> _connect() async {
    try {
      final scheme = AppEnvironment.reverbUseTLS ? 'wss' : 'ws';
      final url = '$scheme://${AppEnvironment.reverbHost}'
          ':${AppEnvironment.reverbPort}'
          '/app/${AppEnvironment.reverbAppKey}'
          '?protocol=7&client=dart&version=1.0&flash=false';

      _socket = await WebSocket.connect(url);
      _reconnectAttempts = 0;

      AppLogger.debug('[WS] Connecté à $url');

      _socket!.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      // ── Ping toutes les 30s pour maintenir la connexion ────────────────
      _pingTimer?.cancel();
      _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
        _sendRaw({'event': 'pusher:ping', 'data': {}});
      });
    } catch (e) {
      AppLogger.debug('[WS] Erreur de connexion : $e');
      _scheduleReconnect();
    }
  }

  // ── Déconnexion ───────────────────────────────────────────────────────────

  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    try {
      await _socket?.close();
    } catch (_) {}
    _socket = null;
    _socketId = null;
    AppLogger.debug('[WS] Déconnecté.');
  }

  void dispose() {
    disconnect();
    _controller.close();
  }

  // ── Gestion des messages ──────────────────────────────────────────────────

  void _onData(dynamic raw) {
    try {
      final Map<String, dynamic> msg = jsonDecode(raw as String);
      final String event = msg['event'] as String? ?? '';
      final dynamic rawData = msg['data'];
      final Map<String, dynamic> data = rawData is String
          ? (jsonDecode(rawData) as Map<String, dynamic>? ?? {})
          : (rawData as Map<String, dynamic>? ?? {});

      // ── Événements internes Pusher ────────────────────────────────────
      if (event == 'pusher:connection_established') {
        _socketId = data['socket_id'] as String?;
        AppLogger.debug('[WS] Socket ID : $_socketId');
        _subscribeToChannels();
        return;
      }

      if (event == 'pusher:pong' || event.startsWith('pusher_internal:')) {
        return;
      }

      // ── Événements métier → stream ────────────────────────────────────
      final String channel = msg['channel'] as String? ?? '';
      _controller.add(WsEvent(event: event, channel: channel, data: data));
    } catch (e) {
      AppLogger.debug('[WS] Erreur parsing : $e');
    }
  }

  void _onError(Object error) {
    AppLogger.debug('[WS] Erreur stream : $error');
    _scheduleReconnect();
  }

  void _onDone() {
    AppLogger.debug('[WS] Connexion fermée (intentionnel: $_intentionalDisconnect).');
    if (!_intentionalDisconnect) {
      _scheduleReconnect();
    }
  }

  // ── Abonnement aux channels privés ────────────────────────────────────────

  Future<void> _subscribeToChannels() async {
    final sid = _socketId;
    if (sid == null) return;

    if (_churchId != null) {
      await _subscribePrivate('private-church.$_churchId', sid);
    }
    if (_userId != null) {
      await _subscribePrivate('private-user.$_userId', sid);
    }
  }

  Future<void> _subscribePrivate(String channelName, String socketId) async {
    try {
      // ── Authentification via /broadcasting/auth ─────────────────────
      // Le token est relu depuis le stockage sécurisé à CHAQUE abonnement
      // (connexion initiale ET chaque reconnexion), jamais mis en cache ici :
      // une connexion WS reste ouverte des heures, et le token d'accès aura
      // très probablement été rafraîchi entre-temps par l'intercepteur HTTP
      // (dio_client.dart) — utiliser un token figé à la connexion initiale
      // ferait échouer silencieusement la ré-authentification du canal à la
      // moindre reconnexion (coupure réseau, veille de l'app…) après un
      // rafraîchissement, coupant le temps réel jusqu'au redémarrage de l'app.
      final token = await _storage.getAccessToken();
      final base = AppEnvironment.apiBaseUrl.replaceAll('/api/v1', '');
      final dio  = Dio();
      final resp = await dio.post(
        '$base/broadcasting/auth',
        data: {'socket_id': socketId, 'channel_name': channelName},
        options: Options(headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        }),
      );

      final authData = resp.data as Map<String, dynamic>;
      final authToken = authData['auth'] as String? ?? '';

      _sendRaw({
        'event': 'pusher:subscribe',
        'data': {
          'channel': channelName,
          'auth': authToken,
        },
      });

      AppLogger.debug('[WS] Abonné à $channelName');
    } catch (e) {
      AppLogger.debug('[WS] Erreur abonnement $channelName : $e');
    }
  }

  // ── Reconnexion automatique (backoff exponentiel) ────────────────────────

  void _scheduleReconnect() {
    if (_intentionalDisconnect) return;
    // onError ET onDone peuvent tous les deux se déclencher pour la MÊME
    // coupure (dart:io ferme le stream juste après une erreur) : sans cette
    // garde, chacun incrémentait _reconnectAttempts et reprogrammait un
    // timer, faisant grimper le backoff deux fois plus vite que prévu pour
    // un seul incident réel.
    if (_reconnectTimer?.isActive ?? false) return;

    _reconnectAttempts++;
    final baseSeconds = (_reconnectAttempts * 2).clamp(2, 60);
    // Jitter aléatoire (±30 %) : à l'échelle de centaines/milliers de
    // clients connectés, un backoff purement déterministe fait retenter TOUT
    // le monde à la même seconde après un incident serveur (redémarrage de
    // Reverb, coupure réseau globale) — un effet "thundering herd" qui peut
    // ré-écrouler le serveur juste au moment où il redevient disponible.
    final jitterRangeMs = (baseSeconds * 300).round();
    final jitterMs = _random.nextInt(jitterRangeMs * 2 + 1) - jitterRangeMs;
    final delay = Duration(
      milliseconds: (baseSeconds * 1000 + jitterMs).clamp(1000, 90000),
    );

    AppLogger.debug('[WS] Reconnexion dans ${delay.inMilliseconds}ms '
        '(tentative $_reconnectAttempts)…');

    _reconnectTimer = Timer(delay, () {
      if (!_intentionalDisconnect) _connect();
    });
  }

  // ── Utilitaire ────────────────────────────────────────────────────────────

  void _sendRaw(Map<String, dynamic> msg) {
    if (_socket?.readyState == WebSocket.open) {
      _socket!.add(jsonEncode(msg));
    }
  }
}
