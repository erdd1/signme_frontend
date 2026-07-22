import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/rapport_annuel_entity.dart';
import '../../domain/entities/rapport_comparaison_entity.dart';
import '../../domain/entities/rapport_mensuel_entity.dart';

class FinancesRemoteDataSource {
  FinancesRemoteDataSource(this._dio);

  final Dio _dio;

  Future<RapportAnnuelEntity> getRapportAnnuel(int year) async {
    final data = await getRapportAnnuelRaw(year);
    return RapportAnnuelEntity.fromJson(data);
  }

  /// Retourne le rapport annuel brut (JSON), utile pour le cache Isar.
  Future<Map<String, dynamic>> getRapportAnnuelRaw(int year) async {
    try {
      final resp = await _dio.get(
        ApiConfig.rapportAnnuel,
        queryParameters: {'year': year},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse finances invalide.');
        }
        return data;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<RapportMensuelEntity> getRapportMois(String monthKey) async {
    try {
      final resp = await _dio.get(
        ApiConfig.rapportMensuel,
        queryParameters: {'month': monthKey},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse mensuelle invalide.');
        }
        return RapportMensuelEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<RapportComparaisonEntity> getComparaison() async {
    try {
      final resp = await _dio.get(ApiConfig.rapportComparaison);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse comparaison invalide.');
        }
        return RapportComparaisonEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
