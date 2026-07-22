import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../models/contribution_model.dart';

class ContributionsRemoteDataSource {
  ContributionsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<ContributionModel> initiate({
    required String evenementUuid,
    required int montant,
    String? note,
    required String paymentMethod,
    String? paymentOperator,
    String? paymentNumber,
    int? groupeId,
  }) async {
    try {
      final resp = await _dio.post(
        ApiConfig.evenementContributions(evenementUuid),
        data: {
          'montant': montant,
          if (note != null && note.isNotEmpty) 'note': note,
          'paymentMethod': paymentMethod,
          if (paymentOperator != null) 'paymentOperator': paymentOperator,
          if (paymentNumber != null) 'paymentNumber': paymentNumber,
          if (groupeId != null) 'groupeId': groupeId,
        },
      );
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse paiement invalide.');
        return ContributionModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<ContributionModel> getStatus(String contributionUuid) async {
    try {
      final resp = await _dio.get(ApiConfig.contributionStatus(contributionUuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Statut introuvable.');
        return ContributionModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Onglet drawer "Contributions événement" — toutes les contributions
  /// réussies de l'église. Le paramètre `status` est toujours forcé à
  /// "completed" : côté application mobile, les paiements échoués/en attente
  /// ne doivent jamais être exposés (ce suivi est réservé au panneau admin,
  /// qui appelle ce même endpoint sans ce filtre pour l'audit/recheck).
  /// Retourne le JSON brut (et non déjà mappé en [ContributionModel]) pour
  /// permettre au provider de le persister tel quel dans le cache local
  /// offline-first avant de le convertir en entités.
  Future<List<Map<String, dynamic>>> listAllForTreasury({int perPage = 20}) async {
    try {
      final resp = await _dio.get(
        ApiConfig.contributionsEvenements,
        queryParameters: {'per_page': perPage, 'status': 'completed'},
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
