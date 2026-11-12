import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/errors/exceptions.dart';
import 'package:signme/core/network/dio_client.dart';
import 'package:signme/features/chants/data/datasources/chants_hub_session.dart';
import 'package:signme/features/chants/data/datasources/chants_remote_datasource.dart';
import 'package:signme/features/chants/domain/entities/chant_entity.dart';
import 'package:signme/features/chants/domain/entities/chant_hub_entities.dart';

/// Adaptateur Dio scripté : aucune requête réseau, chaque réponse est décidée
/// par le test, et chaque requête reçue est enregistrée.
class _Scripte implements HttpClientAdapter {
  _Scripte(this._reponse);

  final ResponseBody Function(RequestOptions options, int numero) _reponse;
  final List<RequestOptions> recues = [];

  /// En-tête d'autorisation vu AU MOMENT de chaque requête (l'objet de requête est réutilisé au rejeu).
  final List<Object?> auths = [];

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async {
    recues.add(options);
    auths.add(options.headers['Authorization']);
    return _reponse(options, recues.length);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(Object corps, [int statut = 200]) => ResponseBody.fromString(
      jsonEncode(corps),
      statut,
      headers: {Headers.contentTypeHeader: ['application/json']},
    );

Map<String, dynamic> _jeton(String valeur, {int expireDans = 900}) => {
      'success': true,
      'message': 'ok',
      'data': {'token': valeur, 'expires_in': expireDans, 'hub_url': 'https://chants.test'},
    };

({ChantsHubSession session, _Scripte principal, _Scripte hub}) _monter({
  required ResponseBody Function(RequestOptions, int) principal,
  required ResponseBody Function(RequestOptions, int) hub,
}) {
  final scripteP = _Scripte(principal);
  final scripteH = _Scripte(hub);
  final mainDio = Dio(BaseOptions(baseUrl: 'https://api.test'))..httpClientAdapter = scripteP;
  final session = ChantsHubSession(
    mainDio,
    hubDioBuilder: (url, auth) => buildHubDioClient(url, auth: auth)..httpClientAdapter = scripteH,
  );

  return (session: session, principal: scripteP, hub: scripteH);
}

void main() {
  group('ChantsHubSession — jeton et adresse du hub', () {
    test('le jeton est réutilisé tant qu\'il est valide : un seul appel à l\'API principale', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (_, __) => _json({'success': true, 'message': 'ok', 'data': {'references': []}}),
      );
      final remote = ChantsRemoteDataSource(m.session);

      await remote.search('grace');
      await remote.search('alleluia');

      expect(m.principal.recues, hasLength(1));
      expect(m.principal.recues.single.path, '/chants/token');
      expect(m.hub.auths, everyElement('Bearer JETON-1'));
      expect(m.hub.recues.first.uri.toString(), startsWith('https://chants.test/v1/recherche'));
    });

    test('un jeton sur le point d\'expirer est renouvelé avant de casser une requête', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n', expireDans: 30)), // sous la marge de 60 s
        hub: (_, __) => _json({'success': true, 'message': 'ok', 'data': {'references': []}}),
      );
      final remote = ChantsRemoteDataSource(m.session);

      await remote.search('grace');
      await remote.search('grace');

      expect(m.principal.recues, hasLength(2));
    });

    test('plusieurs écrans qui demandent en même temps ne déclenchent qu\'un seul renouvellement', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (_, __) => _json({'success': true, 'message': 'ok', 'data': {'references': []}}),
      );
      final remote = ChantsRemoteDataSource(m.session);

      await Future.wait([remote.search('a1'), remote.search('b2'), remote.tendances()]);

