import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/rapport_annuel_entity.dart';
import '../../domain/entities/rapport_comparaison_entity.dart';
import '../../domain/entities/rapport_mensuel_entity.dart';
import '../../data/datasources/finances_remote_datasource.dart';
import '../../data/datasources/finances_local_datasource.dart';
import 'finances_data_providers.dart';

class FinancesState {
  const FinancesState({
    this.year,
    this.annualByYear = const {},
    this.loadingAnnualYears = const {},
    this.monthDetailsByKey = const {},
    this.loadingMonthKeys = const {},
    this.comparison,
    this.isLoadingComparison = false,
    this.hasLoadedComparison = false,
    this.selectedMonthIndex,
    this.annualError,
    this.monthError,
  });

  final int? year;
  final Map<int, RapportAnnuelEntity> annualByYear;
  final Set<int> loadingAnnualYears;
  final Map<String, RapportMensuelEntity> monthDetailsByKey;
  final Set<String> loadingMonthKeys;
  final RapportComparaisonEntity? comparison;
  final bool isLoadingComparison;
  final bool hasLoadedComparison;
  final int? selectedMonthIndex;
  final String? annualError;
  final String? monthError;

  int get currentYear => year ?? DateTime.now().year;

  RapportAnnuelEntity get currentAnnual =>
      annualByYear[currentYear] ?? RapportAnnuelEntity.empty(currentYear);

  bool isLoadingAnnual(int y) => loadingAnnualYears.contains(y);

  bool hasAnnualFor(int y) => annualByYear.containsKey(y);

  bool isLoadingMonthKey(String monthKey) => loadingMonthKeys.contains(monthKey);

  factory FinancesState.initial() => FinancesState(
        year: DateTime.now().year,
        selectedMonthIndex: DateTime.now().month - 1,
      );

  FinancesState copyWith({
    int? year,
    Map<int, RapportAnnuelEntity>? annualByYear,
    Set<int>? loadingAnnualYears,
    Map<String, RapportMensuelEntity>? monthDetailsByKey,
    Set<String>? loadingMonthKeys,
    RapportComparaisonEntity? comparison,
    bool? isLoadingComparison,
    bool? hasLoadedComparison,
    int? selectedMonthIndex,
    String? annualError,
    String? monthError,
    bool clearAnnualError = false,
    bool clearMonthError = false,
  }) =>
      FinancesState(
        year: year ?? this.year,
        annualByYear: annualByYear ?? this.annualByYear,
        loadingAnnualYears: loadingAnnualYears ?? this.loadingAnnualYears,
        monthDetailsByKey: monthDetailsByKey ?? this.monthDetailsByKey,
        loadingMonthKeys: loadingMonthKeys ?? this.loadingMonthKeys,
        comparison: comparison ?? this.comparison,
        isLoadingComparison: isLoadingComparison ?? this.isLoadingComparison,
        hasLoadedComparison: hasLoadedComparison ?? this.hasLoadedComparison,
        selectedMonthIndex: selectedMonthIndex ?? this.selectedMonthIndex,
        annualError: clearAnnualError ? null : annualError ?? this.annualError,
        monthError: clearMonthError ? null : monthError ?? this.monthError,
      );
}

class FinancesNotifier extends StateNotifier<FinancesState> {
  FinancesNotifier(this._remote, this._local) : super(FinancesState.initial());

  final FinancesRemoteDataSource _remote;
  final FinancesLocalDataSource _local;
  bool _annualLoadInProgress = false;

  Future<void> loadIfNeeded() async {
    final y = state.currentYear;
    await loadAnnual(y);
    if (!state.hasLoadedComparison && !state.isLoadingComparison) {
      await loadComparison();
    }
  }

  Future<void> loadAnnual(int year, {bool force = false, int retryPass = 0}) async {
    if (!force && state.hasAnnualFor(year)) {
      state = state.copyWith(year: year, clearAnnualError: true);
      await _loadMonthDetailForSelection();
      return;
    }

    if (_annualLoadInProgress && !force) return;
    _annualLoadInProgress = true;

    state = state.copyWith(year: year, clearAnnualError: true, clearMonthError: true);

    // Hydrater depuis le cache Isar avant de marquer l'année "en chargement"
    // — évite le shimmer si on a déjà des données persistées (ex: après un
    // redémarrage de l'app).
    if (!state.hasAnnualFor(year)) {
      final cachedRaw = await _local.getAnnual(year);
      if (cachedRaw != null) {
        final cachedAnnualMap = Map<int, RapportAnnuelEntity>.from(state.annualByYear)
          ..[year] = RapportAnnuelEntity.fromJson(cachedRaw);
        state = state.copyWith(annualByYear: cachedAnnualMap);
        await _loadMonthDetailForSelection();
      }
    }

    if (!state.hasAnnualFor(year)) {
      state = state.copyWith(loadingAnnualYears: {...state.loadingAnnualYears, year});
    }

    try {
      final raw = await _remote.getRapportAnnuelRaw(year);
      await _local.saveAnnual(year, raw);
      final data = RapportAnnuelEntity.fromJson(raw);
      final annualMap = Map<int, RapportAnnuelEntity>.from(state.annualByYear)
        ..[year] = data;
      final loading = Set<int>.from(state.loadingAnnualYears)..remove(year);
      state = state.copyWith(
        annualByYear: annualMap,
        loadingAnnualYears: loading,
      );
      await _loadMonthDetailForSelection();
    } on AppException catch (e) {
      final loading = Set<int>.from(state.loadingAnnualYears)..remove(year);
      state = state.copyWith(
        loadingAnnualYears: loading,
        annualError: state.hasAnnualFor(year) ? null : e.message,
      );
    } catch (e) {
      final loading = Set<int>.from(state.loadingAnnualYears)..remove(year);
      state = state.copyWith(
        loadingAnnualYears: loading,
        annualError: state.hasAnnualFor(year) ? null : messageFromError(e),
      );
    } finally {
      _annualLoadInProgress = false;
    }

    if (!state.hasAnnualFor(year) && retryPass < 1) {
      await loadAnnual(year, force: false, retryPass: retryPass + 1);
    }
  }

