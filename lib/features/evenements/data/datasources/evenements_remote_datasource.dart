import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../models/evenement_model.dart';

class EvenementsRemoteDataSource {
  EvenementsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<MultipartFile> _multipartFromImage(File image) async {
    final filename = image.path.split(RegExp(r'[/\\]')).last;
    final ext = filename.contains('.') ? filename.split('.').last.toLowerCase() : 'jpg';
    final subtype = switch (ext) {
      'png' => 'png',
      'webp' => 'webp',
      _ => 'jpeg',
    };
    return MultipartFile.fromFile(
      image.path,
      filename: filename,
      contentType: MediaType('image', subtype),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchList(Map<String, dynamic> filters) async {
    try {
      final resp = await _dio.get(
        ApiConfig.evenements,
        queryParameters: {
          'per_page': filters['per_page'] ?? 20,
          if (filters['page'] != null) 'page': filters['page'],
          if (filters['since'] != null) 'since': filters['since'],
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<List<EvenementModel>> list(Map<String, dynamic> filters) async {
    final rows = await _fetchList(filters);
    return rows.map(EvenementModel.fromJson).toList();
  }

  /// Vue "Gérer les événements" (pasteur/secrétaire/trésorier) : tous les
  /// événements de l'église quel que soit le statut (Actif ET Archivé),
  /// avec montant collecté et nombre de contributeurs distincts.
  Future<List<EvenementModel>> listGestion({String? statut, int perPage = 20}) async {
    try {
      final resp = await _dio.get(
        ApiConfig.evenementsGestion,
        queryParameters: {
          'per_page': perPage,
          if (statut != null) 'statut': statut,
        },
      );
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return ApiResponseParser.extractList(resp.data).map(EvenementModel.fromJson).toList();
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Delta depuis la dernière synchro (aucune suppression possible côté
  /// backend pour les événements : uniquement des mises à jour/créations).
  Future<List<EvenementModel>> deltaSince(
    DateTime since,
    Map<String, dynamic> filters,
  ) async {
    final rows = await _fetchList({
      ...filters,
      'since': since.toUtc().toIso8601String(),
    });
    return rows.map(EvenementModel.fromJson).toList();
  }

  Future<EvenementModel> getByUuid(String uuid) async {
    try {
      final resp = await _dio.get(ApiConfig.evenementDetail(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Événement introuvable.');
        return EvenementModel.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<EvenementModel> create(Map<String, dynamic> payload, {File? image}) async {
    try {
      final data = image == null
          ? payload
          : FormData.fromMap({
              ...payload,
              'image': await _multipartFromImage(image),
            });

      final resp = await _dio.post(
        ApiConfig.evenements,
        data: data,
        options: image == null ? null : Options(contentType: 'multipart/form-data'),
      );
      if (resp.statusCode == 201 && ApiResponseParser.isSuccess(resp.data)) {
        final result = ApiResponseParser.dataMap(resp.data);
        if (result == null) throw ServerException(message: 'Réponse création invalide.');
        return EvenementModel.fromJson(result);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<EvenementModel> update(
    String uuid,
    Map<String, dynamic> payload, {
    File? image,
  }) async {
    try {
      final Response resp;
      if (image == null) {
        resp = await _dio.put(ApiConfig.evenementDetail(uuid), data: payload);
      } else {
        // PHP ne peuple pas $_FILES sur une requête PUT multipart : on passe
        // par le spoofing de méthode standard Laravel (_method=PUT).
        final data = FormData.fromMap({
          ...payload,
          '_method': 'PUT',
          'image': await _multipartFromImage(image),
        });
        resp = await _dio.post(
          ApiConfig.evenementDetail(uuid),
          data: data,
          options: Options(contentType: 'multipart/form-data'),
        );
      }
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final result = ApiResponseParser.dataMap(resp.data);
        if (result == null) throw ServerException(message: 'Réponse mise à jour invalide.');
        return EvenementModel.fromJson(result);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<EvenementModel> _postAction(String path) async {
    try {
      final resp = await _dio.post(path);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final result = ApiResponseParser.dataMap(resp.data);
        if (result == null) throw ServerException(message: 'Réponse invalide.');
        return EvenementModel.fromJson(result);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<EvenementModel> publish(String uuid) => _postAction(ApiConfig.evenementPublish(uuid));

  /// Annule un événement planifié pas encore publié — suppression définitive
  /// côté serveur (aucune entité retournée, contrairement aux autres actions).
  Future<void> cancelScheduled(String uuid) async {
    try {
      final resp = await _dio.post(ApiConfig.evenementCancelScheduled(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<EvenementModel> terminer(String uuid) => _postAction(ApiConfig.evenementTerminer(uuid));

  Future<EvenementModel> archiver(String uuid) => _postAction(ApiConfig.evenementArchiver(uuid));

  Future<EvenementModel> desarchiver(String uuid) =>
      _postAction(ApiConfig.evenementDesarchiver(uuid));
}
