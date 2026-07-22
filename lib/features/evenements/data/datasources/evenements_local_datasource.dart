import 'package:isar/isar.dart';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/evenement_isar_model.dart';
import '../../domain/entities/evenement_entity.dart';

/// Datasource local — Événements (Isar).
///
/// Aucune suppression n'est jamais exposée côté backend pour les événements
/// publiés (traçabilité légale) — seule exception : un événement planifié
/// jamais publié peut être annulé/supprimé définitivement (cf.
/// [deleteByUuid]), d'où la présence ponctuelle d'une purge de cache.
class EvenementsLocalDataSource {
  /// Retourne tous les événements du cache, triés par date de mise à jour
  /// décroissante.
  Future<List<EvenementEntity>> getAll() async {
    final models = await IsarService.evenements
        .where()
        .anyId()
        .sortByUpdatedAtDesc()
        .findAll();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<EvenementEntity?> getByUuid(String uuid) async {
    final model = await IsarService.evenements.getByServerUuid(uuid);
    return model?.toEntity();
  }

  /// Retourne les événements en cache dont le statut figure dans [statuts]
  /// (utilisé par la vue "Gérer les événements", filtrée par statut).
  Future<List<EvenementEntity>> getByStatuts(List<String> statuts) async {
    final all = await getAll();
    return all.where((e) => statuts.contains(e.statut)).toList();
  }

  Future<void> saveAll(List<EvenementEntity> entities) async {
    final models = entities.map(EvenementIsarModel.fromEntity).toList();
    await IsarService.instance.writeTxn(() async {
      await IsarService.evenements.putAllByIndex(r'serverUuid', models);
    });
  }

  Future<void> save(EvenementEntity entity) async {
    final model = EvenementIsarModel.fromEntity(entity);
    await IsarService.instance.writeTxn(() async {
      await IsarService.evenements.putByServerUuid(model);
    });
  }

  /// Supprime un événement du cache par son UUID (annulation d'un événement
  /// planifié pas encore publié — cf. EvenementService::cancelScheduledPublication).
  Future<void> deleteByUuid(String uuid) async {
    await IsarService.instance.writeTxn(() async {
      await IsarService.evenements.deleteByServerUuid(uuid);
    });
  }

  Future<bool> get hasCache async => await IsarService.evenements.count() > 0;

  /// Date de mise à jour la plus récente en cache (pour la sync delta).
  Future<DateTime?> get latestUpdatedAt async {
    final models = await IsarService.evenements
        .where()
        .anyId()
        .sortByUpdatedAtDesc()
        .findAll();
    return models.isEmpty ? null : models.first.updatedAt;
  }
}
