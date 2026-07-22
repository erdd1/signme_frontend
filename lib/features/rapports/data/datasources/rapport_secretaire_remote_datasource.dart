import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/rapport_secretaire_entity.dart';

class RapportSecretaireRemoteDataSource {
  RapportSecretaireRemoteDataSource(this.dio);
  final Dio dio;

  Future<RapportSecretaireEntity> getRapportSecretaire({String? month}) async {
    final data = await getRapportSecretaireRaw(month: month);
    return RapportSecretaireEntity.fromJson(data);
  }

  /// Retourne le rapport brut (JSON), utile pour le cache Isar.
  Future<Map<String, dynamic>> getRapportSecretaireRaw({String? month}) async {
    try {
      final params = <String, dynamic>{};
      if (month != null) params['month'] = month;

      final resp = await dio.get(
        ApiConfig.rapportSecretaire,
        queryParameters: params,
      );

      if (resp.statusCode == 200) {
        return resp.data['data'] as Map<String, dynamic>? ?? {};
      }
      throw ServerException(message: 'Impossible de charger le rapport.');
    } on DioException catch (e) {
      throwFromDio(e);
    } catch (e) {
      throw ServerException(message: 'Impossible de charger le rapport. Veuillez réessayer.');
    }
  }
}
