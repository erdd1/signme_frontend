import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/card_payment_config_entity.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/entities/contribution_filter_event_entity.dart';
import '../../domain/entities/contributions_treasury_stats_entity.dart';
import '../models/contribution_model.dart';

/// Résultat paginé retourné par [ContributionsRemoteDataSource.listForDashboard].
class PaginatedContributions {
  const PaginatedContributions({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<ContributionEntity> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

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

  /// Paramètres du paiement par carte (interrupteur serveur + taux de frais).
  Future<CardPaymentConfigEntity> fetchCardPaymentConfig() async {
    try {
      final resp = await _dio.get(ApiConfig.cardPaymentConfig);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return CardPaymentConfigEntity.fromJson(data);
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

  /// Tableau de bord contributions — liste paginée filtrée (vue trésorerie mobile).
  ///
  /// [filters] : map optionnelle avec les clés `event_id`, `group_id`, `year`, `month`.
  /// Toujours limité aux contributions "completed" — le filtre `status` est
  /// envoyé implicitement par le backend via [listAllForTreasuryFiltered].
  Future<PaginatedContributions> listForDashboard({
    Map<String, dynamic> filters = const {},
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final resp = await _dio.get(
        ApiConfig.contributionsEvenements,
        queryParameters: {
          ...filters,
          'page': page,
          'per_page': perPage,
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final body = resp.data as Map<String, dynamic>;
        final rawList = ApiResponseParser.extractList(body);
        final pagination = body['pagination'] as Map<String, dynamic>?;

        final items = rawList
            .map(ContributionModel.fromJson)
            .map((m) => m.toEntity())
            .toList();

        return PaginatedContributions(
          items:       items,
          currentPage: (pagination?['current_page'] as num?)?.toInt() ?? page,
          lastPage:    (pagination?['last_page'] as num?)?.toInt() ?? page,
        );
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Statistiques financières agrégées des contributions "completed" de l'église,
  /// filtrées selon les mêmes critères que [listForDashboard].
  Future<ContributionsTreasuryStatsEntity> getTreasuryStats({
    Map<String, dynamic> filters = const {},
  }) async {
    try {
      final resp = await _dio.get(
        ApiConfig.contributionsEvenementsStats,
        queryParameters: filters.isEmpty ? null : filters,
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Stats invalides.');
        return ContributionsTreasuryStatsEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Liste des événements ayant au moins une contribution "completed" —
  /// utilisé pour alimenter le dropdown "Événement" des filtres.
  Future<List<ContributionFilterEventEntity>> getFilterEvents() async {
    try {
      final resp = await _dio.get(ApiConfig.contributionsEvenementsFilterEvents);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(ContributionFilterEventEntity.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}

