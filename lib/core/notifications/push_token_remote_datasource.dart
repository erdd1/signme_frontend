import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../errors/exceptions.dart';
import '../network/api_response_parser.dart';
import '../network/dio_exception_mapper.dart';

/// Datasource — Enregistrement du jeton FCM de cet appareil côté serveur.
class PushTokenRemoteDataSource {
  PushTokenRemoteDataSource(this._dio);

  final Dio _dio;

  Future<void> register({
    required String token,
    required String platform,
    String? timezone,
  }) async {
    try {
      final resp = await _dio.post(ApiConfig.deviceTokens, data: {
        'token': token,
        'platform': platform,
        if (timezone != null) 'timezone': timezone,
      });
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> unregister(String token) async {
    try {
      await _dio.delete(ApiConfig.deviceTokens, data: {'token': token});
    } on DioException catch (_) {
      // Déconnexion : ne jamais bloquer le logout si ça échoue (le jeton
      // sera de toute façon réassigné au prochain login sur cet appareil).
    }
  }
}
