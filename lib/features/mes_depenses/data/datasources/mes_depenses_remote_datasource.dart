import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';

class MesDepensesRemoteDataSource {
  MesDepensesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<Map<String, dynamic>>> list({int? annee, int? mois, int perPage = 20}) async {
    try {
      final resp = await _dio.get(
        ApiConfig.mesContributions,
        queryParameters: {
          'per_page': perPage,
          if (annee != null) 'annee': annee,
          if (mois != null) 'mois': mois,
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<Map<String, dynamic>> stats({int? annee, int? mois}) async {
    try {
      final resp = await _dio.get(
        ApiConfig.mesContributionsStats,
        queryParameters: {
          if (annee != null) 'annee': annee,
          if (mois != null) 'mois': mois,
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Statistiques indisponibles.');
        return data;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
