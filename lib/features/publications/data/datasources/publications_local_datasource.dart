import 'package:isar/isar.dart';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/publication_isar_model.dart';
import '../../domain/entities/publication_entity.dart';

/// Datasource local â€” Publications (Isar).
///
/// Fournit les opÃ©rations CRUD sur le cache local des publications.
/// AppelÃ© par les providers en lecture (fallback offline) et en Ã©criture
/// (mise Ã  jour du cache aprÃ¨s un fetch rÃ©seau rÃ©ussi).
///
/// Note technique Isar 3.x :
///   - Pour les champs @Index(unique) : utiliser les mÃ©thodes gÃ©nÃ©rÃ©es
///     [getByServerId] / [putByServerId] / [deleteByServerId].
///   - Pour les requÃªtes filtrÃ©es non-uniques : [filter()] + [sortByXxx()]
///     pour activer les mÃ©thodes terminales (Ã©tat [QAfterSortBy]).
class PublicationsLocalDataSource {
  // â”€â”€ Lecture â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Retourne toutes les publications du cache, filtrÃ©es par [type] si fourni.
  /// TriÃ©es par [updatedAt] dÃ©croissant.
  Future<List<PublicationEntity>> getAll({String? type}) async {
    List<PublicationIsarModel> models;

    if (type != null && type.isNotEmpty) {
      // type n'est pas indexÃ© â†’ filter() + sortBy (QAfterSortBy a findAll)
      models = await IsarService.publications
          .filter()
          .typeEqualTo(type)
          .sortByUpdatedAtDesc()
          .findAll();
    } else {
      // Tous les enregistrements triÃ©s par updatedAt
      models = await IsarService.publications
          .where()
          .anyId()
          .sortByUpdatedAtDesc()
          .findAll();
    }

    return models.map((m) => m.toEntity()).toList();
  }

  /// Retourne une publication par son id backend.
  /// Utilise [getByServerId] â€” mÃ©thode gÃ©nÃ©rÃ©e pour l'index unique.
  Future<PublicationEntity?> getById(int serverId) async {
    final model = await IsarService.publications.getByServerId(serverId);
    return model?.toEntity();
  }

  // â”€â”€ Ã‰criture â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Sauvegarde (upsert) une liste de publications dans Isar.
  ///
  /// Utilise [putAllByIndex] via [putByServerId] pour l'upsert sur l'index
  /// unique [serverId], Ã©vitant ainsi les doublons.
  Future<void> saveAll(List<PublicationEntity> entities) async {
    final models = entities.map(PublicationIsarModel.fromEntity).toList();
    await IsarService.instance.writeTxn(() async {
      await IsarService.publications.putAllByIndex(r'serverId', models);
    });
  }

  /// Applique un delta distant: upsert des publications actives et purge
  /// des publications supprimees cote serveur.
  Future<void> applyRemoteChanges(
    List<PublicationEntity> entities,
    List<int> deletedServerIds,
  ) async {
    final models = entities.map(PublicationIsarModel.fromEntity).toList();
    await IsarService.instance.writeTxn(() async {
      if (models.isNotEmpty) {
        await IsarService.publications.putAllByIndex(r'serverId', models);
      }
      if (deletedServerIds.isNotEmpty) {
        await IsarService.publications.deleteAllByIndex(
          r'serverId',
          deletedServerIds.map((id) => [id]).toList(),
        );
      }
    });
  }

  /// Sauvegarde (upsert) une seule publication.
  Future<void> save(PublicationEntity entity) async {
    final model = PublicationIsarModel.fromEntity(entity);
    await IsarService.instance.writeTxn(() async {
      await IsarService.publications.putByServerId(model);
    });
  }

  /// Supprime une publication du cache par son id backend.
  Future<void> deleteByServerId(int serverId) async {
    await IsarService.instance.writeTxn(() async {
      await IsarService.publications.deleteByServerId(serverId);
    });
  }

  // â”€â”€ Utilitaires â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  /// Retourne [true] si le cache contient au moins une publication.
  Future<bool> get hasCache async =>
      await IsarService.publications.count() > 0;

  /// Date de la publication la plus rÃ©cente (pour sync delta).
  Future<DateTime?> get latestUpdatedAt async {
    final models = await IsarService.publications
        .where()
        .anyId()
        .sortByUpdatedAtDesc()
        .findAll();
    return models.isEmpty ? null : models.first.updatedAt;
  }
}
