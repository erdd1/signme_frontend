import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';

class VillesRemoteDataSource {
  VillesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<VilleRef>> list() async {
    try {
      final resp = await _dio.get(ApiConfig.villes);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(VilleRef.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<VilleRef> create(String nom, {required bool estDiaspora}) async {
    try {
      final resp = await _dio.post(
        ApiConfig.villes,
        data: {'nom': nom, 'estDiaspora': estDiaspora},
      );
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse création invalide.');
        }
        return VilleRef.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final resp = await _dio.delete(ApiConfig.villeDetail(id));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