      expect(m.principal.recues, hasLength(1));
    });

    test('un 401 du hub renouvelle le jeton et rejoue la requête UNE fois', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (options, n) => n == 1
            ? _json({'success': false, 'message': 'Jeton invalide ou expiré.'}, 401)
            : _json({'success': true, 'message': 'ok', 'data': {'references': []}}),
      );

      final resultat = await ChantsRemoteDataSource(m.session).search('grace');

      expect(resultat.estVide, isTrue);
      expect(m.principal.recues, hasLength(2));
      expect(m.hub.auths, ['Bearer JETON-1', 'Bearer JETON-2']);
    });

    test('un 401 persistant échoue proprement, sans boucle infinie', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (_, __) => _json({'success': false, 'message': 'Jeton invalide ou expiré.'}, 401),
      );

      await expectLater(ChantsRemoteDataSource(m.session).search('grace'), throwsA(isA<AppException>()));

      expect(m.hub.recues, hasLength(2)); // la requête + UN rejeu
      expect(m.principal.recues, hasLength(2));
    });

    test('hub désactivé côté serveur (503 sur le jeton) : message clair, jamais d\'appel au hub', () async {
      final m = _monter(
        principal: (_, __) => _json({'success': false, 'message': 'Le répertoire de chants est momentanément indisponible.'}, 503),
        hub: (_, __) => _json({}),
      );

      await expectLater(
        ChantsRemoteDataSource(m.session).search('grace'),
        throwsA(isA<ServerException>().having((e) => e.message, 'message', contains('momentanément indisponible'))),
      );
      expect(m.hub.recues, isEmpty);
    });

    test('hub arrêté : erreur réseau typée (l\'écran affiche « indisponible », le reste de l\'app continue)', () async {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (options, _) => throw DioException(requestOptions: options, type: DioExceptionType.connectionError),
      );

      await expectLater(ChantsRemoteDataSource(m.session).search('grace'), throwsA(isA<NetworkException>()));
    });
  });

  group('ChantsRemoteDataSource — enregistrer ce que le chrétien regarde', () {
    ({ChantsRemoteDataSource remote, _Scripte hub}) monter() {
      final m = _monter(
        principal: (_, n) => _json(_jeton('JETON-$n')),
        hub: (_, __) => _json({
          'success': true,
          'message': 'ok',
          'data': {'uuid': 'u-1', 'titre': 'Grand est ton amour', 'source': 'youtube', 'embed_id': 'abcdefghijk', 'disponible': true, 'favori': false},
        }),
      );

      return (remote: ChantsRemoteDataSource(m.session), hub: m.hub);
    }

    test('une vidéo trouvée est envoyée avec son identifiant, jamais son contenu', () async {
      final m = monter();

      final ouverture = await m.remote.vu(const OuvrirVideo(
        ChantVideoEntity(embedId: 'abcdefghijk', titre: 'Grand est ton amour', artiste: 'Chorale', thumb: 'https://i.ytimg.com/x.jpg'),
      ));

      final requete = m.hub.recues.single;
      expect(requete.method, 'POST');
      expect(requete.path, '/v1/vus');
      expect(requete.data, {
        'titre': 'Grand est ton amour',
        'source': 'youtube',
        'embed_id': 'abcdefghijk',
        'artiste': 'Chorale',
        'thumb': 'https://i.ytimg.com/x.jpg',
      });
      expect(ouverture.embedId, 'abcdefghijk');
    });

    test('des paroles trouvées sont envoyées avec leur identifiant', () async {
      final m = monter();

      await m.remote.vu(OuvrirParoles(ChantSummaryEntity(id: 77, title: 'Chant', artist: '', excerpt: const [], versions: const [])));

      expect(m.hub.recues.single.data, {'titre': 'Chant', 'source': 'paroles', 'lyrics_id': 77});
    });

    test('une page web gardée depuis le navigateur est envoyée avec son titre et son lien', () async {
      final m = monter();

      await m.remote.vu(const OuvrirWeb(titre: 'Cantique 12', url: 'https://exemple.org/cantique/12'));

      expect(m.hub.recues.single.data, {'titre': 'Cantique 12', 'source': 'web', 'url': 'https://exemple.org/cantique/12'});
    });

    test('un chant déjà référencé s\'ouvre par son identifiant, pas par « vu »', () async {
      final m = monter();

      expect(() => m.remote.vu(const OuvrirReference('u-1')), throwsArgumentError);
      await m.remote.ouvrir('u-1');

      expect(m.hub.recues.single.path, '/v1/references/u-1/ouvrir');
    });
  });

  group('Entités du hub', () {
    test('une recherche mélange chants référencés, vidéos et paroles', () {
      final r = ChantsSearchResult.fromJson({
        'references': [
          {'uuid': 'a', 'source': 'youtube', 'titre': 'Louange', 'artiste': null, 'thumb': null, 'favori': true, 'lien_casse': false},
        ],
        'videos': [
          {'embed_id': 'VID', 'titre': 'Vidéo', 'artiste': 'Chaîne', 'thumb': 'https://x/y.jpg'},
        ],
        'paroles': [
          {'lyrics_id': 5, 'titre': 'Paroles', 'artiste': 'Auteur', 'extrait': ['ligne'], 'versions': []},
        ],
        'partiel': true,
        'mention': 'Mention du serveur',
      });

      expect(r.references.single.favori, isTrue);
      expect(r.references.single.source, ChantSource.youtube);
      expect(r.videos.single.embedId, 'VID');
      expect(r.paroles.single.id, 5);
      expect(r.paroles.single.title, 'Paroles');
      expect(r.partiel, isTrue);
      expect(r.mention, 'Mention du serveur');
      expect(r.estVide, isFalse);
      expect(const ChantsSearchResult().estVide, isTrue);
    });

    test('une source inconnue est traitée comme une page web', () {
      expect(ChantSource.parse('autre'), ChantSource.web);
      expect(ChantSource.parse(null), ChantSource.web);
    });

    test('une vidéo supprimée est annoncée indisponible', () {
      final o = ChantOuvertureEntity.fromJson({
        'uuid': 'u', 'titre': 'T', 'source': 'youtube', 'embed_id': 'VID', 'disponible': false, 'statut_lien': 'casse', 'favori': true,
      });

      expect(o.disponible, isFalse);
      expect(o.favori, isTrue);
      expect(o.copyWith(favori: false).favori, isFalse);
      expect(o.copyWith(favori: false).embedId, 'VID');
    });

    test('des champs vides du serveur deviennent absents, pas des chaînes vides', () {
      final c = ChantReferenceEntity.fromJson({'uuid': 'a', 'source': 'web', 'titre': 'T', 'artiste': '  ', 'thumb': ''});

      expect(c.artiste, isNull);
      expect(c.thumb, isNull);
    });
  });
}
