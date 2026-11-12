import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/entities/chant_entity.dart';
import '../../domain/entities/chant_hub_entities.dart';
import 'chants_hub_session.dart';

/// Accès aux chants : tout passe par le hub (service séparé).
class ChantsRemoteDataSource {
  ChantsRemoteDataSource(this._session);

  final ChantsHubSession _session;

  Future<T> _appel<T>(Future<Response<dynamic>> Function(Dio dio) requete, T Function(Response<dynamic> r) lire,
      {Set<int> ok = const {200, 201}}) async {
    try {
      final resp = await requete(await _session.client());
      if (ok.contains(resp.statusCode) && ApiResponseParser.isSuccess(resp.data)) return lire(resp);
      throw ServerException(message: ApiResponseParser.message(resp.data));
    } on DioException catch (e) {
      throwFromDio(e);
    }
  }

  Map<String, dynamic> _map(Response<dynamic> r) =>
      ApiResponseParser.dataMap(r.data) ?? (throw ServerException(message: 'Réponse invalide.'));

  /// Chants déjà référencés, vidéos et paroles pour [query]. [cancelToken]
  /// abandonne la requête devenue obsolète quand l'utilisateur continue de saisir.
  Future<ChantsSearchResult> search(String query, {CancelToken? cancelToken}) => _appel(
        (dio) => dio.get('/v1/recherche', queryParameters: {'q': query}, cancelToken: cancelToken),
        (r) => ChantsSearchResult.fromJson(_map(r)),
      );

  /// Paroles complètes (strophes, refrains).
  Future<ChantDetailEntity> fetchDetail(int id) => _appel(
        (dio) => dio.get('/v1/paroles/$id'),
        (r) => ChantDetailEntity.fromJson(_map(r)),
      );

  /// Je regarde un chant trouvé par la recherche : il est référencé (titre + lien)
  /// et ajouté à mon historique.
  Future<ChantOuvertureEntity> vu(ChantAOuvrir cible) {
    final corps = switch (cible) {
      OuvrirVideo(:final video) => {
          'titre': video.titre,
          'source': 'youtube',
          'embed_id': video.embedId,
          if (video.artiste != null) 'artiste': video.artiste,
          if (video.thumb != null) 'thumb': video.thumb,
        },
      OuvrirParoles(:final chant) => {
          'titre': chant.title,
          'source': 'paroles',
          'lyrics_id': chant.id,
          if (chant.artist.isNotEmpty) 'artiste': chant.artist,
        },
      OuvrirReference() => throw ArgumentError('Un chant référencé s\'ouvre par son identifiant.'),
    };

    return _appel((dio) => dio.post('/v1/vus', data: corps), (r) => ChantOuvertureEntity.fromJson(_map(r)));
  }

  /// J'ouvre un chant déjà référencé (clic sur son titre).
  Future<ChantOuvertureEntity> ouvrir(String uuid) => _appel(
        (dio) => dio.post('/v1/references/$uuid/ouvrir'),
        (r) => ChantOuvertureEntity.fromJson(_map(r)),
      );

  Future<List<ChantReferenceEntity>> historique({int perPage = 20}) => _liste('/v1/historique', perPage);

  Future<List<ChantReferenceEntity>> favoris({int perPage = 50}) => _liste('/v1/favoris', perPage);

  Future<List<ChantReferenceEntity>> _liste(String chemin, int perPage) => _appel(
        (dio) => dio.get(chemin, queryParameters: {'per_page': perPage}),
        (r) => ApiResponseParser.extractList(r.data).map(ChantReferenceEntity.fromJson).toList(),
      );

  /// Chants du moment : regardés par plusieurs personnes différentes (anonyme).
  Future<List<ChantReferenceEntity>> tendances() => _appel(
        (dio) => dio.get('/v1/tendances'),
        (r) => ((_map(r)['chants'] as List?) ?? const [])
            .whereType<Map>()
            .map((e) => ChantReferenceEntity.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
      );

  Future<void> ajouterFavori(String uuid) => _appel((dio) => dio.put('/v1/favoris/$uuid'), (_) {});

  Future<void> retirerFavori(String uuid) => _appel((dio) => dio.delete('/v1/favoris/$uuid'), (_) {});

  Future<void> retirerDeLHistorique(String uuid) => _appel((dio) => dio.delete('/v1/historique/$uuid'), (_) {});

  Future<void> signaler(String uuid, {String? motif}) => _appel(
        (dio) => dio.post('/v1/signalements', data: {'reference': uuid, if (motif != null) 'motif': motif}),
        (_) {},
      );
}
