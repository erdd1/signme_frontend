import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart'; // Ajout pour la stabilité du state
import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/network/auth_session_listener.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/datasources/google_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/models/user_model.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

// ── Providers infrastructure ───────────────────────────────────────────────
final secureStorageProvider = Provider<SecureStorage>((ref) => SecureStorage());

/// Évite la circularité dioProvider ↔ authNotifierProvider.
final authSessionListenerProvider = Provider<AuthSessionListener>(
  (ref) => AuthSessionListener(),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final listener = ref.watch(authSessionListenerProvider);
  return buildDioClient(
    storage,
    onSessionExpired: () async {
      final handler = listener.onExpired;
      if (handler != null) await handler();
    },
  );
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

final googleAuthDataSourceProvider = Provider<GoogleAuthDataSource>(
  (ref) => GoogleAuthDataSource(),
);

// ── Auth State ─────────────────────────────────────────────────────────────
class AuthState extends Equatable {
  const AuthState({
    this.auth,
    this.isLoading = false,
    this.failure,
    this.isInitialized = false,
    this.sessionExpiredNotice = false,
  });

  final AuthEntity? auth;
  final bool isLoading;
  final Failure? failure;
  final bool isInitialized;
  final bool sessionExpiredNotice;

  bool get isAuthenticated => auth != null;

  @override
  List<Object?> get props =>
      [auth, isLoading, failure, isInitialized, sessionExpiredNotice];

  AuthState copyWith({
    AuthEntity? auth,
    bool? isLoading,
    Failure? failure,
    bool? isInitialized,
    bool? sessionExpiredNotice,
    bool clearFailure = false,
    bool clearAuth = false,
    bool clearSessionExpiredNotice = false,
  }) {
    return AuthState(
      auth: clearAuth ? null : auth ?? this.auth,
      isLoading: isLoading ?? this.isLoading,
      failure: clearFailure ? null : failure ?? this.failure,
      isInitialized: isInitialized ?? this.isInitialized,
      sessionExpiredNotice: clearSessionExpiredNotice
          ? false
          : sessionExpiredNotice ?? this.sessionExpiredNotice,
    );
  }
}

/// Email mémorisé pour préremplir le login.
final rememberedEmailProvider = FutureProvider<String?>((ref) async {
  final remember = await ref.watch(secureStorageProvider).getRememberMe();
  if (!remember) return null;
  return ref.watch(secureStorageProvider).getRememberedEmail();
});

// ── Auth Notifier ──────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(
    this._repository,
    this._storage,
    this._connectivity,
    this._googleAuth,
  ) : super(const AuthState()) {
    _init();
  }

  final AuthRepository _repository;
  final SecureStorage  _storage;
  final ConnectivityService _connectivity;
  final GoogleAuthDataSource _googleAuth;

  Future<void> _init() async {
    final result = await _repository.restoreSession();
    await result.fold(
      (failure) async {
        state = state.copyWith(isInitialized: true);
      },
      (auth) async {
        if (auth != null) await _guardCacheForUser(auth.user.id);
        state = state.copyWith(auth: auth, isInitialized: true);
        if (auth != null) await refreshProfile();
      },
    );
  }

  /// Vide le cache Isar si l'utilisateur qui s'authentifie n'est PAS celui
  /// dont les données sont actuellement en cache sur cet appareil — sinon
  /// les données d'un compte précédent (potentiellement d'une AUTRE église)
  /// restent visibles jusqu'au premier rafraîchissement réseau de chaque
  /// écran, ce qui est visible et grave dans une app multi-églises. Couvre
  /// aussi le cas d'un logout jamais réellement exécuté (app tuée/crashée).
  Future<void> _guardCacheForUser(int userId) async {
    try {
      final lastId = await _storage.getLastCachedUserId();
      if (lastId != null && lastId != userId) {
        await IsarService.clearAll();
      }
      await _storage.setLastCachedUserId(userId);
    } catch (e) {
      AppLogger.error('Échec de la vérification du cache multi-comptes', e);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    // Le bouton "Se connecter" se désactive via `isLoading`, mais seulement
    // au prochain frame — un double-tap très rapide peut encore atteindre
    // ce callback avant ce rendu. Garde de ré-entrance ici, à la source :
    // deux requêtes de connexion simultanées peuvent déclencher un blocage
    // par rate-limiting que l'utilisateur n'a lui-même pas vraiment demandé.
    if (state.isLoading) return false;

    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearSessionExpiredNotice: true,
    );
    final result = await _repository.login(
      email:      email,
      password:   password,
      rememberMe: rememberMe,
    );
    return await result.fold<Future<bool>>(
      (failure) async {
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
      (auth) async {
        await _guardCacheForUser(auth.user.id);
        state = state.copyWith(isLoading: false, auth: auth);
        await refreshProfile();
        return true;
      },
    );
  }

  /// Connexion via Google Sign-In. Retourne `false` sans poser d'erreur
  /// visible si l'utilisateur annule simplement la sélection de compte.
  Future<bool> loginWithGoogle() async {
    // Même garde de ré-entrance que login() ci-dessus.
    if (state.isLoading) return false;

    state = state.copyWith(
      isLoading: true,
      clearFailure: true,
      clearSessionExpiredNotice: true,
    );

    String? idToken;
    try {
      idToken = await _googleAuth.signInAndGetIdToken();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        failure: UnknownFailure(message: messageFromError(e)),
      );
      return false;
    }

    if (idToken == null) {
      // Annulé par l'utilisateur : pas une erreur, on referme juste le loader.
      state = state.copyWith(isLoading: false);
      return false;
    }

    final result = await _repository.loginWithGoogle(idToken: idToken);
    return await result.fold<Future<bool>>(
      (failure) async {
        // Déconnecter la session Google locale : sinon Google renvoie le
        // même compte en cache sans jamais réafficher le sélecteur, et
        // l'utilisateur reste bloqué sur le même compte refusé.
        try {
          await _googleAuth.signOut();
        } catch (_) {}
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
      (auth) async {
        await _guardCacheForUser(auth.user.id);
        state = state.copyWith(isLoading: false, auth: auth);
        await refreshProfile();
        return true;
      },
    );
  }

  /// Session expirée (refresh échoué) — aligne l'état UI avec le stockage.
  Future<void> onSessionExpired() async {
    await _storage.clearSession();
    state = const AuthState(
      isInitialized: true,
      sessionExpiredNotice: true,
    );
  }

  void clearSessionExpiredNotice() {
    state = state.copyWith(clearSessionExpiredNotice: true);
  }

  /// Recharge le profil depuis `GET /auth/me` (téléphone, profession, etc.).
  Future<void> refreshProfile() async {
    if (state.auth == null) return;
    final result = await _repository.getMe();
    result.fold(
      (_) {},
      (user) => updateUserData(user),
    );
  }

  /// Déconnecte l'utilisateur. Retourne `false` sans rien faire si l'appareil
  /// est hors ligne : se déconnecter sans réseau empêcherait toute
  /// réinvalidation côté serveur et ferait perdre l'accès au cache local
  /// Offline-First sans pouvoir se reconnecter pour le récupérer.
  Future<bool> logout() async {
    final isOnline = await _connectivity.isOnline;
    if (!isOnline) {
      state = state.copyWith(
        isLoading: false,
        failure: const NetworkFailure(
          message: 'Connexion Internet requise pour se déconnecter.',
        ),
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearFailure: true);

    try {
      await _repository.logout();
    } catch (_) {
      // Les erreurs de logout (ex: token déjà expiré) ne doivent pas bloquer l'UX
    } finally {
      // Déconnecter aussi la session Google locale (permet de changer de
      // compte au prochain "Continuer avec Google").
      try {
        await _googleAuth.signOut();
      } catch (_) {}
      // Nettoyer le cache Isar local (Offline-First) — jamais laisser un
      // échec d'écriture locale (disque plein, corruption) bloquer la
      // déconnexion : l'utilisateur doit toujours pouvoir se déconnecter.
      try {
        await IsarService.clearAll();
      } catch (e) {
        AppLogger.error('Échec du nettoyage du cache local à la déconnexion', e);
      }
      // Réinitialiser l'état → GoRouter redirige vers /login
      state = const AuthState(isInitialized: true, auth: null);
    }
    return true;
  }

  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.forgotPassword(email: email);
    result.fold(
          (failure) => state = state.copyWith(isLoading: false, failure: failure),
          (_)       => state = state.copyWith(isLoading: false),
    );
  }

  /// Vérifie le code OTP et retourne le reset_token
  Future<Map<String, dynamic>?> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.verifyPasswordResetOTP(email: email, otp: otp);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return null;
      },
      (data) {
        state = state.copyWith(isLoading: false);
        return data;
      },
    );
  }

  /// Renvoie le code OTP avec gestion escalade délais
  Future<Map<String, dynamic>?> resendPasswordResetOTP({
    required String email,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.resendPasswordResetOTP(email: email);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return null;
      },
      (data) {
        state = state.copyWith(isLoading: false);
        return data;
      },
    );
  }

  /// Confirme la réinitialisation après vérification OTP
  Future<bool> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.confirmPasswordReset(
      resetToken: resetToken,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    state = state.copyWith(isLoading: true, clearFailure: true);
    final result = await _repository.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: passwordConfirmation,
    );
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, failure: failure);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  /// Mettre à jour les données de l'utilisateur courant (sans logout/splash)
  /// Crée un nouvel AuthEntity avec l'utilisateur mis à jour mais conserve les tokens
  /// Persiste automatiquement dans SecureStorage
  Future<void> updateUserData(UserEntity updatedUser) async {
    if (state.auth == null) return;

    // 1. Créer un nouvel AuthEntity avec le nouvel utilisateur mais les tokens existants
    final newAuth = AuthEntity(
      user: updatedUser,
      accessToken: state.auth!.accessToken,
      refreshToken: state.auth!.refreshToken,
      isAuthenticated: state.auth!.isAuthenticated,
    );

    // 2. Mettre à jour l'état en mémoire
    state = state.copyWith(auth: newAuth);

    // 3. Persister dans SecureStorage pour survie après recompilation
    try {
      final userModel = UserModel.fromEntity(updatedUser);
      await _storage.saveUser(jsonEncode(userModel.toJson()));
    } catch (e) {
      AppLogger.error('Erreur sauvegarde utilisateur local', e);
    }
  }

  void clearFailure() => state = state.copyWith(clearFailure: true);
}

// ── Providers ─────────────────────────────────────────────────────────────
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final notifier = AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
    ref.watch(connectivityServiceProvider),
    ref.watch(googleAuthDataSourceProvider),
  );
  ref.read(authSessionListenerProvider).onExpired = notifier.onSessionExpired;
  return notifier;
});

/// Raccourci pour accéder au user courant
final currentUserProvider = Provider<AuthEntity?>((ref) {
  return ref.watch(authNotifierProvider).auth;
});