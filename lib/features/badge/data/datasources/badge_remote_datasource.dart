import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../models/badge_count_model.dart';

/// Source de données distante — Badges de notifications
///
/// GET  [ApiConfig.notificationBadges]        → compteurs non lus
/// POST [ApiConfig.notificationBadgesMarkRead] → marque un type comme lu
class BadgeRemoteDataSource {
  BadgeRemoteDataSource(this._dio);

  final Dio _dio;

  /// Récupère les compteurs de badges depuis le backend.
  Future<BadgeCountModel> fetchBadgeCounts() async {
    try {
      final resp = await _dio.get(ApiConfig.notificationBadges);

      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse badges invalide.');
        }
        return BadgeCountModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Marque un type de badge comme lu sur le backend.
  ///
  /// [type] : 'annonces' | 'meditations' | 'evenements' | 'historique' | 'historique_signatures'
  ///
  /// Retourne les nouveaux compteurs mis à jour (le backend les recalcule
  /// et les renvoie directement, évitant un second appel GET).
  Future<BadgeCountModel> markRead(String type) async {
    try {
      final resp = await _dio.post(
        ApiConfig.notificationBadgesMarkRead,
        data: {'type': type},
      );

      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse mark-read invalide.');
        }
        return BadgeCountModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
