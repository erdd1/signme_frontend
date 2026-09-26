import '../../domain/entities/badge_count_entity.dart';

/// Modèle de données — Désérialise la réponse JSON du backend
///
/// Format attendu :
/// ```json
/// {
///   "success": true,
///   "data": {
///     "annonces": 1,
///     "meditations": 2,
///     "evenements": 0,
///     "historique": 2,
///     "historique_signatures": 1
///   }
/// }
/// ```
class BadgeCountModel {
  const BadgeCountModel({
    required this.annonces,
    required this.meditations,
    required this.evenements,
    required this.historique,
    required this.historiqueSignatures,
  });

  final int annonces;
  final int meditations;
  final int evenements;
  final int historique;
  final int historiqueSignatures;

  factory BadgeCountModel.fromJson(Map<String, dynamic> json) {
    return BadgeCountModel(
      annonces: (json['annonces'] as num?)?.toInt() ?? 0,
      meditations: (json['meditations'] as num?)?.toInt() ?? 0,
      evenements: (json['evenements'] as num?)?.toInt() ?? 0,
      historique: (json['historique'] as num?)?.toInt() ?? 0,
      historiqueSignatures:
          (json['historique_signatures'] as num?)?.toInt() ?? 0,
    );
  }

  BadgeCountEntity toEntity() => BadgeCountEntity(
        annonces: annonces,
        meditations: meditations,
        evenements: evenements,
        historique: historique,
        historiqueSignatures: historiqueSignatures,
      );
}
