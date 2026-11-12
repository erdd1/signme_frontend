/// Version d'un chant (même titre, autre interprète ou album).
class ChantVersionEntity {
  const ChantVersionEntity({
    required this.id,
    required this.artist,
    this.album,
    this.durationSeconds,
  });

  final int id;
  final String artist;
  final String? album;
  final int? durationSeconds;

  factory ChantVersionEntity.fromJson(Map<String, dynamic> json) {
    return ChantVersionEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      durationSeconds: (json['duration'] as num?)?.toInt(),
    );
  }
}

/// Chant tel qu'affiché dans les résultats de recherche (sans paroles
/// complètes) : un extrait suffit pour reconnaître le chant.
class ChantSummaryEntity {
  const ChantSummaryEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.excerpt,
    required this.versions,
  });

  final int id;
  final String title;
  final String artist;
  final List<String> excerpt;
  final List<ChantVersionEntity> versions;

  /// Résultat « paroles » du hub : mêmes données, clés en français.
  factory ChantSummaryEntity.fromHub(Map<String, dynamic> json) {
    return ChantSummaryEntity(
      id: (json['lyrics_id'] as num?)?.toInt() ?? 0,
      title: json['titre']?.toString() ?? '',
      artist: json['artiste']?.toString() ?? '',
      excerpt: (json['extrait'] as List? ?? const []).map((e) => e.toString()).toList(),
      versions: (json['versions'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => ChantVersionEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }

  factory ChantSummaryEntity.fromJson(Map<String, dynamic> json) {
    return ChantSummaryEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      excerpt: (json['excerpt'] as List? ?? const []).map((e) => e.toString()).toList(),
      versions: (json['versions'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => ChantVersionEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

enum LyricsSectionType { strophe, refrain }

/// Bloc de paroles : une strophe ou un refrain.
class LyricsSectionEntity {
  const LyricsSectionEntity({required this.type, required this.lines});

  final LyricsSectionType type;
  final List<String> lines;

  factory LyricsSectionEntity.fromJson(Map<String, dynamic> json) {
    return LyricsSectionEntity(
      type: json['type'] == 'refrain' ? LyricsSectionType.refrain : LyricsSectionType.strophe,
      lines: (json['lines'] as List? ?? const []).map((e) => e.toString()).toList(),
    );
  }

  String get text => lines.join('\n');
}

/// Chant complet : paroles découpées en strophes/refrains + autres versions.
class ChantDetailEntity {
  const ChantDetailEntity({
    required this.id,
    required this.title,
    required this.artist,
    required this.sections,
    required this.versions,
    required this.sourceName,
    this.album,
    this.durationSeconds,
  });

  final int id;
  final String title;
  final String artist;
  final String? album;
  final int? durationSeconds;
  final List<LyricsSectionEntity> sections;
  final List<ChantVersionEntity> versions;
  final String sourceName;

  factory ChantDetailEntity.fromJson(Map<String, dynamic> json) {
    final source = json['source'];
    return ChantDetailEntity(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title']?.toString() ?? '',
      artist: json['artist']?.toString() ?? '',
      album: json['album']?.toString(),
      durationSeconds: (json['duration'] as num?)?.toInt(),
      sections: (json['sections'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => LyricsSectionEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      versions: (json['versions'] as List? ?? const [])
          .whereType<Map>()
          .map((e) => ChantVersionEntity.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      sourceName: source is Map ? source['nom']?.toString() ?? '' : '',
    );
  }

  /// Paroles complètes en texte brut (copie / partage).
  String get plainText => sections.map((s) => s.text).join('\n\n');
}
