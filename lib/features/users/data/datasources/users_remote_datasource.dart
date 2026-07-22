import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/utils/photo_url_utils.dart';
import '../../../auth/data/models/user_model.dart';
import '../../domain/entities/user_stats_entity.dart';

class UsersRemoteDataSource {
  UsersRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<UserModel>> list({
    int page = 1,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final params = <String, dynamic>{
        'page': page,
        'per_page': 50,
        ...?filters,
      };
      final resp = await _dio.get(
        ApiConfig.users,
        queryParameters: params,
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data)
            .map(UserModel.fromJson)
            .toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<UserModel> getById(int id) async {
    try {
      final resp = await _dio.get('${ApiConfig.users}/$id');
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Membre introuvable.');
        }
        return UserModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<UserModel> create(Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.post(ApiConfig.users, data: payload);
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse création invalide.');
        }
        return UserModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<UserModel> update(int id, Map<String, dynamic> payload) async {
    try {
      final resp = await _dio.put('${ApiConfig.users}/$id', data: payload);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse mise à jour invalide.');
        }
        return UserModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<String> uploadPhoto({
    required int userId,
    required File photoFile,
  }) async {
    try {
      final filename = photoFile.path.split(RegExp(r'[/\\]')).last;
      final ext = filename.contains('.')
          ? filename.split('.').last.toLowerCase()
          : 'jpg';
      final imageSubtype = switch (ext) {
        'png' => 'png',
        'webp' => 'webp',
        'gif' => 'gif',
        _ => 'jpeg',
      };

      final formData = FormData.fromMap({
        'photo': await MultipartFile.fromFile(
          photoFile.path,
          filename: filename,
          contentType: MediaType('image', imageSubtype),
        ),
      });
      final resp = await _dio.post(
        ApiConfig.userPhoto(userId),
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        final url = normalizePhotoUrl(data?['photoUrl'] ?? data?['photo_url']);
        if (url != null && url.isNotEmpty) return url;
        throw ServerException(message: 'URL photo manquante dans la réponse.');
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<UserModel> toggleStatus(int id) async {
    try {
      final resp = await _dio.patch('${ApiConfig.users}/$id/toggle-status');
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse statut invalide.');
        }
        return UserModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<UserStatsEntity> stats() async {
    try {
      final resp = await _dio.get(ApiConfig.usersStats);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) {
          throw ServerException(message: 'Réponse statistiques invalide.');
        }
        return UserStatsEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
