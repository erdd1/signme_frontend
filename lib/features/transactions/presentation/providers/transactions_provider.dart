import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/transactions_remote_datasource.dart';
import '../../domain/entities/transaction_entity.dart';

final transactionsRemoteDataSourceProvider = Provider<TransactionsRemoteDataSource>((ref) {
  return TransactionsRemoteDataSource(ref.watch(dioProvider));
});

/// Nombre de transactions affichées dans l'aperçu de l'écran Services.
const int recentTransactionsCount = 5;

/// Les dernières transactions, pour l'aperçu de l'écran Services.
/// À invalider après un paiement pour rafraîchir l'aperçu.
final recentTransactionsProvider = FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
  final page = await ref
      .watch(transactionsRemoteDataSourceProvider)
      .list(perPage: recentTransactionsCount);
  return page.items;
});

/// Filtres et recherche de l'historique complet.
class TransactionsFilters {
  const TransactionsFilters({this.query = '', this.statut, this.type});

  final String query;
  final TransactionStatus? statut;
  final TransactionType? type;

  bool get hasFilter => statut != null || type != null;

  TransactionsFilters copyWith({
    String? query,
    TransactionStatus? statut,
    TransactionType? type,
    bool clearStatut = false,
    bool clearType = false,
  }) =>
      TransactionsFilters(
        query: query ?? this.query,
        statut: clearStatut ? null : statut ?? this.statut,
        type: clearType ? null : type ?? this.type,
      );
}

class TransactionsHistoryState {
  const TransactionsHistoryState({
    this.filters = const TransactionsFilters(),
    this.items = const [],
    this.page = 0,
    this.hasMore = false,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.error,
  });

  final TransactionsFilters filters;
  final List<TransactionEntity> items;
  final int page;
  final bool hasMore;

  /// Premier chargement (ou nouvelle recherche) en cours.
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  TransactionsHistoryState copyWith({
    TransactionsFilters? filters,
    List<TransactionEntity>? items,
    int? page,
    bool? hasMore,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
  }) =>
      TransactionsHistoryState(
        filters: filters ?? this.filters,
        items: items ?? this.items,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        error: clearError ? null : error ?? this.error,
      );
}

/// Historique complet : recherche, filtres et pagination infinie.
class TransactionsHistoryNotifier extends StateNotifier<TransactionsHistoryState> {
  TransactionsHistoryNotifier(this._remote) : super(const TransactionsHistoryState()) {
    _load();
  }

  static const int pageSize = 20;
  static const Duration _debounce = Duration(milliseconds: 400);

  final TransactionsRemoteDataSource _remote;
  Timer? _timer;
  CancelToken? _cancel;

  /// Identifie la requête en cours : une réponse arrivée après un changement
  /// de filtre est ignorée.
  int _generation = 0;

  void setQuery(String value) {
    final query = value.trim();
    if (query == state.filters.query) return;

    state = state.copyWith(filters: state.filters.copyWith(query: query), isLoading: true, clearError: true);
    _timer?.cancel();
    _timer = Timer(_debounce, _load);
  }

  void setStatut(TransactionStatus? statut) => _applyFilters(
        statut == null
            ? state.filters.copyWith(clearStatut: true)
            : state.filters.copyWith(statut: statut),
      );

  void setType(TransactionType? type) => _applyFilters(
        type == null ? state.filters.copyWith(clearType: true) : state.filters.copyWith(type: type),
      );

  void clearFilters() => _applyFilters(
        state.filters.copyWith(clearStatut: true, clearType: true),
      );

  Future<void> refresh() => _load();

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading || state.isLoadingMore) return;

    final generation = _generation;
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await _fetch(state.page + 1);
      if (generation != _generation || !mounted) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        page: page.currentPage,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );
    } catch (e) {
      if (generation != _generation || !mounted) return;
      state = state.copyWith(isLoadingMore: false, error: messageFromError(e));
    }
  }

  void _applyFilters(TransactionsFilters filters) {
    _timer?.cancel();
    state = state.copyWith(filters: filters, isLoading: true, clearError: true);
    _load();
  }

  Future<void> _load() async {
    _timer?.cancel();
    _cancel?.cancel();
    final generation = ++_generation;
    state = state.copyWith(isLoading: true, isLoadingMore: false, clearError: true);

    try {
      final page = await _fetch(1);
      if (generation != _generation || !mounted) return;
      state = state.copyWith(
        items: page.items,
        page: page.currentPage,
        hasMore: page.hasMore,
        isLoading: false,
      );
    } catch (e) {
      if (generation != _generation || !mounted) return;
      state = state.copyWith(items: const [], isLoading: false, error: messageFromError(e));
    }
  }

  Future<TransactionsPage> _fetch(int page) {
    final token = CancelToken();
    _cancel = token;

    return _remote.list(
      page: page,
      perPage: pageSize,
      query: state.filters.query,
      statut: state.filters.statut?.name,
      type: state.filters.type?.name,
      cancelToken: token,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _cancel?.cancel();
    super.dispose();
  }
}

/// autoDispose : l'historique repart de zéro à chaque ouverture.
final transactionsHistoryProvider =
    StateNotifierProvider.autoDispose<TransactionsHistoryNotifier, TransactionsHistoryState>(
  (ref) => TransactionsHistoryNotifier(ref.watch(transactionsRemoteDataSourceProvider)),
);
