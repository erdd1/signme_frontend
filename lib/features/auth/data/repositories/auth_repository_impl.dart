import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.storage,
  });

  final AuthRemoteDataSource remoteDataSource;
  final SecureStorage        storage;

  @override
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  }) async {
    try {
      final auth = await remoteDataSource.login(email: email, password: password);
      if (rememberMe) {
        await storage.saveRememberMe(true);
        await storage.saveRememberedEmail(email);
      } else {
        await storage.saveRememberMe(false);
        await storage.clearRememberedEmail();
      }
      return Right(auth);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, AuthEntity>> loginWithGoogle({required String idToken}) async {
    try {
      final auth = await remoteDataSource.loginWithGoogle(idToken: idToken);
      return Right(auth);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ForbiddenException catch (e) {
      return Left(ForbiddenFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDataSource.logout();
      return const Right(null);
    } catch (e) {
      await storage.clearAll(); // Force clear même en cas d'erreur réseau
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getMe() async {
    try {
      final user = await remoteDataSource.getMe();
      // Mettre à jour le cache local
      await storage.saveUser(jsonEncode(user.toJson()));
      return Right(user);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final result = await remoteDataSource.verifyPasswordResetOTP(
        email: email,
        otp: otp,
      );
      return Right(result);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> resendPasswordResetOTP({
    required String email,
  }) async {
    try {
      final result = await remoteDataSource.resendPasswordResetOTP(email: email);
      return Right(result);
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.confirmPasswordReset(
        resetToken: resetToken,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await remoteDataSource.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      return const Right(null);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError, errors: e.errors));
    } on RateLimitException catch (e) {
      return Left(RateLimitFailure(
        message: e.message,
        retryAfterSeconds: e.retryAfterSeconds,
      ));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: messageFromError(e)));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> restoreSession() async {
    try {
      final token    = await storage.getAccessToken();
      final userJson = await storage.getUser();
      final refresh  = await storage.getRefreshToken();

      if (token == null || token.isEmpty || userJson == null) {
        return const Right(null);
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final user    = UserModel.fromJson(userMap);

      return Right(AuthModel(
        user:         user,
        accessToken:  token,
        refreshToken: refresh ?? '',
      ));
    } catch (_) {
      return const Right(null);
    }
  }
}
