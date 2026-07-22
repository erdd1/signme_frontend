import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';

class GroupesRemoteDataSource {
  GroupesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<GroupeRef>> list() async {
    try {
      final resp = await _dio.get(ApiConfig.groupes);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(GroupeRef.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<GroupeRef> create(String nom) async {
    try {
      final resp = await _dio.post(ApiConfig.groupes, data: {'nom': nom});
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse création invalide.');
        }
        return GroupeRef.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final resp = await _dio.delete(ApiConfig.groupeDetail(id));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
