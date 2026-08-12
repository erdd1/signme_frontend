import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../users/data/datasources/groupes_remote_datasource.dart';
import '../../data/datasources/contributions_remote_datasource.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/entities/contribution_filter_event_entity.dart';
import '../../domain/entities/contributions_treasury_stats_entity.dart';
import 'contributions_tresorerie_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Value-object immuable — état des filtres actifs sur le tableau de bord.
// Utilisé comme paramètre du StateNotifier et des FutureProvider.family.
// Pas de Provider Riverpod global : le cycle de vie est local au widget.
// ─────────────────────────────────────────────────────────────────────────────

class ContributionsTreasuryFilter {
  const ContributionsTreasuryFilter({
    this.eventId,
    this.eventLabel,
    this.groupeId,
    this.groupeLabel,
    this.year,
    this.month,
  });

  final int? eventId;
  final String? eventLabel; // pour l'affichage dans le résumé
  final int? groupeId;
  final String? groupeLabel;
  final int? year;
  final int? month;

  bool get hasAnyFilter =>
      eventId != null || groupeId != null || year != null || month != null;

  /// Convertit en query params pour le datasource.
  Map<String, dynamic> toQueryParams() => {
        if (eventId != null) 'event_id': eventId,
        if (groupeId != null) 'group_id': groupeId,
        if (year != null) 'year': year,
        if (month != null) 'month': month,
      };

  ContributionsTreasuryFilter copyWith({
    Object? eventId = _sentinel,
    Object? eventLabel = _sentinel,
    Object? groupeId = _sentinel,
    Object? groupeLabel = _sentinel,
    Object? year = _sentinel,
    Object? month = _sentinel,
  }) =>
      ContributionsTreasuryFilter(
        eventId:     eventId == _sentinel ? this.eventId : eventId as int?,
        eventLabel:  eventLabel == _sentinel ? this.eventLabel : eventLabel as String?,
        groupeId:    groupeId == _sentinel ? this.groupeId : groupeId as int?,
        groupeLabel: groupeLabel == _sentinel ? this.groupeLabel : groupeLabel as String?,
        year:        year == _sentinel ? this.year : year as int?,
        month:       month == _sentinel ? this.month : month as int?,
      );

  static const ContributionsTreasuryFilter empty = ContributionsTreasuryFilter();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContributionsTreasuryFilter &&
          other.eventId == eventId &&
          other.groupeId == groupeId &&
          other.year == year &&
          other.month == month;

  @override
  int get hashCode => Object.hash(eventId, groupeId, year, month);
}

// Sentinel pour distinguer null explicite de "non fourni" dans copyWith.
const _sentinel = Object();

// ─────────────────────────────────────────────────────────────────────────────
// État de la liste paginée (load-more)
// ─────────────────────────────────────────────────────────────────────────────

class ContributionsTreasuryListState {
  const ContributionsTreasuryListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.error,
  });

  final List<ContributionEntity> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  ContributionsTreasuryListState copyWith({
    List<ContributionEntity>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) =>
      ContributionsTreasuryListState(
        items:       items       ?? this.items,
        isLoading:   isLoading   ?? this.isLoading,
        hasMore:     hasMore     ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error:       error,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// StateNotifier — liste paginée avec load-more
// ─────────────────────────────────────────────────────────────────────────────

class ContributionsTreasuryListNotifier
    extends StateNotifier<ContributionsTreasuryListState> {
  ContributionsTreasuryListNotifier(this._remote, this._connectivity)
      : super(const ContributionsTreasuryListState());

  final ContributionsRemoteDataSource _remote;
  final dynamic _connectivity; // ConnectivityService

  /// Charge la page 1 (reset) ou la page suivante (load-more).
  Future<void> fetch(
    ContributionsTreasuryFilter filters, {
    bool reset = false,
  }) async {
    if (state.isLoading) return;

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) return;

    final nextPage = reset ? 1 : state.currentPage + 1;

    if (!reset && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _remote.listForDashboard(
        filters: filters.toQueryParams(),
        page: nextPage,
      );

      final updatedItems = reset
          ? result.items
          : [...state.items, ...result.items];

      state = ContributionsTreasuryListState(
        items:       updatedItems,
        isLoading:   false,
        hasMore:     result.hasMore,
        currentPage: result.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Alias sémantique utilisé par le pull-to-refresh.
  Future<void> refresh(ContributionsTreasuryFilter filters) =>
      fetch(filters, reset: true);

  /// Charge la page suivante (scroll infini).
  Future<void> loadMore(ContributionsTreasuryFilter filters) =>
      fetch(filters, reset: false);
}

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Liste paginée — chargée/rechargée à l'ouverture de la page, sans bootstrap.
final contributionsTreasuryListProvider = StateNotifierProvider<
    ContributionsTreasuryListNotifier,
    ContributionsTreasuryListState>(
  (ref) => ContributionsTreasuryListNotifier(
    ref.watch(contributionsRemoteForTreasuryProvider),
    ref.watch(connectivityServiceProvider),
  ),
);

/// Stats financières agrégées — recalculées côté backend à chaque changement
/// de filtre. [ContributionsTreasuryFilter.empty] = stats globales (card bleu).
final contributionsTreasuryStatsProvider =
    FutureProvider.family<ContributionsTreasuryStatsEntity, ContributionsTreasuryFilter>(
  (ref, filter) async {
    final remote = ref.watch(contributionsRemoteForTreasuryProvider);
    return remote.getTreasuryStats(filters: filter.toQueryParams());
  },
);

/// Événements ayant des contributions — pour le dropdown "Événement".
/// Chargé une seule fois par session (autoDispose = false).
final contributionsFilterEventsProvider =
    FutureProvider<List<ContributionFilterEventEntity>>((ref) async {
  final remote = ref.watch(contributionsRemoteForTreasuryProvider);
  return remote.getFilterEvents();
});

/// Groupes de l'église — pour le dropdown "Groupe".
/// Réutilise le datasource existant (GroupesRemoteDataSource).
final contributionsFilterGroupesProvider =
    FutureProvider<List<GroupeRef>>((ref) async {
  final remote = GroupesRemoteDataSource(ref.watch(dioProvider));
  return remote.list();
});