  Future<void> loadComparison({bool force = false}) async {
    if (state.isLoadingComparison) return;
    if (!force && state.hasLoadedComparison && state.comparison != null) {
      return;
    }

    state = state.copyWith(isLoadingComparison: true);
    try {
      final data = await _remote.getComparaison();
      state = state.copyWith(
        comparison: data,
        isLoadingComparison: false,
        hasLoadedComparison: true,
      );
    } catch (_) {
      state = state.copyWith(
        isLoadingComparison: false,
        hasLoadedComparison: true,
        comparison: RapportComparaisonEntity.empty(),
      );
    }
  }

  Future<void> selectMonth(int idx) async {
    state = state.copyWith(
      selectedMonthIndex: idx,
      clearMonthError: true,
    );
    await _loadMonthDetailForSelection();
  }

  Future<void> _loadMonthDetailForSelection({bool force = false, bool silent = false}) async {
    final idx = state.selectedMonthIndex;
    final year = state.currentYear;
    if (idx == null || idx < 0 || idx > 11) return;
    if (!state.hasAnnualFor(year)) return;

    final annual = state.currentAnnual;
    final monthKey = annual.monthlyData[idx].monthKey.isNotEmpty
        ? annual.monthlyData[idx].monthKey
        : '$year-${(idx + 1).toString().padLeft(2, '0')}';

    final hasDetail = state.monthDetailsByKey.containsKey(monthKey);
    if (!force && hasDetail) {
      return;
    }

    if (!silent || !hasDetail) {
      state = state.copyWith(
        loadingMonthKeys: {...state.loadingMonthKeys, monthKey},
        clearMonthError: true,
      );
    }

    try {
      final detail = await _remote.getRapportMois(monthKey);
      final details = Map<String, RapportMensuelEntity>.from(state.monthDetailsByKey)
        ..[monthKey] = detail;
      final loading = Set<String>.from(state.loadingMonthKeys)..remove(monthKey);
      state = state.copyWith(
        monthDetailsByKey: details,
        loadingMonthKeys: loading,
      );
    } on AppException catch (e) {
      final loading = Set<String>.from(state.loadingMonthKeys)..remove(monthKey);
      state = state.copyWith(
        loadingMonthKeys: loading,
        monthError: e.message,
      );
    } catch (e) {
      final loading = Set<String>.from(state.loadingMonthKeys)..remove(monthKey);
      state = state.copyWith(
        loadingMonthKeys: loading,
        monthError: messageFromError(e),
      );
    }
  }

  void previousYear() => loadAnnual(state.currentYear - 1);
  void nextYear() => loadAnnual(state.currentYear + 1);

  Future<void> refresh() async {
    final y = state.currentYear;
    await Future.wait([
      loadAnnual(y, force: true),
      loadComparison(force: true),
    ]);
  }

  /// Rafraîchit silencieusement l'année et la comparaison courantes (appelé
  /// à chaque ouverture de l'écran) sans jamais marquer "en chargement" — les
  /// données déjà affichées restent visibles pendant la mise à jour.
  Future<void> refreshSilently() async {
    final year = state.currentYear;
    try {
      final raw = await _remote.getRapportAnnuelRaw(year);
      await _local.saveAnnual(year, raw);
      final annualMap = Map<int, RapportAnnuelEntity>.from(state.annualByYear)
        ..[year] = RapportAnnuelEntity.fromJson(raw);
      state = state.copyWith(annualByYear: annualMap, clearAnnualError: true);
      await _loadMonthDetailForSelection(force: true, silent: true);
    } catch (_) {
      // Réseau en échec : on garde les données déjà affichées.
    }

    try {
      final comparison = await _remote.getComparaison();
      state = state.copyWith(
        comparison: comparison,
        hasLoadedComparison: true,
      );
    } catch (_) {
      // Réseau en échec : on garde la comparaison déjà affichée.
    }
  }

  void reset() {
    _annualLoadInProgress = false;
    state = FinancesState.initial();
  }
}

final financesProvider =
    StateNotifierProvider<FinancesNotifier, FinancesState>((ref) {
  ref.keepAlive();
  final notifier = FinancesNotifier(
    ref.watch(financesRemoteDataSourceProvider),
    ref.watch(financesLocalDataSourceProvider),
  );
  ref.onDispose(notifier.reset);
  return notifier;
});

/// Précharge finances au login (utilisateurs autorisés uniquement).
final financesBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<AuthState>(
    authNotifierProvider,
    (previous, next) {
      final user = next.auth?.user;
      final canView =
          next.isInitialized && next.isAuthenticated && user != null &&
          AppPermissions.canViewFinances(user);

      if (canView) {
        Future<void>.microtask(() => ref.read(financesProvider.notifier).loadIfNeeded());
      } else if (previous?.isAuthenticated == true && !next.isAuthenticated) {
        ref.read(financesProvider.notifier).reset();
      }
    },
    fireImmediately: true,
  );
});
