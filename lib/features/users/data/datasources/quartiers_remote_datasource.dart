import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';

class QuartiersRemoteDataSource {
  QuartiersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<QuartierRef>> list() async {
    try {
      final resp = await _dio.get(ApiConfig.quartiers);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(QuartierRef.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<QuartierRef> create(String nom) async {
    try {
      final resp = await _dio.post(ApiConfig.quartiers, data: {'nom': nom});
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse création invalide.');
        }
        return QuartierRef.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final resp = await _dio.delete(ApiConfig.quartierDetail(id));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
