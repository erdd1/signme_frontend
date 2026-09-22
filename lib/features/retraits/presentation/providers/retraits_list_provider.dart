import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/retraits_remote_datasource.dart';
import '../../domain/entities/retrait_entity.dart';
import 'retraits_provider.dart';

class RetraitsListState {
  const RetraitsListState({
    this.items = const [],
    this.isLoading = false,
    this.hasMore = false,
    this.currentPage = 0,
    this.error,
  });

  final List<RetraitEntity> items;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  RetraitsListState copyWith({
    List<RetraitEntity>? items,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) =>
      RetraitsListState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        currentPage: currentPage ?? this.currentPage,
        error: error,
      );
}

class RetraitsListNotifier extends StateNotifier<RetraitsListState> {
  RetraitsListNotifier(this._remote) : super(const RetraitsListState());

  final RetraitsRemoteDataSource _remote;

  Future<void> load({bool reset = false}) async {
    if (state.isLoading) return;

    final nextPage = reset ? 1 : state.currentPage + 1;
    if (!reset && !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _remote.fetchHistorique(page: nextPage);
      final updatedItems = reset ? result.items : [...state.items, ...result.items];

      state = RetraitsListState(
        items: updatedItems,
        isLoading: false,
        hasMore: result.hasMore,
        currentPage: result.currentPage,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load(reset: true);

  Future<void> loadMore() => load(reset: false);

  /// Revérifie un retrait précis auprès de NotchPay et remplace son entrée
  /// dans la liste en place (pas de rechargement complet).
  Future<void> recheck(String uuid) async {
    final updated = await _remote.recheck(uuid);
    state = state.copyWith(
      items: [for (final r in state.items) r.uuid == uuid ? updated : r],
    );
  }
}

final retraitsListProvider = StateNotifierProvider.autoDispose<RetraitsListNotifier, RetraitsListState>(
  (ref) => RetraitsListNotifier(ref.watch(retraitsRemoteDataSourceProvider)),
);
