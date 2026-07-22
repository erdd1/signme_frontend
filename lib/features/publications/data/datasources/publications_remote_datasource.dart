import 'package:dio/dio.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../models/publication_model.dart';

class PublicationDelta {
  const PublicationDelta({
    required this.items,
    required this.deletedIds,
  });

  final List<PublicationModel> items;
  final List<int> deletedIds;
}

class PublicationsRemoteDataSource {
  PublicationsRemoteDataSource(this._dio);

  final Dio _dio;

  Map<String, dynamic> _queryFromFilters(Map<String, dynamic> filters) {
    final query = <String, dynamic>{
      'per_page': filters['per_page'] ?? 20,
      if (filters['page'] != null) 'page': filters['page'],
      if (filters['since'] != null) 'since': filters['since'],
    };
    final type = filters['type']?.toString() ?? '';
    if (type.isNotEmpty) query['type'] = type;
    return query;
  }

  bool _isDeleted(Map<String, dynamic> json) => json['deleted_at'] != null;

  int _idFromJson(Map<String, dynamic> json) {
    final raw = json['id'];
    return raw is int ? raw : int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Future<List<Map<String, dynamic>>> _fetchList(
    Map<String, dynamic> filters,
  ) async {
    try {
      final resp = await _dio.get(
        ApiConfig.publications,
        queryParameters: _queryFromFilters(filters),
      );

      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<List<PublicationModel>> list(Map<String, dynamic> filters) async {
    final rows = await _fetchList(filters);
    return rows
        .where((row) => !_isDeleted(row))
        .map(PublicationModel.fromJson)
        .toList();
  }

  Future<PublicationDelta> deltaSince(
    DateTime since,
    Map<String, dynamic> filters,
  ) async {
    final rows = await _fetchList({
      ...filters,
      'since': since.toUtc().toIso8601String(),
    });

    final deletedIds = <int>[];
    final items = <PublicationModel>[];

    for (final row in rows) {
      if (_isDeleted(row)) {
        final id = _idFromJson(row);
        if (id > 0) deletedIds.add(id);
      } else {
        items.add(PublicationModel.fromJson(row));
      }
    }

    return PublicationDelta(items: items, deletedIds: deletedIds);
  }

  Future<PublicationModel> getById(int id) async {
    try {
      final resp = await _dio.get('${ApiConfig.publications}/$id');
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Publication introuvable.');
        }
        return PublicationModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<PublicationModel> create(Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.post(
        ApiConfig.publications,
        data: payload,
      );
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Reponse creation invalide.');
        }
        return PublicationModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<PublicationModel> update(int id, Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.put(
        '${ApiConfig.publications}/$id',
        data: payload,
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Reponse mise a jour invalide.');
        }
        return PublicationModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> delete(int id) async {
    try {
      final resp = await _dio.delete('${ApiConfig.publications}/$id');
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}