import '../../domain/entities/badge_count_entity.dart';

/// Modèle de données — Désérialise la réponse JSON du backend
///
/// Format attendu :
/// ```json
/// {
///   "success": true,
///   "data": {
///     "publications": 3,
///     "historique": 2,
///     "historique_signatures": 1
///   }
/// }
/// ```
class BadgeCountModel {
  const BadgeCountModel({
    required this.publications,
    required this.evenements,
    required this.historique,
    required this.historiqueSignatures,
  });

  final int publications;
  final int evenements;
  final int historique;
  final int historiqueSignatures;

  factory BadgeCountModel.fromJson(Map<String, dynamic> json) {
    return BadgeCountModel(
      publications: (json['publications'] as num?)?.toInt() ?? 0,
      evenements: (json['evenements'] as num?)?.toInt() ?? 0,
      historique: (json['historique'] as num?)?.toInt() ?? 0,
      historiqueSignatures:
          (json['historique_signatures'] as num?)?.toInt() ?? 0,
    );
  }

  BadgeCountEntity toEntity() => BadgeCountEntity(
        publications: publications,
        evenements: evenements,
        historique: historique,
        historiqueSignatures: historiqueSignatures,
      );
}
