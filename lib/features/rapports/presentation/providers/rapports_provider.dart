import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/rapport_secretaire_entity.dart';
import '../../domain/entities/rapport_membre_entity.dart';
import '../../data/datasources/rapport_secretaire_remote_datasource.dart';
import '../../data/datasources/rapport_secretaire_local_datasource.dart';

final rapportDataSourceProvider =
    Provider<RapportSecretaireRemoteDataSource>((ref) {
  return RapportSecretaireRemoteDataSource(ref.watch(dioProvider));
});

final rapportSecretaireLocalDataSourceProvider =
    Provider<RapportSecretaireLocalDataSource>(
  (_) => RapportSecretaireLocalDataSource(),
);

// ── State ──────────────────────────────────────────────────────────────────
//
// Offline-First : les rapports déjà chargés (cache Isar ou session) restent
// affichés pendant qu'un rafraîchissement réseau se fait en arrière-plan —
// jamais de retour à un état vide une fois qu'on a des données pour le mois.
class RapportState {
  const RapportState({
    this.month,
    this.dataByMonth = const {},
    this.loadingMonths = const {},
    this.error,
  });

  final String? month;
  final Map<String, RapportSecretaireEntity> dataByMonth;
  final Set<String> loadingMonths;
  final String? error;

  String get currentMonth => month ?? _currentMonthKey();

  RapportSecretaireEntity get data =>
      dataByMonth[currentMonth] ?? RapportSecretaireEntity.empty();

  bool get isLoading => loadingMonths.contains(currentMonth);

  bool hasDataFor(String m) => dataByMonth.containsKey(m);

  static String _currentMonthKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  factory RapportState.initial() => const RapportState();

  RapportState copyWith({
    String? month,
    Map<String, RapportSecretaireEntity>? dataByMonth,
    Set<String>? loadingMonths,
    String? error,
    bool clearError = false,
  }) =>
      RapportState(
        month: month ?? this.month,
        dataByMonth: dataByMonth ?? this.dataByMonth,
        loadingMonths: loadingMonths ?? this.loadingMonths,
        error: clearError ? null : error ?? this.error,
      );
}

// ── Notifier ───────────────────────────────────────────────────────────────
class RapportSecretaireNotifier extends StateNotifier<RapportState> {
  RapportSecretaireNotifier(this._ds, this._local, this._ref)
      : super(RapportState.initial()) {
    load(month: state.currentMonth);
  }

  final RapportSecretaireRemoteDataSource _ds;
  final RapportSecretaireLocalDataSource _local;
  final Ref _ref;

  Future<void> load({String? month, bool force = false}) async {
    final monthToLoad = month ?? state.currentMonth;
    state = state.copyWith(month: monthToLoad, clearError: true);

    // Hydrater depuis le cache Isar avant de marquer "en chargement" — évite
    // le shimmer si on a déjà des données persistées pour ce mois.
    if (!force && !state.hasDataFor(monthToLoad)) {
      final cachedRaw = await _local.get(monthToLoad);
      if (cachedRaw != null) {
        final cachedData = Map<String, RapportSecretaireEntity>.from(state.dataByMonth)
          ..[monthToLoad] = RapportSecretaireEntity.fromJson(cachedRaw);
        state = state.copyWith(dataByMonth: cachedData);
      }
    }

    if (!force && state.hasDataFor(monthToLoad)) {
      // Déjà en cache/session : on rafraîchit silencieusement (pas de flag
      // loading) plutôt que de bloquer l'UI.
      await _fetchAndUpdate(monthToLoad, silent: true);
      return;
    }

    final isOnline = await _ref.read(connectivityServiceProvider).isOnline;
    if (!isOnline && !state.hasDataFor(monthToLoad)) {
      state = state.copyWith(error: 'Données non disponibles hors ligne.');
      return;
    }

    if (!state.hasDataFor(monthToLoad)) {
      state = state.copyWith(
        loadingMonths: {...state.loadingMonths, monthToLoad},
      );
    }

    await _fetchAndUpdate(monthToLoad, silent: state.hasDataFor(monthToLoad));
  }

  Future<void> _fetchAndUpdate(String month, {required bool silent}) async {
    try {
      final raw = await _ds.getRapportSecretaireRaw(month: month);
      await _local.save(month, raw);
      final entity = RapportSecretaireEntity.fromJson(raw);
      final dataMap = Map<String, RapportSecretaireEntity>.from(state.dataByMonth)
        ..[month] = entity;
      final loading = Set<String>.from(state.loadingMonths)..remove(month);
      state = state.copyWith(dataByMonth: dataMap, loadingMonths: loading, clearError: true);
    } catch (e) {
      final loading = Set<String>.from(state.loadingMonths)..remove(month);
      state = state.copyWith(
        loadingMonths: loading,
        error: state.hasDataFor(month) ? null : messageFromError(e),
      );
    }
  }

  /// Rafraîchit silencieusement le mois courant (appelé à chaque ouverture
  /// de l'écran), sans jamais cacher les données déjà affichées.
  Future<void> refreshSilently() => load(month: state.currentMonth, force: false);

  Future<void> refresh({String? month}) => load(month: month ?? state.currentMonth, force: true);
}

final rapportSecretaireProvider =
    StateNotifierProvider<RapportSecretaireNotifier, RapportState>((ref) {
  ref.keepAlive();
  return RapportSecretaireNotifier(
    ref.watch(rapportDataSourceProvider),
    ref.watch(rapportSecretaireLocalDataSourceProvider),
    ref,
  );
});

/// Précharge le rapport secrétaire du mois courant au login.
final rapportSecretaireBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<AuthState>(
    authNotifierProvider,
    (previous, next) {
      if (next.isInitialized && next.isAuthenticated &&
          previous?.isAuthenticated != true) {
        Future<void>.microtask(() => ref.read(rapportSecretaireProvider.notifier).load());
      }
    },
    fireImmediately: true,
  );
});

// ── Listes filtrées (Signés / Non-Signés) ──────────────────────────────────
class RapportMembresListState {
  const RapportMembresListState({
    this.membres = const [],
    this.isLoading = false,
    this.error,
    this.searchQuery = '',
  });

  final List<RapportMembreEntity> membres;
  final bool isLoading;
  final String? error;
  final String searchQuery;

  RapportMembresListState copyWith({
    List<RapportMembreEntity>? membres,
    bool? isLoading,
    String? error,
    String? searchQuery,
    bool clearError = false,
  }) =>
      RapportMembresListState(
        membres: membres ?? this.membres,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  /// Filtre les membres selon la requête de recherche
  List<RapportMembreEntity> get filtered {
    if (searchQuery.isEmpty) return membres;
    final q = searchQuery.toLowerCase();
    return membres
        .where(
          (m) =>
              m.nom.toLowerCase().contains(q) ||
              m.email.toLowerCase().contains(q),
        )
        .toList();
  }
}

class RapportMembresListNotifier extends StateNotifier<RapportMembresListState> {
  RapportMembresListNotifier() : super(const RapportMembresListState());

  /// Met à jour la liste des membres
  void setMembers(List<RapportMembreEntity> members) {
    state = state.copyWith(membres: members, isLoading: false);
  }

  /// Effectue une recherche sur la liste
  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  /// Efface la recherche
  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

final rapportSignesListProvider =
    StateNotifierProvider<RapportMembresListNotifier, RapportMembresListState>(
      (ref) => RapportMembresListNotifier(),
    );

final rapportNonSignesListProvider =
    StateNotifierProvider<RapportMembresListNotifier, RapportMembresListState>(
      (ref) => RapportMembresListNotifier(),
    );
