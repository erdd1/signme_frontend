import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/badge_remote_datasource.dart';
import '../../data/datasources/badge_local_datasource.dart';
import '../../domain/entities/badge_count_entity.dart';
import '../../../../core/websocket/ws_provider.dart';
import '../../../../core/websocket/ws_client.dart';
import '../../../../core/utils/app_logger.dart';

// ─── Durée du polling périodique ─────────────────────────────────────────────
const Duration _kPollingInterval = Duration(seconds: 60);

// ─── Provider datasource distante ────────────────────────────────────────────
final badgeRemoteDataSourceProvider = Provider<BadgeRemoteDataSource>(
  (ref) => BadgeRemoteDataSource(ref.watch(dioProvider)),
);

// ─── Provider datasource locale (Isar) ───────────────────────────────────────
final badgeLocalDataSourceProvider = Provider<BadgeLocalDataSource>(
  (_) => BadgeLocalDataSource(),
);

// ─── Provider principal ───────────────────────────────────────────────────────
final badgeNotifierProvider =
    StateNotifierProvider<BadgeNotifier, AsyncValue<BadgeCountEntity>>(
  (ref) => BadgeNotifier(ref),
);

/// Notifier qui gère les compteurs de badges — Offline-First + WebSocket.
///
/// Responsabilités :
///   - Afficher immédiatement le cache Isar dès le login
///   - Rafraîchir depuis l'API en arrière-plan
///   - Réagir aux événements WebSocket [BadgeUpdated] en temps réel
///   - Polling de secours toutes les 60s
///   - Stopper tout au logout
class BadgeNotifier extends StateNotifier<AsyncValue<BadgeCountEntity>> {
  BadgeNotifier(this._ref) : super(const AsyncLoading()) {
    _authListener = _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        if (next.isAuthenticated) {
          if (previous?.isAuthenticated != true) {
            _loadFromCacheThenRefresh();
            _startPolling();
            _listenWebSocket();
          }
        } else {
          _stopAll();
          state = const AsyncData(BadgeCountEntity.empty);
        }
      },
      fireImmediately: true,
    );
  }

  final Ref _ref;
  Timer? _pollingTimer;
  StreamSubscription<WsEvent>? _wsSub;
  ProviderSubscription<AuthState>? _authListener;

  // ── Chargement initial ────────────────────────────────────────────────────

  Future<void> _loadFromCacheThenRefresh() async {
    final cached = await _ref.read(badgeLocalDataSourceProvider).get();
    if (mounted) state = AsyncData(cached);
    await refresh();
  }

  // ── Polling ───────────────────────────────────────────────────────────────

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(_kPollingInterval, (_) {
      if (_ref.read(authNotifierProvider).isAuthenticated) {
        refresh();
      } else {
        _stopAll();
      }
    });
  }

  // ── WebSocket ─────────────────────────────────────────────────────────────

  void _listenWebSocket() {
    _wsSub?.cancel();
    _wsSub = _ref.read(wsClientProvider).events.listen((event) {
      if (event.event == 'badge.updated' ||
          event.event == 'App\\Events\\BadgeUpdated') {
        _onBadgeWsEvent(event.data);
      }
    });
  }

  void _onBadgeWsEvent(Map<String, dynamic> data) {
    try {
      final entity = BadgeCountEntity(
        annonces:             (data['annonces'] as num?)?.toInt() ?? 0,
        meditations:          (data['meditations'] as num?)?.toInt() ?? 0,
        evenements:           (data['evenements'] as num?)?.toInt() ?? 0,
        historique:           (data['historique'] as num?)?.toInt() ?? 0,
        historiqueSignatures: (data['historique_signatures'] as num?)?.toInt() ?? 0,
      );
      if (mounted) state = AsyncData(entity);
      _ref.read(badgeLocalDataSourceProvider).save(entity);
    } catch (e) {
      // Sans conséquence pour l'utilisateur : refresh() corrige au prochain
      // sondage. Journalisé pour repérer un format d'event WS cassé.
      AppLogger.error('Événement WS badge invalide', e);
    }
  }

  // ── Actions publiques ─────────────────────────────────────────────────────

  /// Rafraîchit les compteurs depuis l'API et persiste en cache Isar.
  Future<void> refresh() async {
    if (!_ref.read(authNotifierProvider).isAuthenticated) return;
    try {
      final model  = await _ref.read(badgeRemoteDataSourceProvider).fetchBadgeCounts();
      final entity = model.toEntity();
      await _ref.read(badgeLocalDataSourceProvider).save(entity);
      if (mounted) state = AsyncData(entity);
    } catch (_) {
      if (mounted) {
        state = AsyncData(state.valueOrNull ?? BadgeCountEntity.empty);
      }
    }
  }

  /// Marque un type de badge comme lu (optimistic + sync + cache).
  ///
  /// [type] : 'annonces' | 'meditations' | 'evenements' | 'historique' | 'historique_signatures'
  Future<void> markRead(String type) async {
    if (!_ref.read(authNotifierProvider).isAuthenticated) return;

    final current    = state.valueOrNull ?? BadgeCountEntity.empty;
    final optimistic = current.copyWithZero(type);
    state = AsyncData(optimistic);

    try {
      final model  = await _ref.read(badgeRemoteDataSourceProvider).markRead(type);
      final entity = model.toEntity();
      await _ref.read(badgeLocalDataSourceProvider).save(entity);
      if (mounted) state = AsyncData(entity);
    } catch (_) {
      // Garder l'optimistic update, le polling resynchronisera.
      await _ref.read(badgeLocalDataSourceProvider).save(optimistic);
    }
  }

  void _stopAll() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _wsSub?.cancel();
    _wsSub = null;
  }

  @override
  void dispose() {
    _stopAll();
    _authListener?.close();
    super.dispose();
  }
}
