import 'dart:convert';
import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/auth_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/auth_model.dart';

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
      if (rememberMe) await storage.saveRememberMe(true);
      return Right(auth);
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(message: e.firstError));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
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
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> forgotPassword({required String email}) async {
    try {
      await remoteDataSource.forgotPassword(email: email);
      return const Right(null);
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(UnknownFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthEntity?>> restoreSession() async {
    try {
      final token    = await storage.getAccessToken();
      final userJson = await storage.getUser();
      final refresh  = await storage.getRefreshToken();

      if (token == null || userJson == null) return const Right(null);

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
