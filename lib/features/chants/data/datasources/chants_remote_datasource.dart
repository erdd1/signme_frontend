import 'package:dio/dio.dart';

import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/chant_entity.dart';

class ChantsRemoteDataSource {
  ChantsRemoteDataSource(this._dio);

  final Dio _dio;

  /// Recherche par titre ou par extrait de paroles. [cancelToken] permet
  /// d'abandonner la requête devenue obsolète quand l'utilisateur continue
  /// de saisir.
  Future<List<ChantSummaryEntity>> search(String query, {CancelToken? cancelToken}) async {
    try {
      final resp = await _dio.get(
        ApiConfig.chantsSearch,
        queryParameters: {'q': query},
        cancelToken: cancelToken,
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(ChantSummaryEntity.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<ChantDetailEntity> fetchDetail(int id) async {
    try {
      final resp = await _dio.get(ApiConfig.chantDetail(id));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return ChantDetailEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
