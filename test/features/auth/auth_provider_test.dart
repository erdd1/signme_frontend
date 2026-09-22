import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/errors/failures.dart';
import 'package:signme/core/services/connectivity_service.dart';
import 'package:signme/core/storage/secure_storage.dart';
import 'package:signme/features/auth/data/datasources/google_auth_datasource.dart';
import 'package:signme/features/auth/domain/entities/auth_entity.dart';
import 'package:signme/features/auth/domain/entities/user_entity.dart';
import 'package:signme/features/auth/domain/repositories/auth_repository.dart';
import 'package:signme/features/auth/presentation/providers/auth_provider.dart';

/// En mémoire — évite tout appel réel à flutter_secure_storage (canal de
/// plateforme indisponible dans un test unitaire pur).
class _FakeSecureStorage extends SecureStorage {
  int? lastCachedUserId;

  @override
  Future<int?> getLastCachedUserId() async => lastCachedUserId;

  @override
  Future<void> setLastCachedUserId(int userId) async =>
      lastCachedUserId = userId;

  @override
  Future<void> saveUser(String userJson) async {}
}

class _FakeAuthRepository implements AuthRepository {
  final List<Completer<Either<Failure, AuthEntity>>> pendingLogins = [];

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) {
    final completer = Completer<Either<Failure, AuthEntity>>();
    pendingLogins.add(completer);
    return completer.future;
  }

  @override
  Future<Either<Failure, AuthEntity?>> restoreSession() async =>
      const Right(null);

  @override
  Future<Either<Failure, UserEntity>> getMe() async =>
      const Left(UnknownFailure(message: 'n/a'));

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle({
    required String idToken,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> logout() => throw UnimplementedError();

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, Map<String, dynamic>>> resendPasswordResetOTP({
    required String email,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) =>
      throw UnimplementedError();

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) =>
      throw UnimplementedError();
}

void main() {
  test(
    'login() : un double-appel (double-tap trop rapide pour que le bouton '
    "n'ait eu le temps de se désactiver) ne déclenche qu'une seule requête "
    'de connexion',
    () async {
      final repo = _FakeAuthRepository();
      final notifier = AuthNotifier(
        repo,
        _FakeSecureStorage(),
        ConnectivityService(),
        GoogleAuthDataSource(),
      );
      addTearDown(notifier.dispose);

      // Laisse _init() (restoreSession, appelé par le constructeur) se
      // résoudre avant de tester login().
      await Future<void>.delayed(Duration.zero);

      final first = notifier.login(email: 'membre@test.com', password: 'x');
      final second = notifier.login(email: 'membre@test.com', password: 'x');

      expect(await second, isFalse);
      expect(repo.pendingLogins.length, 1);

      repo.pendingLogins.single.complete(
        const Right(
          AuthEntity(
            user: UserEntity(id: 1, nom: 'Membre', email: 'membre@test.com', role: 'paroissien'),
            accessToken: 'token',
            refreshToken: 'refresh',
          ),
        ),
      );
      expect(await first, isTrue);
      expect(notifier.state.isAuthenticated, isTrue);
    },
  );
}
