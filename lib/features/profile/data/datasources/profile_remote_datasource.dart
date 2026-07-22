import 'package:dio/dio.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/data/models/user_model.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/update_profile_request_model.dart';

/// Interface pour les appels API du profil
abstract class ProfileRemoteDataSource {
  /// Mettre à jour le profil utilisateur via l'API
  /// 
  /// Lance les exceptions spécifiques en cas d'erreur
  Future<UserEntity> updateProfile({
    required int userId,
    required UpdateProfileRequestModel requestModel,
  });
}

/// Implémentation des appels API du profil
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio dio;

  ProfileRemoteDataSourceImpl(this.dio);

  @override
  Future<UserEntity> updateProfile({
    required int userId,
    required UpdateProfileRequestModel requestModel,
  }) async {
    try {
      final response = await dio.put(
        '${ApiConfig.users}/$userId',
        data: requestModel.toJson(),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        if (data is! Map<String, dynamic>) {
          throw ServerException(message: 'Réponse profil invalide.');
        }
        return UserModel.fromJson(data);
      }
      
      throw ServerException(
        message: 'Erreur ${response.statusCode}: Impossible de mettre à jour le profil',
      );
    } on DioException catch (e) {
      _handleDioException(e);
      rethrow;
    } on Exception catch (e) {
      // Si c'est déjà une exception métier, la relancer
      if (e is ServerException || e is AuthException || e is NetworkException || 
          e is TimeoutException || e is ValidationException || e is ForbiddenException ||
          e is NotFoundException || e is UnknownException) {
        rethrow;
      }
      throw UnknownException();
    }
  }

  /// Gérer les exceptions Dio et les convertir en exceptions métier
  void _handleDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        throw TimeoutException(
          message: 'La connexion a expiré. Veuillez réessayer.',
        );
      
      case DioExceptionType.unknown:
        throw NetworkException(
          message: 'Erreur réseau. Vérifiez votre connexion.',
        );
      
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        if (statusCode == 422) {
          throw ValidationException(
            message: 'Données invalides',
            errors: responseData?['errors'] ?? {},
          );
        } else if (statusCode == 401) {
          throw AuthException(
            message: 'Votre session a expiré. Veuillez vous reconnecter.',
          );
        } else if (statusCode == 403) {
          throw ForbiddenException(
            message: 'Vous n\'avez pas la permission de modifier ce profil.',
          );
        } else if (statusCode == 404) {
          throw NotFoundException(
            message: 'Profil utilisateur introuvable.',
          );
        } else if (statusCode != null && statusCode >= 500) {
          throw ServerException(
            message: 'Erreur serveur. Veuillez réessayer plus tard.',
          );
        } else {
          throw UnknownException(
            message: 'Erreur HTTP $statusCode',
          );
        }
      
      case DioExceptionType.cancel:
        throw NetworkException(message: 'Requête annulée.');
      
      case DioExceptionType.badCertificate:
      case DioExceptionType.connectionError:
        throw NetworkException(
          message: 'Erreur de connexion. Vérifiez votre connexion internet.',
        );
    }
  }
}
