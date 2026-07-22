import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, AuthEntity>> loginWithGoogle({required String idToken});

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getMe();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, Map<String, dynamic>>> verifyPasswordResetOTP({
    required String email,
    required String otp,
  });

  Future<Either<Failure, Map<String, dynamic>>> resendPasswordResetOTP({
    required String email,
  });

  Future<Either<Failure, void>> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });

  Future<Either<Failure, AuthEntity?>> restoreSession();
}
