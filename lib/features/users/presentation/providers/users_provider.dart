import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/user_entity.dart';

// ── Data Source ────────────────────────────────────────────────────────────
class UsersDataSource {
  UsersDataSource(this.dio);
  final Dio dio;

  /// Récupère la liste des utilisateurs de l'église
  /// Pour pasteur/secrétaire : membres de leur église
  /// Pour autres : leur propre profil + collègues visibles
  Future<List<UserEntity>> getUsers({int page = 1, Map<String, dynamic>? filters}) async {
    try {
      final params = {
        'page': page,
        'per_page': 50,
        ...?filters,
      };
      final resp = await dio.get(ApiConfig.users, queryParameters: params);
      print('DEBUG: /users response status = ${resp.statusCode}');
      print('DEBUG: /users response data = ${resp.data}');
      
      if (resp.statusCode == 200) {
        // Structure de la réponse:
        // {
        //   "success": true,
        //   "message": "...",
        //   "data": [...],  // Array d'utilisateurs
        //   "pagination": {...}
        // }
        final List<dynamic> items = resp.data['data'] as List? ?? [];
        print('DEBUG: Parsed ${items.length} users');
        return items.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Erreur HTTP ${resp.statusCode}');
    } catch (e) {
      print('DEBUG: Error fetching users: $e');
      throw Exception('Impossible de charger les utilisateurs: $e');
    }
  }

  /// Récupère les détails d'un utilisateur spécifique
  Future<UserEntity> getUser(int id) async {
    try {
      final resp = await dio.get('${ApiConfig.users}/$id');
      if (resp.statusCode == 200) {
        return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Utilisateur non trouvé');
    } catch (e) {
      throw Exception('Impossible de charger l\'utilisateur: $e');
    }
  }

  /// Met à jour le profil de l'utilisateur
  Future<UserEntity> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final resp = await dio.put('${ApiConfig.users}/$id', data: data);
      if (resp.statusCode == 200) {
        return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour');
    } catch (e) {
      throw Exception('Impossible de mettre à jour l\'utilisateur: $e');
    }
  }

  /// Upload la photo de profil
  Future<String> uploadPhoto(int id, String filePath) async {
    try {
      final file = await MultipartFile.fromFile(
        filePath,
        filename: 'profile_photo.jpg',
      );
      final formData = FormData.fromMap({
        'photo': file,
      });
      
      final resp = await dio.post('${ApiConfig.users}/$id/photo', data: formData);
      if (resp.statusCode == 200) {
        return resp.data['data']?['photoUrl']?.toString() ?? '';
      }
      throw Exception('Erreur lors du upload');
    } catch (e) {
      throw Exception('Impossible d\'uploader la photo: $e');
    }
  }

  /// Crée un nouvel utilisateur (pasteur/secrétaire uniquement)
  Future<UserEntity> createUser(Map<String, dynamic> data) async {
    try {
      final resp = await dio.post(ApiConfig.users, data: data);
      if (resp.statusCode == 201) {
        return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la création: ${resp.statusCode}');
    } catch (e) {
      throw Exception('Impossible de créer l\'utilisateur: $e');
    }
  }

  /// Désactive/Réactive un compte utilisateur
  Future<UserEntity> toggleStatus(int id) async {
    try {
      final resp = await dio.patch('${ApiConfig.users}/$id/toggle-status');
      if (resp.statusCode == 200) {
        return UserModel.fromJson(resp.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Erreur lors de la mise à jour du statut');
    } catch (e) {
      throw Exception('Impossible de changer le statut: $e');
    }
  }
}

final usersDataSourceProvider = Provider<UsersDataSource>((ref) {
  return UsersDataSource(ref.watch(dioProvider));
});

// ── Users List State ──────────────────────────────────────────────────────
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
        .where((u) =>
            u.nom.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.role.toLowerCase().contains(q))
        .toList();
  }
}

// ── Users Notifier ────────────────────────────────────────────────────────
class UsersListNotifier extends StateNotifier<UsersListState> {
  UsersListNotifier(this._ds) : super(const UsersListState()) {
    load();
  }

  final UsersDataSource _ds;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final items = await _ds.getUsers(page: 1);
      state = state.copyWith(
        users: items,
        isLoading: false,
        page: 1,
        hasMore: items.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(isLoading: true);
    try {
      final items = await _ds.getUsers(page: state.page + 1);
      state = state.copyWith(
        users: [...state.users, ...items],
        isLoading: false,
        page: state.page + 1,
        hasMore: items.length >= 50,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void search(String query) =>
      state = state.copyWith(searchQuery: query);

  Future<void> refresh() => load();

  /// Crée un nouvel utilisateur et le rajoute à la liste
  Future<bool> createUser(Map<String, dynamic> data) async {
    try {
      final newUser = await _ds.createUser(data);
      // Ajouter l'utilisateur au début de la liste
      state = state.copyWith(
        users: [newUser, ...state.users],
        searchQuery: '',
      );
      return true;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

final usersListProvider =
    StateNotifierProvider<UsersListNotifier, UsersListState>((ref) {
  return UsersListNotifier(ref.watch(usersDataSourceProvider));
});

// ── User Detail State ─────────────────────────────────────────────────────
class UserDetailState {
  const UserDetailState({
    this.user,
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingPhoto = false,
    this.isToggling = false,
    this.error,
    this.success,
  });

  final UserEntity? user;
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingPhoto;
  final bool isToggling;
  final String? error;
  final String? success;

  UserDetailState copyWith({
    UserEntity? user,
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingPhoto,
    bool? isToggling,
    String? error,
    String? success,
    bool clearError = false,
    bool clearSuccess = false,
  }) =>
      UserDetailState(
        user: user ?? this.user,
        isLoading: isLoading ?? this.isLoading,
        isUpdating: isUpdating ?? this.isUpdating,
        isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
        isToggling: isToggling ?? this.isToggling,
        error: clearError ? null : error ?? this.error,
        success: clearSuccess ? null : success ?? this.success,
      );
}

// ── User Detail Notifier ──────────────────────────────────────────────────
class UserDetailNotifier extends StateNotifier<UserDetailState> {
  UserDetailNotifier(this._ds) : super(const UserDetailState());

  final UsersDataSource _ds;

  Future<void> loadUser(int id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final user = await _ds.getUser(id);
      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> updateUser(int id, Map<String, dynamic> data) async {
    state = state.copyWith(isUpdating: true, clearError: true, clearSuccess: true);
    try {
      final user = await _ds.updateUser(id, data);
      state = state.copyWith(
        user: user,
        isUpdating: false,
        success: 'Profil mis à jour avec succès',
        clearSuccess: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isUpdating: false, error: e.toString());
      return false;
    }
  }

  Future<bool> uploadPhoto(int id, String filePath) async {
    state = state.copyWith(isUploadingPhoto: true, clearError: true);
    try {
      final photoUrl = await _ds.uploadPhoto(id, filePath);
      // Mettre à jour l'objet user localement
      if (state.user != null) {
        final updatedUser = UserModel(
          id: state.user!.id,
          nom: state.user!.nom,
          email: state.user!.email,
          role: state.user!.role,
          churchId: state.user!.churchId,
          churchNom: state.user!.churchNom,
          photoUrl: photoUrl,
          telephone: state.user!.telephone,
          actif: state.user!.actif,
          estDeService: state.user!.estDeService,
          groupe: state.user!.groupe,
          profession: state.user!.profession,
          originaireDe: state.user!.originaireDe,
        );
        state = state.copyWith(
          user: updatedUser,
          isUploadingPhoto: false,
          success: 'Photo uploadée avec succès',
        );
      }
      return true;
    } catch (e) {
      state = state.copyWith(isUploadingPhoto: false, error: e.toString());
      return false;
    }
  }

  /// Désactive ou réactive un compte utilisateur
  Future<bool> toggleStatus(int id) async {
    state = state.copyWith(isToggling: true, clearError: true, clearSuccess: true);
    try {
      final updatedUser = await _ds.toggleStatus(id);
      state = state.copyWith(
        user: updatedUser,
        isToggling: false,
        success: updatedUser.actif 
            ? 'Compte activé avec succès' 
            : 'Compte désactivé avec succès',
        clearSuccess: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isToggling: false, error: e.toString());
      return false;
    }
  }

  void clearMessages() =>
      state = state.copyWith(clearError: true, clearSuccess: true);
}

// ── Providers ─────────────────────────────────────────────────────────────
final userDetailProvider = StateNotifierProvider<UserDetailNotifier, UserDetailState>((ref) {
  return UserDetailNotifier(ref.watch(usersDataSourceProvider));
});

// ── Alias pour backward compatibility ─────────────────────────────────────
@Deprecated('Utilisez usersListProvider à la place')
final usersProvider = usersListProvider;
