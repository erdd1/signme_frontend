import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/badge_isar_model.dart';
import '../../domain/entities/badge_count_entity.dart';

/// Datasource local — Badges (Isar).
///
/// Un seul enregistrement (id fixe = 1) est maintenu en base.
/// Toute écriture écrase la valeur précédente (comportement souhaité).
class BadgeLocalDataSource {
  // ── Lecture ──────────────────────────────────────────────────────────────

  /// Retourne les compteurs en cache, ou [BadgeCountEntity.empty] si absent.
  Future<BadgeCountEntity> get() async {
    final model = await IsarService.badges.get(1);
    return model?.toEntity() ?? BadgeCountEntity.empty;
  }

  // ── Écriture ─────────────────────────────────────────────────────────────

  /// Sauvegarde les nouveaux compteurs (toujours id=1, upsert).
  Future<void> save(BadgeCountEntity entity) async {
    await IsarService.instance.writeTxn(() async {
      await IsarService.badges.put(BadgeIsarModel.fromEntity(entity));
    });
  }

  // ── Utilitaires ──────────────────────────────────────────────────────────

  /// Retourne [true] si un cache badges existe.
  Future<bool> get hasCache async => await IsarService.badges.get(1) != null;
}
