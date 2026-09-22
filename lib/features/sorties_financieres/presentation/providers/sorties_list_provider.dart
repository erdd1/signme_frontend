import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../data/datasources/sorties_remote_datasource.dart';
import '../../domain/entities/sortie_financiere_entity.dart';
import 'sorties_financieres_provider.dart';
import 'sorties_dashboard_provider.dart';

class SortiesListState {
  const SortiesListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.error,
  });

  final List<SortieFinanciereEntity> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  SortiesListState copyWith({
    List<SortieFinanciereEntity>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) =>
      SortiesListState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
      );
}

class SortiesListNotifier extends StateNotifier<SortiesListState> {
  SortiesListNotifier(this._remote, this._connectivity)
      : super(const SortiesListState());

  final SortiesRemoteDataSource _remote;
  final ConnectivityService _connectivity;

  Future<void> load(SortiesFilter filters, {String? type, bool reset = false}) async {
    if (state.isLoading) return;

    final isOnline = await _connectivity.isOnline;
    if (!isOnline) return;

    final nextPage = reset ? 1 : state.currentPage + 1;

    if (!reset && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final params = filters.toQueryParams();
      if (type != null && type != 'tous') {
        params['type'] = type;
      }
      
      final result = await _remote.fetchList(
        params: params,
        page: nextPage,
      );

      final updatedItems = reset
          ? result.items
          : [...state.items, ...result.items];

      state = SortiesListState(
        items: updatedItems,
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: result.currentPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh(SortiesFilter filters, {String? type}) =>
      load(filters, type: type, reset: true);

  Future<void> loadMore(SortiesFilter filters, {String? type}) =>
      load(filters, type: type, reset: false);
}

final sortiesListProvider = StateNotifierProvider<SortiesListNotifier, SortiesListState>(
  (ref) => SortiesListNotifier(
    ref.watch(sortiesRemoteDataSourceProvider),
    ref.watch(connectivityServiceProvider),
  ),
);
