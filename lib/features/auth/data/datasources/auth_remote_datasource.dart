import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});
  Future<void>      logout();
  Future<UserModel> getMe();
  Future<void>      forgotPassword({required String email});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dio, required this.storage});
  final Dio           dio;
  final SecureStorage storage;

  @override
  Future<AuthModel> login({required String email, required String password}) async {
    try {
      final response = await dio.post(
        ApiConfig.login,
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final auth = AuthModel.fromJson(response.data);
        // Sauvegarder tokens de façon sécurisée
        await storage.saveAccessToken(auth.accessToken);
        await storage.saveRefreshToken(auth.refreshToken);
        await storage.saveUser(jsonEncode((auth.user as UserModel).toJson()));
        return auth;
      }

      throw ServerException(
        message: response.data['message']?.toString() ?? 'Erreur de connexion.',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422 || e.response?.statusCode == 401) {
        throw AuthException(
          message: e.response?.data['message']?.toString() ?? 'Email ou mot de passe incorrect.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post(ApiConfig.logout);
    } catch (_) {
      // Silencieux — on nettoie le stockage local quoi qu'il arrive
    } finally {
      await storage.clearAll();
    }
  }

  @override
  Future<UserModel> getMe() async {
    final response = await dio.get(ApiConfig.me);
    if (response.statusCode == 200 && response.data['success'] == true) {
      return UserModel.fromJson(
        response.data['data'] as Map<String, dynamic>,
      );
    }
    throw ServerException(message: 'Impossible de récupérer le profil.');
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    final response = await dio.post(
      ApiConfig.forgotPassword,
      data: {'email': email},
    );
    if (response.statusCode != 200 || response.data['success'] != true) {
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Erreur lors de l\'envoi.',
      );
    }
  }
}
