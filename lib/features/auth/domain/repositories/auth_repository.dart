import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/auth_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, AuthEntity>> login({
    required String email,
    required String password,
    bool rememberMe = false,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, UserEntity>> getMe();

  Future<Either<Failure, void>> forgotPassword({required String email});

  Future<Either<Failure, AuthEntity?>> restoreSession();
}
