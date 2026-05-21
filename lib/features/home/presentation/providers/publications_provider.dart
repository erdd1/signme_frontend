import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/publication_model.dart';
import '../../domain/entities/publication_entity.dart';

// ── Remote DataSource ─────────────────────────────────────────────────────
final publicationsRemoteProvider = Provider<_PublicationDataSource>((ref) {
  return _PublicationDataSource(ref.watch(dioProvider));
});

class _PublicationDataSource {
  _PublicationDataSource(this.dio);
  final Dio dio;

  Future<List<PublicationModel>> getPublications({int page = 1}) async {
    final response = await dio.get(
      ApiConfig.publications,
      queryParameters: {'page': page, 'per_page': 20},
    );
    if (response.statusCode == 200) {
      final List<dynamic> items =
          response.data['data'] is List
              ? response.data['data'] as List
              : (response.data['data']?['data'] as List? ?? []);
      return items
          .map((e) => PublicationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return [];
  }
}

// ── Publications State ────────────────────────────────────────────────────
class PublicationsState {
  const PublicationsState({
    this.publications = const [],
    this.isLoading    = false,
    this.hasMore      = true,
    this.page         = 1,
    this.error,
  });

  final List<PublicationEntity> publications;
  final bool   isLoading;
  final bool   hasMore;
  final int    page;
  final String? error;

  PublicationsState copyWith({
    List<PublicationEntity>? publications,
    bool?   isLoading,
    bool?   hasMore,
    int?    page,
    String? error,
    bool    clearError = false,
  }) =>
      PublicationsState(
        publications: publications ?? this.publications,
        isLoading:    isLoading    ?? this.isLoading,
        hasMore:      hasMore      ?? this.hasMore,
        page:         page         ?? this.page,
        error:        clearError ? null : error ?? this.error,
      );
}

class PublicationsNotifier extends StateNotifier<PublicationsState> {
  PublicationsNotifier(this._ds) : super(const PublicationsState()) {
    load();
  }

  final _PublicationDataSource _ds;

  Future<void> load() async {
    if (state.isLoading) return;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _ds.getPublications(page: 1);
      state = state.copyWith(
        publications: items,
        isLoading:    false,
        page:         1,
        hasMore:      items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final items = await _ds.getPublications(page: state.page + 1);
      state = state.copyWith(
        publications: [...state.publications, ...items],
        isLoading:    false,
        page:         state.page + 1,
        hasMore:      items.length >= 20,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() => load();
}

final publicationsProvider =
    StateNotifierProvider<PublicationsNotifier, PublicationsState>((ref) {
  return PublicationsNotifier(ref.watch(publicationsRemoteProvider));
});
