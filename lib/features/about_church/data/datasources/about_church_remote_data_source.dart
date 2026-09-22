import 'dart:io';
import 'package:dio/dio.dart';

import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/about_article_entity.dart';
import '../../domain/entities/about_church_payload_entity.dart';
import '../../domain/entities/church_about_info_entity.dart';

class AboutChurchRemoteDataSource {
  AboutChurchRemoteDataSource(this._dio);

  final Dio _dio;

  // ── Chemins relatifs — le baseUrl (/api/v1) est déjà dans le DioClient ──
  static const _base = '/about-church';
  static const _info = '/about-church/info';
  static const _articles = '/about-church/articles';
  static String _article(String uuid) => '/about-church/articles/$uuid';
  static String _pin(String uuid) => '/about-church/articles/$uuid/pin';
  static String _unpin(String uuid) => '/about-church/articles/$uuid/unpin';

  /// Payload brut (non désérialisé) — utilisé par le notifier et par
  /// [SyncService] pour alimenter le cache Isar offline-first, à l'identique
  /// du pattern Finances/Évènements (`getRapportAnnuelRaw`, `deltaSince`…).
  Future<Map<String, dynamic>> fetchRaw() async {
    try {
      final resp = await _dio.get(_base);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return data;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<ChurchAboutInfoEntity> updateInfo(Map<String, dynamic> body) async {
    try {
      final resp = await _dio.put(_info, data: body);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return ChurchAboutInfoEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<AboutArticleEntity> createArticle({
    required String type,
    required String titre,
    required String contenu,
    String? statutPasteur,
    List<File> images = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        'type': type,
        'titre': titre,
        'contenu': contenu,
        if (statutPasteur != null) 'statutPasteur': statutPasteur,
      });
      for (final file in images) {
        formData.files.add(MapEntry(
          'images[]',
          await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
        ));
      }

      final resp = await _dio.post(_articles, data: formData);
      if ((resp.statusCode == 200 || resp.statusCode == 201) &&
          ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return AboutArticleEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  /// Gestion des photos — [photosTouched] doit être `true` dès que
  /// l'utilisateur a ajouté et/ou retiré une photo (même pour tout retirer
  /// sans rien ajouter). Si `false`, [keepImages] et [images] sont ignorés
  /// et les photos existantes de l'article restent inchangées. Si `true`,
  /// le jeu final = [keepImages] (URLs existantes conservées) + [images]
  /// (nouveaux fichiers uploadés), dans cet ordre.
  Future<AboutArticleEntity> updateArticle({
    required String uuid,
    String? titre,
    String? contenu,
    String? statutPasteur,
    bool photosTouched = false,
    List<String> keepImages = const [],
    List<File> images = const [],
  }) async {
    try {
      final formData = FormData.fromMap({
        if (titre != null) 'titre': titre,
        if (contenu != null) 'contenu': contenu,
        if (statutPasteur != null) 'statutPasteur': statutPasteur,
        if (photosTouched) 'photosTouched': '1',
        // Laravel ne parse pas nativement le multipart sur une vraie requête
        // PUT (limitation PHP) — on envoie donc un POST avec ce spoofing,
        // reconnu automatiquement par le middleware Laravel.
        '_method': 'PUT',
      });
      if (photosTouched) {
        for (final url in keepImages) {
          formData.fields.add(MapEntry('keepImages[]', url));
        }
        for (final file in images) {
          formData.files.add(MapEntry(
            'images[]',
            await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
          ));
        }
      }

      final resp = await _dio.post(_article(uuid), data: formData);
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return AboutArticleEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<void> deleteArticle(String uuid) async {
    try {
      final resp = await _dio.delete(_article(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        return;
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<AboutArticleEntity> pinArticle(String uuid) async {
    try {
      final resp = await _dio.post(_pin(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return AboutArticleEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Future<AboutArticleEntity> unpinArticle(String uuid) async {
    try {
      final resp = await _dio.post(_unpin(uuid));
      if (resp.statusCode == 200 && ApiResponseParser.isSuccess(resp.data)) {
        final data = ApiResponseParser.dataMap(resp.data);
        if (data == null) throw ServerException(message: 'Réponse invalide.');
        return AboutArticleEntity.fromJson(data);
      }
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }
}
