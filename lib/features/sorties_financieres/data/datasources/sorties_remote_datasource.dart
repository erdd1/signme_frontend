import 'package:dio/dio.dart';

import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/sortie_financiere_entity.dart';
import '../../domain/entities/sorties_dashboard_stats_entity.dart';

class PaginatedSorties {
  const PaginatedSorties({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<SortieFinanciereEntity> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

class SortiesRemoteDataSource {
  SortiesRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Chemins relatifs — le baseUrl (/api/v1) est déjà dans le DioClient ──
  static const _base      = '/sorties-financieres';
  static const _dashboard = '/sorties-financieres/dashboard';
  static const _simple    = '/sorties-financieres/simple';
  static const _frais     = '/sorties-financieres/frais';
  static String _detail(String uuid) => '/sorties-financieres/$uuid';

  Future<SortiesDashboardStatsEntity> fetchDashboard({
    Map<String, dynamic>? params,
  }) async {
    try {
      final resp = await _dio.get(_dashboard, queryParameters: params);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Stats invalides.');
        return SortiesDashboardStatsEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<PaginatedSorties> fetchList({
    Map<String, dynamic>? params,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final query = {
        ...?params,
        'page': page,
        'per_page': perPage,
      };
      final resp = await _dio.get(_base, queryParameters: query);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final body = resp.data as Map<String, dynamic>;
        final rawList = ApiResponseParser.extractList(body);
        final pagination = body['pagination'] as Map<String, dynamic>?;

        final items = rawList
            .map((m) => SortieFinanciereEntity.fromJson(m))
            .toList();

        return PaginatedSorties(
          items: items,
          currentPage: (pagination?['current_page'] as num?)?.toInt() ?? page,
          lastPage: (pagination?['last_page'] as num?)?.toInt() ?? page,
        );
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<SortieFinanciereEntity> createSimple(
    Map<String, dynamic> body,
  ) async {
    try {
      final resp = await _dio.post(_simple, data: body);
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return SortieFinanciereEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<SortieFinanciereEntity> createFrais(
    Map<String, dynamic> body,
  ) async {
    try {
      final resp = await _dio.post(_frais, data: body);
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return SortieFinanciereEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<SortieFinanciereEntity> update(
    String uuid,
    Map<String, dynamic> body,
  ) async {
    try {
      final resp = await _dio.put(_detail(uuid), data: body);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return SortieFinanciereEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> delete(String uuid) async {
    try {
      final resp = await _dio.delete(_detail(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
