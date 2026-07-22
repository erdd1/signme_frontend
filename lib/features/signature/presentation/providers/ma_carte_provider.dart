import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/signature_local_datasource.dart';
import '../../data/datasources/signature_remote_datasource.dart';
import '../../domain/entities/signature_entity.dart';
import '../../domain/ma_carte_years.dart';
import 'signature_data_providers.dart';

class MaCarteState {
  const MaCarteState({
    this.cartesByYear = const {},
    this.loadingYears = const {},
    this.error,
  });

  final Map<int, MaCarteData> cartesByYear;
  final Set<int> loadingYears;
  final String? error;

  bool isYearLoading(int year) => loadingYears.contains(year);

  bool get hasAllYears =>
      MaCarteYears.display.every(cartesByYear.containsKey);

  MaCarteData? carteForYear(int year) => cartesByYear[year];

  MaCarteState copyWith({
    Map<int, MaCarteData>? cartesByYear,
    Set<int>? loadingYears,
    String? error,
    bool clearError = false,
  }) =>
      MaCarteState(
        cartesByYear: cartesByYear ?? this.cartesByYear,
        loadingYears: loadingYears ?? this.loadingYears,
        error: clearError ? null : error ?? this.error,
      );
}

class MaCarteNotifier extends StateNotifier<MaCarteState> {
  MaCarteNotifier(this._remote, this._local, this._connectivity)
      : super(const MaCarteState());

  final SignatureRemoteDataSource _remote;
  final SignatureLocalDataSource _local;
  final ConnectivityService _connectivity;
  bool _loadInProgress = false;

  Future<void> loadIfNeeded() => load(force: false);

  List<int> _yearsToFetch({required bool force}) {
    if (force) return List<int>.from(MaCarteYears.display);
    return MaCarteYears.display
        .where((y) => !state.cartesByYear.containsKey(y))
        .toList();
  }

  Future<void> _hydrateFromCache(Iterable<int> years) async {
    final cartes = Map<int, MaCarteData>.from(state.cartesByYear);

    for (final year in years) {
      if (cartes.containsKey(year)) continue;
      final cached = await _local.getMaCarte(year);
      if (cached == null) continue;
      cartes[year] = MaCarteData.fromJson(cached);
    }

    if (cartes.length != state.cartesByYear.length) {
      state = state.copyWith(cartesByYear: cartes, clearError: true);
    }
  }

  Future<void> load({bool force = false, int retryPass = 0}) async {
    final requestedYears = _yearsToFetch(force: force);
    if (requestedYears.isEmpty) return;

    if (_loadInProgress && !force) return;
    _loadInProgress = true;

    state = state.copyWith(
      loadingYears: {...state.loadingYears, ...requestedYears},
      clearError: true,
    );

    await _hydrateFromCache(requestedYears);

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      final loading = Set<int>.from(state.loadingYears)
        ..removeAll(requestedYears);
      state = state.copyWith(
        loadingYears: loading,
        error: state.cartesByYear.isEmpty
            ? 'Donnees non disponibles hors ligne.'
            : null,
      );
      _loadInProgress = false;
      return;
    }

    String? lastError;
    for (final year in requestedYears) {
      try {
        final raw = await _remote.getMaCarteRaw(year);
        await _local.saveMaCarte(year, raw);
        final data = MaCarteData.fromJson(raw);
        final cartes = Map<int, MaCarteData>.from(state.cartesByYear)
          ..[year] = data;
        final loading = Set<int>.from(state.loadingYears)..remove(year);
        state = MaCarteState(
          cartesByYear: cartes,
          loadingYears: loading,
          error: lastError,
        );
      } catch (e) {
        await _hydrateFromCache([year]);
        lastError = state.cartesByYear.containsKey(year)
            ? null
            : messageFromError(e);
        final loading = Set<int>.from(state.loadingYears)..remove(year);
        state = state.copyWith(
          loadingYears: loading,
          error: lastError,
        );
      }
    }

    _loadInProgress = false;

    final missing = _yearsToFetch(force: false);
    if (missing.isNotEmpty && retryPass < 1) {
      await load(force: false, retryPass: retryPass + 1);
    }
  }

  /// Rafraîchit silencieusement toutes les années affichées (appelé à chaque
  /// ouverture de l'écran) sans jamais marquer "en chargement" — les données
  /// déjà affichées restent visibles pendant la mise à jour en arrière-plan.
  Future<void> refreshSilently() async {
    final isOnline = await _connectivity.isOnline;
    if (!isOnline) return;

    for (final year in MaCarteYears.display) {
      try {
        final raw = await _remote.getMaCarteRaw(year);
        await _local.saveMaCarte(year, raw);
        final cartes = Map<int, MaCarteData>.from(state.cartesByYear)
          ..[year] = MaCarteData.fromJson(raw);
        state = state.copyWith(cartesByYear: cartes, clearError: true);
      } catch (_) {
        // Réseau en échec pour cette année : on garde les données déjà
        // affichées et on continue avec les autres années.
      }
    }
  }

  void reset() {
    _loadInProgress = false;
    state = const MaCarteState();
  }
}

final maCarteProvider =
    StateNotifierProvider<MaCarteNotifier, MaCarteState>((ref) {
  ref.keepAlive();
  final notifier = MaCarteNotifier(
    ref.watch(signatureRemoteDataSourceProvider),
    ref.watch(signatureLocalDataSourceProvider),
    ref.watch(connectivityServiceProvider),
  );
  ref.onDispose(notifier.reset);
  return notifier;
});

final maCarteBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<bool>(
    authNotifierProvider.select(
      (s) => s.isInitialized && s.isAuthenticated,
    ),
    (wasAuthenticated, isAuthenticated) {
      if (isAuthenticated) {
        Future<void>.microtask(() => ref.read(maCarteProvider.notifier).loadIfNeeded());
      } else if (wasAuthenticated == true) {
        ref.read(maCarteProvider.notifier).reset();
      }
    },
    fireImmediately: true,
  );
});