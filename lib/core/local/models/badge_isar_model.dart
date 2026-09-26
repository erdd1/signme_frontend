import 'package:isar/isar.dart';
import '../../../features/badge/domain/entities/badge_count_entity.dart';

part 'badge_isar_model.g.dart';

/// Collection Isar singleton pour les compteurs de badges.
///
/// Id fixe = 1 → toujours un seul enregistrement (upsert).
@collection
class BadgeIsarModel {
  /// Id fixe : on écrase toujours le même enregistrement.
  Id id = 1;

  int annonces             = 0;
  int meditations          = 0;
  int evenements          = 0;
  int historique          = 0;
  int historiqueSignatures = 0;

  // ── Conversions ─────────────────────────────────────────────────────────

  BadgeCountEntity toEntity() => BadgeCountEntity(
        annonces:            annonces,
        meditations:         meditations,
        evenements:          evenements,
        historique:          historique,
        historiqueSignatures: historiqueSignatures,
      );

  static BadgeIsarModel fromEntity(BadgeCountEntity e) {
    return BadgeIsarModel()
      ..id                  = 1
      ..annonces            = e.annonces
      ..meditations         = e.meditations
      ..evenements          = e.evenements
      ..historique          = e.historique
      ..historiqueSignatures = e.historiqueSignatures;
  }
}
