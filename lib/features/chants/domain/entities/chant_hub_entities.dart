import 'chant_entity.dart';

/// Origine d'un chant référencé.
enum ChantSource {
  youtube,
  paroles,
  web;

  static ChantSource parse(String? value) => switch (value) {
        'youtube' => ChantSource.youtube,
        'paroles' => ChantSource.paroles,
        _ => ChantSource.web,
      };

  String get apiValue => name;

  String get label => switch (this) {
        ChantSource.youtube => 'Vidéo',
        ChantSource.paroles => 'Paroles',
        ChantSource.web => 'Site web',
      };
}

/// Chant déjà référencé (un titre et un lien — jamais le contenu).
class ChantReferenceEntity {
  const ChantReferenceEntity({
    required this.uuid,
    required this.source,
    required this.titre,
    this.artiste,
    this.thumb,
    this.favori = false,
    this.lienCasse = false,
    this.personnes,
  });

  final String uuid;
  final ChantSource source;
  final String titre;
  final String? artiste;
  final String? thumb;
  final bool favori;
  final bool lienCasse;

  /// Tendances : nombre de personnes différentes (anonyme).
  final int? personnes;

  ChantReferenceEntity copyWith({bool? favori}) => ChantReferenceEntity(
        uuid: uuid,
        source: source,
        titre: titre,
        artiste: artiste,
        thumb: thumb,
        favori: favori ?? this.favori,
        lienCasse: lienCasse,
        personnes: personnes,
      );

  factory ChantReferenceEntity.fromJson(Map<String, dynamic> json) => ChantReferenceEntity(
        uuid: json['uuid']?.toString() ?? '',
        source: ChantSource.parse(json['source']?.toString()),
        titre: json['titre']?.toString() ?? '',
        artiste: _nonVide(json['artiste']),
        thumb: _nonVide(json['thumb']),
        favori: json['favori'] == true,
        lienCasse: json['lien_casse'] == true,
        personnes: (json['personnes'] as num?)?.toInt(),
      );
}

/// Vidéo YouTube proposée par la recherche (pas encore référencée : elle le
/// devient quand le chrétien la regarde).
class ChantVideoEntity {
  const ChantVideoEntity({required this.embedId, required this.titre, this.artiste, this.thumb});

  final String embedId;
  final String titre;
  final String? artiste;
  final String? thumb;

  factory ChantVideoEntity.fromJson(Map<String, dynamic> json) => ChantVideoEntity(
        embedId: json['embed_id']?.toString() ?? '',
        titre: json['titre']?.toString() ?? '',
        artiste: _nonVide(json['artiste']),
        thumb: _nonVide(json['thumb']),
      );
}

/// Résultat d'une recherche : chants déjà référencés, vidéos, paroles.
class ChantsSearchResult {
  const ChantsSearchResult({
    this.references = const [],
    this.videos = const [],
    this.paroles = const [],
    this.partiel = false,
    this.mention = '',
  });

  final List<ChantReferenceEntity> references;
  final List<ChantVideoEntity> videos;
  final List<ChantSummaryEntity> paroles;

  /// Une source externe n'a pas répondu : le reste est affiché quand même.
  final bool partiel;
  final String mention;

  bool get estVide => references.isEmpty && videos.isEmpty && paroles.isEmpty;

  factory ChantsSearchResult.fromJson(Map<String, dynamic> json) => ChantsSearchResult(
        references: _liste(json['references']).map(ChantReferenceEntity.fromJson).toList(),
        videos: _liste(json['videos']).map(ChantVideoEntity.fromJson).toList(),
        paroles: _liste(json['paroles']).map(ChantSummaryEntity.fromHub).toList(),
        partiel: json['partiel'] == true,
        mention: json['mention']?.toString() ?? '',
      );
}

/// Comment ouvrir un chant : lecteur YouTube, paroles ou page web.
class ChantOuvertureEntity {
  const ChantOuvertureEntity({
    required this.uuid,
    required this.titre,
    required this.source,
    this.artiste,
    this.url,
    this.embedId,
    this.lyricsId,
    this.thumb,
    this.disponible = true,
    this.mention = '',
    this.favori = false,
  });

  final String uuid;
  final String titre;
  final String? artiste;
  final ChantSource source;
  final String? url;
  final String? embedId;
  final int? lyricsId;
  final String? thumb;

  /// false = la source n'existe plus (vidéo supprimée, lien cassé).
  final bool disponible;
  final String mention;
  final bool favori;

  ChantOuvertureEntity copyWith({bool? favori}) => ChantOuvertureEntity(
        uuid: uuid,
        titre: titre,
        source: source,
        artiste: artiste,
        url: url,
        embedId: embedId,
        lyricsId: lyricsId,
        thumb: thumb,
        disponible: disponible,
        mention: mention,
        favori: favori ?? this.favori,
      );

  factory ChantOuvertureEntity.fromJson(Map<String, dynamic> json) => ChantOuvertureEntity(
        uuid: json['uuid']?.toString() ?? '',
        titre: json['titre']?.toString() ?? '',
        source: ChantSource.parse(json['source']?.toString()),
        artiste: _nonVide(json['artiste']),
        url: _nonVide(json['url']),
        embedId: _nonVide(json['embed_id']),
        lyricsId: (json['lyrics_id'] as num?)?.toInt(),
        thumb: _nonVide(json['thumb']),
        disponible: json['disponible'] != false,
        mention: json['mention']?.toString() ?? '',
        favori: json['favori'] == true,
      );
}

/// Ce que le chrétien vient de toucher : décide quel appel enregistre la vue.
sealed class ChantAOuvrir {
  const ChantAOuvrir();
}

/// Chant déjà référencé (historique, favoris, tendances, « mes chants »).
class OuvrirReference extends ChantAOuvrir {
  const OuvrirReference(this.uuid, {this.titre});
  final String uuid;
  final String? titre;
}

/// Vidéo trouvée par la recherche.
class OuvrirVideo extends ChantAOuvrir {
  const OuvrirVideo(this.video);
  final ChantVideoEntity video;
}

/// Paroles trouvées par la recherche.
class OuvrirParoles extends ChantAOuvrir {
  const OuvrirParoles(this.chant);
  final ChantSummaryEntity chant;
}

String? _nonVide(dynamic v) {
  final s = v?.toString().trim();
  return s == null || s.isEmpty ? null : s;
}

List<Map<String, dynamic>> _liste(dynamic v) =>
    (v as List? ?? const []).whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
