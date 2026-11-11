import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/groupes_remote_datasource.dart';
import '../../domain/entities/groupe_entities.dart';

final mesGroupesRemoteDataSourceProvider = Provider<MesGroupesRemoteDataSource>(
  (ref) => MesGroupesRemoteDataSource(ref.watch(dioProvider)),
);

/// Groupes de l'utilisateur connecté (avec son poste dans chacun).
final mesGroupesProvider = FutureProvider.autoDispose<List<GroupeEntity>>(
  (ref) => ref.watch(mesGroupesRemoteDataSourceProvider).mesGroupes(),
);

/// Un groupe avec sa caisse et ses responsables.
final groupeProvider = FutureProvider.autoDispose.family<GroupeEntity, String>(
  (ref, uuid) => ref.watch(mesGroupesRemoteDataSourceProvider).groupe(uuid),
);

final communiquesProvider = FutureProvider.autoDispose.family<List<CommuniqueEntity>, String>(
  (ref, uuid) => ref.watch(mesGroupesRemoteDataSourceProvider).communiques(uuid),
);

/// Qui a contribué à un communiqué : clé = (groupeUuid, communiqueUuid).
final contributeursProvider =
    FutureProvider.autoDispose.family<List<ContributeurEntity>, (String, String)>(
  (ref, key) => ref.watch(mesGroupesRemoteDataSourceProvider).contributeurs(key.$1, key.$2),
);

/// Compte de retrait de l'utilisateur (réservé président/trésorier).
final groupeBeneficiaireProvider = FutureProvider.autoDispose.family(
  (ref, String uuid) => ref.watch(mesGroupesRemoteDataSourceProvider).beneficiaire(uuid),
);

/// Recharge tout ce qui dépend d'un groupe (après une contribution, un
/// retrait, un communiqué…).
void refreshGroupe(WidgetRef ref, String uuid) {
  ref.invalidate(groupeProvider(uuid));
  ref.invalidate(communiquesProvider(uuid));
  ref.invalidate(mouvementsProvider(uuid));
  ref.invalidate(mesGroupesProvider);
}

// ── Historique de la caisse (pagination) ─────────────────────────────────────

class MouvementsState {
  const MouvementsState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = false,
    this.page = 0,
    this.error,
  });

  final List<MouvementEntity> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final int page;
  final String? error;

  MouvementsState copyWith({
    List<MouvementEntity>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    int? page,
    String? error,
    bool clearError = false,
  }) =>
      MouvementsState(
        items: items ?? this.items,
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        error: clearError ? null : error ?? this.error,
      );
}

class MouvementsNotifier extends StateNotifier<MouvementsState> {
  MouvementsNotifier(this._remote, this._uuid) : super(const MouvementsState(isLoading: true)) {
    refresh();
  }

  final MesGroupesRemoteDataSource _remote;
  final String _uuid;

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _remote.mouvements(_uuid);
      if (!mounted) return;
      state = MouvementsState(items: page.items, hasMore: page.hasMore, page: page.currentPage);
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(isLoading: false, error: messageFromError(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final page = await _remote.mouvements(_uuid, page: state.page + 1);
      if (!mounted) return;
      state = state.copyWith(
        items: [...state.items, ...page.items],
        hasMore: page.hasMore,
        page: page.currentPage,
        isLoadingMore: false,
      );
    } catch (_) {
      if (mounted) state = state.copyWith(isLoadingMore: false);
    }
  }
}

final mouvementsProvider = StateNotifierProvider.autoDispose.family<MouvementsNotifier, MouvementsState, String>(
  (ref, uuid) => MouvementsNotifier(ref.watch(mesGroupesRemoteDataSourceProvider), uuid),
);
