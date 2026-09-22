import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';

class MesDepensesRemoteDataSource {
  MesDepensesRemoteDataSource(this._dio);

  final Dio _dio;

  /// Parcourt TOUTES les pages (chaque requête HTTP bornée à [perPage]
  /// lignes) : une contribution personnelle cumulée sur plusieurs années peut
  /// largement dépasser une seule page, il ne faut jamais en perdre
  /// silencieusement au-delà de la première.
  Future<List<Map<String, dynamic>>> list({int? annee, int? mois, int perPage = 100}) async {
    try {
      final all = <Map<String, dynamic>>[];
      var page = 1;
      while (true) {
        final resp = await _dio.get(
          ApiConfig.mesContributions,
          queryParameters: {
            'per_page': perPage,
            'page': page,
            if (annee != null) 'annee': annee,
            if (mois != null) 'mois': mois,
          },
        );
        if (resp.statusCode != 200 || !ApiResponseParser.isSuccess(resp.data)) {
          throw ServerException(message: ApiResponseParser.message(resp.data));
        }
        final body = resp.data as Map<String, dynamic>;
        all.addAll(ApiResponseParser.extractList(body));

        final pagination = body['pagination'] as Map<String, dynamic>?;
        final currentPage = (pagination?['current_page'] as num?)?.toInt() ?? page;
        final lastPage = (pagination?['last_page'] as num?)?.toInt() ?? page;
        if (currentPage >= lastPage) break;
        page++;
      }
      return all;
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
