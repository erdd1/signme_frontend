import 'package:dio/dio.dart';

import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';
import '../../domain/entities/retrait_entity.dart';

class PaginatedRetraits {
  const PaginatedRetraits({
    required this.items,
    required this.currentPage,
    required this.lastPage,
  });

  final List<RetraitEntity> items;
  final int currentPage;
  final int lastPage;

  bool get hasMore => currentPage < lastPage;
}

class RetraitsRemoteDataSource {
  RetraitsRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Chemins relatifs — le baseUrl (/api/v1) est déjà dans le DioClient ──
  static const _base = '/retraits';
  static const _solde = '/retraits/solde';
  static const _beneficiaire = '/retraits/beneficiaire';
  static String _recheck(String uuid) => '/retraits/$uuid/recheck';

  Future<int> fetchSolde() async {
    try {
      final resp = await _dio.get(_solde);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        final solde = data?['solde'];
        return solde is num ? solde.toInt() : 0;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<RetraitBeneficiaireEntity?> fetchBeneficiaire() async {
    try {
      final resp = await _dio.get(_beneficiaire);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) return null;
        return RetraitBeneficiaireEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<RetraitBeneficiaireEntity> storeBeneficiaire({
    required String operator,
    required String phone,
  }) async {
    try {
      final resp = await _dio.post(_beneficiaire, data: {
        'operator': operator,
        'phone': phone,
      });
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return RetraitBeneficiaireEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<RetraitEntity> initiateRetrait(int montant) async {
    try {
      final resp = await _dio.post(_base, data: {'montant': montant});
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return RetraitEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<PaginatedRetraits> fetchHistorique({int page = 1, int perPage = 20}) async {
    try {
      final resp = await _dio.get(_base, queryParameters: {'page': page, 'per_page': perPage});
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final body = resp.data as Map<String, dynamic>;
        final rawList = ApiResponseParser.extractList(body);
        final pagination = body['pagination'] as Map<String, dynamic>?;

        final items = rawList.map((m) => RetraitEntity.fromJson(m)).toList();

        return PaginatedRetraits(
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

  Future<RetraitEntity> recheck(String uuid) async {
    try {
      final resp = await _dio.post(_recheck(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return RetraitEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
