import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/chants_hub_session.dart';
import '../../data/datasources/chants_remote_datasource.dart';
import '../../domain/entities/chant_entity.dart';
import '../../domain/entities/chant_hub_entities.dart';

/// Session du hub (jeton + adresse) : une seule pour toute l'app.
final chantsHubSessionProvider = Provider<ChantsHubSession>((ref) {
  return ChantsHubSession(ref.watch(dioProvider));
});

final chantsRemoteDataSourceProvider = Provider<ChantsRemoteDataSource>((ref) {
  return ChantsRemoteDataSource(ref.watch(chantsHubSessionProvider));
});

/// État de la recherche : texte saisi + résultat de la dernière requête
/// aboutie. `isIdle` = pas encore assez de caractères pour chercher.
class ChantsSearchState {
  const ChantsSearchState({
    this.query = '',
    this.result = const AsyncValue.data(ChantsSearchResult()),
  });

  final String query;
  final AsyncValue<ChantsSearchResult> result;

  bool get isIdle => query.trim().length < ChantsSearchNotifier.minQueryLength;
}

class ChantsSearchNotifier extends StateNotifier<ChantsSearchState> {
  ChantsSearchNotifier(this._remote) : super(const ChantsSearchState());

  static const int minQueryLength = 2;
  static const Duration _debounce = Duration(milliseconds: 400);

  final ChantsRemoteDataSource _remote;
  Timer? _timer;
  CancelToken? _cancel;

  /// Appelé à chaque frappe : attend une courte pause avant d'interroger le
  /// serveur, et abandonne toute requête devenue obsolète.
  void onQueryChanged(String raw) {
    final query = raw.trim();
    _timer?.cancel();
    _cancel?.cancel();

    if (query.length < minQueryLength) {
      state = ChantsSearchState(query: query);
      return;
    }

    state = ChantsSearchState(query: query, result: const AsyncValue.loading());
    _timer = Timer(_debounce, () => _run(query));
  }

  /// Relance la recherche courante (bouton « Réessayer »).
  void retry() {
    if (state.isIdle) return;
    final query = state.query;
    state = ChantsSearchState(query: query, result: const AsyncValue.loading());
    _timer?.cancel();
    _run(query);
  }

  Future<void> _run(String query) async {
    final token = CancelToken();
    _cancel = token;
    try {
      final chants = await _remote.search(query, cancelToken: token);
      if (token.isCancelled || !mounted) return;
      state = ChantsSearchState(query: query, result: AsyncValue.data(chants));
    } catch (e, st) {
      if (token.isCancelled || !mounted) return;
      state = ChantsSearchState(query: query, result: AsyncValue.error(e, st));
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancel?.cancel();
    super.dispose();
  }
}

/// autoDispose : la recherche repart de zéro quand on quitte l'écran.
final chantsSearchProvider =
    StateNotifierProvider.autoDispose<ChantsSearchNotifier, ChantsSearchState>(
  (ref) => ChantsSearchNotifier(ref.watch(chantsRemoteDataSourceProvider)),
);

final chantDetailProvider =
    FutureProvider.autoDispose.family<ChantDetailEntity, int>((ref, id) {
  return ref.watch(chantsRemoteDataSourceProvider).fetchDetail(id);
});

/// Taille du texte des paroles (réglable par l'utilisateur, 1.0 = normal).
final chantTextScaleProvider = StateProvider<double>((ref) => 1.0);

// ── Écran d'accueil : mes chants, du moment ──────────────────────────────────

/// Mes chants regardés récemment (le plus récent d'abord).
final chantsHistoriqueProvider = FutureProvider.autoDispose<List<ChantReferenceEntity>>(
  (ref) => ref.watch(chantsRemoteDataSourceProvider).historique(),
);

/// Mes chants favoris.
final chantsFavorisProvider = FutureProvider.autoDispose<List<ChantReferenceEntity>>(
  (ref) => ref.watch(chantsRemoteDataSourceProvider).favoris(),
);

/// Chants du moment : regardés par plusieurs personnes différentes (anonyme).
final chantsTendancesProvider = FutureProvider.autoDispose<List<ChantReferenceEntity>>(
  (ref) => ref.watch(chantsRemoteDataSourceProvider).tendances(),
);

/// Recharge les listes de l'accueil (après avoir regardé un chant ou changé un favori).
void rafraichirAccueilChants(WidgetRef ref) {
  ref.invalidate(chantsHistoriqueProvider);
  ref.invalidate(chantsFavorisProvider);
  ref.invalidate(chantsTendancesProvider);
}
