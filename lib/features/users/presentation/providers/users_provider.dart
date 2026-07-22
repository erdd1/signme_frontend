import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/users_remote_datasource.dart';
import '../../domain/entities/user_stats_entity.dart';
import 'users_data_providers.dart';

// ── Liste paginée ───────────────────────────────────────────────────────────

class UsersListState {
  const UsersListState({
    this.users = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
    this.searchQuery = '',
  });

  final List<UserEntity> users;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;
  final String searchQuery;

  UsersListState copyWith({
    List<UserEntity>? users,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
    String? searchQuery,
    bool clearError = false,
  }) =>
      UsersListState(
        users: users ?? this.users,
        isLoading: isLoading ?? this.isLoading,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        error: clearError ? null : error ?? this.error,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  List<UserEntity> get filtered {
    if (searchQuery.isEmpty) return users;
    final q = searchQuery.toLowerCase();
    return users
        .where(
          (u) =>
              u.nom.toLowerCase().contains(q) ||
              u.email.toLowerCase().contains(q) ||
              (u.telephone?.toLowerCase().contains(q) ?? false),
        )
        .toList();
  }
}

class UsersListNotifier extends StateNotifier<UsersListState> {
  UsersListNotifier(this._remote) : super(const UsersListState()) {
    load();
  }

  final UsersRemoteDataSource _remote;

  Map<String, dynamic>? get _searchFilter {
    final q = state.searchQuery.trim();
    if (q.isEmpty) return null;
    return {'search': q};
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _remote.list(page: 1, filters: _searchFilter);
      state = state.copyWith(
        users: items,
        isLoading: false,
        page: 1,
        hasMore: items.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: messageFromError(e));
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final items =
          await _remote.list(page: state.page + 1, filters: _searchFilter);
      state = state.copyWith(
        users: [...state.users, ...items],
        isLoading: false,
        page: state.page + 1,
        hasMore: items.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: messageFromError(e));
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
    load();
  }

  Future<void> refresh() => load();

  void prependUser(UserEntity user) {
    state = state.copyWith(users: [user, ...state.users]);
  }

  void replaceUser(UserEntity user) {
    state = state.copyWith(
      users: [
        for (final u in state.users)
          if (u.id == user.id) user else u,
      ],
    );
  }
}

final usersListProvider =
    StateNotifierProvider<UsersListNotifier, UsersListState>((ref) {
  return UsersListNotifier(ref.watch(usersRemoteDataSourceProvider));
});

// ── Détail ──────────────────────────────────────────────────────────────────

final userDetailProvider = FutureProvider.family<UserEntity, int>((ref, id) async {
  final model = await ref.watch(usersRemoteDataSourceProvider).getById(id);
  return model;
});

// ── Tableau de bord "Gérer utilisateurs" ──────────────────────────────────

final userStatsProvider = FutureProvider.autoDispose<UserStatsEntity>((ref) {
  return ref.watch(usersRemoteDataSourceProvider).stats();
});

/// Liste filtrée pour un filtre du tableau de bord (mois de naissance,
/// quartier, groupe, région d'origine) — indépendante de [usersListProvider]
/// qui alimente l'écran "Membres" avec sa propre pagination/recherche.
final userFilteredListProvider = FutureProvider.autoDispose
    .family<List<UserEntity>, Map<String, dynamic>>((ref, filters) async {
  return ref.watch(usersRemoteDataSourceProvider).list(filters: filters);
});

// ── Actions (création / mise à jour / statut) ─────────────────────────────

class UsersActionsNotifier extends StateNotifier<AsyncValue<void>> {
  UsersActionsNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<UserEntity> create(Map<String, dynamic> payload) async {
    state = const AsyncLoading();
    try {
      final user =
          await _ref.read(usersRemoteDataSourceProvider).create(payload);
      _ref.read(usersListProvider.notifier).prependUser(user);
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserEntity> update(int id, Map<String, dynamic> payload) async {
    state = const AsyncLoading();
    try {
      final user =
          await _ref.read(usersRemoteDataSourceProvider).update(id, payload);
      _ref.read(usersListProvider.notifier).replaceUser(user);
      _ref.invalidate(userDetailProvider(id));
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<UserEntity> uploadPhoto({
    required int userId,
    required File photoFile,
  }) async {
    state = const AsyncLoading();
    try {
      final newPhotoUrl = await _ref
          .read(usersRemoteDataSourceProvider)
          .uploadPhoto(userId: userId, photoFile: photoFile);

      final current = _ref.read(authNotifierProvider).auth?.user;
      if (current != null && current.id == userId) {
        final patched = _userWithPhotoUrl(current, newPhotoUrl);
        await _ref.read(authNotifierProvider.notifier).updateUserData(patched);
        // Synchronise aussi le cache local même si GET /users/{id} échoue.
        await _ref.read(authNotifierProvider.notifier).refreshProfile();
      }

      UserEntity user;
      try {
        user = await _ref.read(usersRemoteDataSourceProvider).getById(userId);
        if (current != null && current.id == userId) {
          await _ref
              .read(authNotifierProvider.notifier)
              .updateUserData(UserModel.fromEntity(user));
        }
      } catch (_) {
        user = current != null && current.id == userId
            ? _userWithPhotoUrl(current, newPhotoUrl)
            : UserEntity(
                id: userId,
                nom: '',
                email: '',
                role: 'paroissien',
                photoUrl: newPhotoUrl,
              );
      }

      _ref.read(usersListProvider.notifier).replaceUser(user);
      _ref.invalidate(userDetailProvider(userId));
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  UserModel _userWithPhotoUrl(UserEntity user, String photoUrl) {
    final base = UserModel.fromEntity(user);
    return UserModel(
      id: base.id,
      nom: base.nom,
      email: base.email,
      role: base.role,
      churchId: base.churchId,
      churchNom: base.churchNom,
      photoUrl: photoUrl,
      telephone: base.telephone,
      actif: base.actif,
      estDeService: base.estDeService,
      profession: base.profession,
      originaireDe: base.originaireDe,
      dateConfirmation: base.dateConfirmation,
      lieuConfirmation: base.lieuConfirmation,
      sexe: base.sexe,
      dateNaissance: base.dateNaissance,
      quartier: base.quartier,
      ville: base.ville,
      groupePrincipal: base.groupePrincipal,
      groupes: base.groupes,
    );
  }

  Future<UserEntity> toggleStatus(int id) async {
    state = const AsyncLoading();
    try {
      final user =
          await _ref.read(usersRemoteDataSourceProvider).toggleStatus(id);
      _ref.read(usersListProvider.notifier).replaceUser(user);
      _ref.invalidate(userDetailProvider(id));
      state = const AsyncData(null);
      return user;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final usersActionsProvider =
    StateNotifierProvider<UsersActionsNotifier, AsyncValue<void>>(
  (ref) => UsersActionsNotifier(ref),
);
