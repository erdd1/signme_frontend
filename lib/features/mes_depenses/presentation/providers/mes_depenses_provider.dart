import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/utils/pending_refresh_scheduler.dart';
import '../../domain/entities/contribution_perso_entity.dart';
import '../../domain/entities/mes_depenses_stats_entity.dart';
import 'mes_depenses_data_providers.dart';

/// Historique personnel filtré (année/mois) — Offline-First : cache Isar puis
/// rafraîchissement réseau, sans jamais faire clignoter l'écran.
///
/// Toutes les contributions remontent, quel que soit leur statut : dès
/// l'envoi d'une contribution à distance, elle doit apparaître "en cours de
/// traitement" puis passer à "payé"/"paiement échoué" — [_pendingScheduler]
/// relance un [refresh] léger tant qu'une contribution reste en attente (même
/// mécanisme que l'historique personnel des signatures, voir sa doc).
class MesDepensesListNotifier extends StateNotifier<AsyncValue<List<ContributionPersoEntity>>> {
  MesDepensesListNotifier(this._ref, this._annee, this._mois) : super(const AsyncLoading()) {
    _pendingScheduler = PendingRefreshScheduler(refresh: refresh);
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;
  final int? _annee;
  final int? _mois;
  late final PendingRefreshScheduler _pendingScheduler;

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(mesDepensesLocalDataSourceProvider);
    final cached = await local.getList(_annee, _mois);
    if (cached != null && mounted) {
      final entities = cached.map(ContributionPersoEntity.fromJson).toList();
      state = AsyncData(entities);
      _pendingScheduler.scheduleIfNeeded(entities.any((c) => c.isPending));
    }
    await refresh();
  }

  Future<void> refresh() async {
    final connectivity = _ref.read(connectivityServiceProvider);
    final isOnline = await connectivity.isOnline;
    if (!isOnline) return;

    final remote = _ref.read(mesDepensesRemoteDataSourceProvider);
    final local = _ref.read(mesDepensesLocalDataSourceProvider);

    try {
      final rows = await remote.list(annee: _annee, mois: _mois);
      await local.saveList(_annee, _mois, rows);
      final entities = rows.map(ContributionPersoEntity.fromJson).toList();
      if (mounted) state = AsyncData(entities);
      _pendingScheduler.scheduleIfNeeded(entities.any((c) => c.isPending));
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        final cached = await local.getList(_annee, _mois);
        state = cached != null
            ? AsyncData(cached.map(ContributionPersoEntity.fromJson).toList())
            : AsyncError(e, st);
      }
    }
  }

  @override
  void dispose() {
    _pendingScheduler.dispose();
    super.dispose();
  }
}

final mesDepensesListProvider = StateNotifierProvider.autoDispose<
    MesDepensesListNotifier, AsyncValue<List<ContributionPersoEntity>>>((ref) {
  final annee = ref.watch(mesDepensesYearProvider);
  final mois = ref.watch(mesDepensesMonthProvider);
  return MesDepensesListNotifier(ref, annee, mois);
});

/// Statistiques (total/mois/année + période sélectionnée) — Offline-First.
class MesDepensesStatsNotifier extends StateNotifier<AsyncValue<MesDepensesStatsEntity>> {
  MesDepensesStatsNotifier(this._ref, this._annee, this._mois) : super(const AsyncLoading()) {
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;
  final int? _annee;
  final int? _mois;

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(mesDepensesLocalDataSourceProvider);
    final cached = await local.getStats(_annee, _mois);
    if (cached != null && mounted) {
      state = AsyncData(MesDepensesStatsEntity.fromJson(cached));
    }
    await refresh();
  }

  Future<void> refresh() async {
    final connectivity = _ref.read(connectivityServiceProvider);
    final isOnline = await connectivity.isOnline;
    if (!isOnline) return;

    final remote = _ref.read(mesDepensesRemoteDataSourceProvider);
    final local = _ref.read(mesDepensesLocalDataSourceProvider);

    try {
      final raw = await remote.stats(annee: _annee, mois: _mois);
      await local.saveStats(_annee, _mois, raw);
      if (mounted) state = AsyncData(MesDepensesStatsEntity.fromJson(raw));
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        final cached = await local.getStats(_annee, _mois);
        state = cached != null
            ? AsyncData(MesDepensesStatsEntity.fromJson(cached))
            : AsyncError(e, st);
      }
    }
  }
}

final mesDepensesStatsProvider =
    StateNotifierProvider.autoDispose<MesDepensesStatsNotifier, AsyncValue<MesDepensesStatsEntity>>(
  (ref) {
    final annee = ref.watch(mesDepensesYearProvider);
    final mois = ref.watch(mesDepensesMonthProvider);
    return MesDepensesStatsNotifier(ref, annee, mois);
  },
);
