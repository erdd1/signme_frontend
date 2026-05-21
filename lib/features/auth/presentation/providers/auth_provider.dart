import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart'; // Ajout pour la stabilité du state
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Providers infrastructure ───────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return buildDioClient(storage);
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio:     ref.watch(dioProvider),
    storage: ref.watch(secureStorageProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    storage:          ref.watch(secureStorageProvider),
  );
});

// ── Auth State ─────────────────────────────────────────────────────────────
class AuthState extends Equatable { // Ajout de Equatable
  const AuthState({
    this.auth,
    this.isLoading   = false,
    this.failure,
    this.isInitialized = false,
  });

  final AuthEntity? auth;
  final bool        isLoading;
  final Failure?    failure;
  final bool        isInitialized;

  // L'utilisateur est authentifié si l'objet auth existe et est valide
  bool get isAuthenticated => auth != null;

  @override
  List<Object?> get props => [auth, isLoading, failure, isInitialized];

  AuthState copyWith({
    AuthEntity? auth,
    bool?       isLoading,
    Failure?    failure,
    bool?       isInitialized,
    bool        clearFailure = false,
    bool        clearAuth    = false,
  }) {
    return AuthState(
      auth:          clearAuth    ? null    : auth          ?? this.auth,
      isLoading:     isLoading    ?? this.isLoading,
      failure:       clearFailure ? null    : failure       ?? this.failure,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// ── Auth Notifier ──────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    _init();
  }

  final AuthRepository _repository;

  Future<void> _init() async {
    final result = await _repository.restoreSession();
    result.fold(
          (failure) => state = state.copyWith(isInitialized: true),
          (auth)    => state = state.copyWith(auth: auth, isInitialized: true),
    );
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.login(
      email:      email,
      password:   password,
      rememberMe: rememberMe,
    );
    return result.fold(
          (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
          (auth) {
        state = state.copyWith(isLoading: false, auth: auth);
        return true;
      },
    );
  }

  Future<void> logout() async {
    // 1. On passe en chargement pour bloquer l'UI si nécessaire
    state = state.copyWith(isLoading: true);

    try {
      // 2. On appelle le repository pour nettoyer le serveur et le stockage
      await _repository.logout();
    } catch (_) {
      // Les erreurs de logout (ex: token déjà expiré) ne doivent pas bloquer l'UX
    } finally {
      // 3. On réinitialise l'état local.
      // Comme auth devient null, isAuthenticated passe à false,
      // et le GoRouter (qui écoute ce notifier) redirigera vers /login.
      state = const AuthState(isInitialized: true, auth: null);
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.forgotPassword(email: email);
    result.fold(
          (failure) => state = state.copyWith(isLoading: false, failure: failure),
          (_)       => state = state.copyWith(isLoading: false),
    );
  }

  void clearFailure() => state = state.copyWith(clearFailure: true);
}

// ── Providers ─────────────────────────────────────────────────────────────
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

/// Raccourci pour accéder au user courant
final currentUserProvider = Provider<AuthEntity?>((ref) {
  return ref.watch(authNotifierProvider).auth;
});