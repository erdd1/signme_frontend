import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthModel> login({required String email, required String password});
  Future<AuthModel> loginWithGoogle({required String idToken});
  Future<void> logout();
  Future<UserModel> getMe();
  Future<void> forgotPassword({required String email});
  Future<Map<String, dynamic>> verifyPasswordResetOTP({required String email, required String otp});
  Future<Map<String, dynamic>> resendPasswordResetOTP({required String email});
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  });
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({required this.dio, required this.storage});
  final Dio           dio;
  final SecureStorage storage;

  @override
  Future<AuthModel> login({required String email, required String password}) async {
    final deviceId = await storage.getOrCreateDeviceId();
    return _authenticate(
      ApiConfig.login,
      {
        'email': email,
        'password': password,
        'device_id': deviceId,
      },
      defaultAuthMessage: 'Email ou mot de passe incorrect.',
    );
  }

  @override
  Future<AuthModel> loginWithGoogle({required String idToken}) async {
    final deviceId = await storage.getOrCreateDeviceId();
    return _authenticate(
      ApiConfig.googleLogin,
      {
        'id_token': idToken,
        'device_id': deviceId,
      },
      defaultAuthMessage: 'Connexion Google refusée.',
    );
  }

  /// Logique commune login/login Google : envoie la requête, persiste les
  /// tokens en cas de succès, mappe les erreurs réseau de façon uniforme.
  Future<AuthModel> _authenticate(
    String path,
    Map<String, dynamic> data, {
    required String defaultAuthMessage,
  }) async {
    try {
      final response = await dio.post(path, data: data);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final auth = AuthModel.fromJson(response.data);
        if (auth.accessToken.isEmpty) {
          throw AuthException(
            message: 'Réponse serveur invalide : token d\'accès manquant.',
          );
        }
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
      final code = e.response?.statusCode;
      final msg = e.response?.data?['message']?.toString();
      if (code == 401) {
        throw AuthException(message: msg ?? defaultAuthMessage);
      }
      if (code == 403) {
        throw ForbiddenException(message: msg ?? 'Accès refusé.');
      }
      if (e.error is AppException) throw e.error as AppException;
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
      // Ne jamais laisser un échec d'écriture locale empêcher la
      // déconnexion de se terminer.
      try {
        await storage.clearAll();
      } catch (_) {}
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dio.get(ApiConfig.me);
      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is! Map<String, dynamic>) {
          throw ServerException(message: 'Réponse profil invalide.');
        }
        return UserModel.fromJson(data);
      }
      throw ServerException(message: 'Impossible de récupérer le profil.');
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await dio.post(
        ApiConfig.forgotPassword,
        data: {'email': email},
      );
      if (response.statusCode != 200 || response.data['success'] != true) {
        throw ServerException(
          message: response.data['message']?.toString() ?? 'Erreur lors de l\'envoi.',
        );
      }
    } on DioException catch (e) {
      // Mapper toutes les DioException : AppException empaqueté, timeout, réseau, etc.
      throwFromDio(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.resetPassword,
        data: {
          'email': email,
          'token': token,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }
      throw ServerException(
        message: response.data['message']?.toString() ??
            'Réinitialisation impossible.',
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        throw ValidationException(
          message: e.response?.data['message']?.toString() ??
              'Données invalides.',
          errors: e.response?.data['errors'] ?? {},
        );
      }
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPasswordResetOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.verifyPasswordResetOTP,
        data: {'email': email, 'otp': otp},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Code invalide.',
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.data?['message']?.toString();
      if (code == 422) {
        throw ValidationException(
          message: msg ?? 'Données invalides.',
          errors: e.response?.data['errors'] ?? {},
        );
      }
      if (code == 429) {
        throw RateLimitException(message: msg ?? 'Trop de tentatives.');
      }
      if (e.error is AppException) throw e.error as AppException;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> resendPasswordResetOTP({
    required String email,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.resendPasswordResetOTP,
        data: {'email': email},
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw ServerException(
        message: response.data['message']?.toString() ?? 'Impossible de renvoyer.',
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.data?['message']?.toString();
      if (code == 429) {
        throw RateLimitException(message: msg ?? 'Trop de renvois. Attendez.');
      }
      if (e.error is AppException) throw e.error as AppException;
      rethrow;
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String resetToken,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.confirmPasswordReset,
        data: {
          'reset_token': resetToken,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        return;
      }
      throw ServerException(
        message: response.data['message']?.toString() ??
            'Réinitialisation impossible.',
      );
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await dio.post(
        ApiConfig.changePassword,
        data: {
          'current_password': currentPassword,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );
      if (response.statusCode == 200 && response.data['success'] == true) {
        await storage.clearSession();
        return;
      }
      throw ServerException(
        message: response.data['message']?.toString() ??
            'Impossible de modifier le mot de passe.',
      );
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final msg = e.response?.data?['message']?.toString();
      if (code == 400 || code == 401) {
        throw AuthException(
          message: msg ?? 'Mot de passe actuel incorrect.',
        );
      }
      if (code == 422) {
        throw ValidationException(
          message: msg ?? 'Données invalides.',
          errors: e.response?.data['errors'] ?? {},
        );
      }
      if (e.error is AppException) throw e.error as AppException;
      rethrow;
    }
  }
}
