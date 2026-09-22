import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/signature_entity.dart';
import '../models/signature_model.dart';

/// Couche data â€” appels HTTP signatures / rapports liÃ©s.
class SignatureRemoteDataSource {
  SignatureRemoteDataSource(this._dio);

  final Dio _dio;

  Future<Map<String, dynamic>> getMaCarteRaw(int year) async {
    try {
      final resp = await _dio.get(
        ApiConfig.signatureMaCarte,
        queryParameters: {'year': year},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Reponse carte invalide.');
        }
        return data;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<MaCarteData> getMaCarte(int year) async {
    return MaCarteData.fromJson(await getMaCarteRaw(year));
  }

  Future<List<SignatureEntity>> getHistoriquePasteur({
    int page = 1,
    String? month,
    String? status,
    String? type,
  }) async {
    try {
      final resp = await _dio.get(
        ApiConfig.signatureHistorique,
        queryParameters: {
          'page': page,
          'per_page': 20,
          if (month != null) 'month': month,
          if (status != null) 'status': status,
          if (type != null) 'type': type,
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map((e) => SignatureModel.fromJson(e))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
