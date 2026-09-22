import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/celebration_entity.dart';

class CelebrationsRemoteDataSource {
  CelebrationsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Payload brut (liste) — utilisé par le notifier et par le cache
  /// offline-first, à l'identique du pattern Finances/Évènements.
  Future<List<Map<String, dynamic>>> fetchListRaw() async {
    try {
      final resp = await _dio.get(ApiConfig.celebrations, queryParameters: {'per_page': 100});
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data as Map<String, dynamic>)
            .cast<Map<String, dynamic>>();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<CelebrationEntity> fetchByUuid(String uuid) async {
    try {
      final resp = await _dio.get(ApiConfig.celebrationDetail(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return CelebrationEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<CelebrationEntity> markRead(String uuid) async {
    try {
      final resp = await _dio.post(ApiConfig.celebrationMarkRead(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return CelebrationEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
