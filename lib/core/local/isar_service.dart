import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'models/publication_isar_model.dart';
import 'models/badge_isar_model.dart';
import 'models/sync_cache_isar_model.dart';
import 'models/evenement_isar_model.dart';

/// Service singleton d'accès à la base de données Isar locale.
///
/// Initialisation : appeler [IsarService.init()] dans [main()] avant
/// [runApp()]. Ensuite, accéder à l'instance via [IsarService.instance].
///
/// Toutes les collections sont ouvertes une seule fois et réutilisées
/// pendant toute la durée de vie de l'application.
class IsarService {
  IsarService._();

  static Isar? _isar;

  /// Instance Isar prête à l'emploi (après [init]).
  static Isar get instance {
    assert(_isar != null, 'Appelez IsarService.init() avant d\'utiliser instance.');
    return _isar!;
  }

  /// Initialise Isar et ouvre toutes les collections.
  /// À appeler UNE seule fois dans [main()], avant [runApp()].
  static Future<void> init() async {
    if (_isar != null && _isar!.isOpen) return; // déjà initialisé

    final dir = await getApplicationDocumentsDirectory();

    _isar = await Isar.open(
      [
        PublicationIsarModelSchema,
        BadgeIsarModelSchema,
        SyncCacheIsarModelSchema,
        EvenementIsarModelSchema,
      ],
      directory: dir.path,
      name: 'signme_offline',
    );
  }

  /// Ferme proprement la base de données (p.ex. en test).
  static Future<void> close() async {
    await _isar?.close();
    _isar = null;
  }

  /// Supprime toutes les données locales (appelé au logout).
  static Future<void> clearAll() async {
    final db = instance;
    await db.writeTxn(() async {
      await db.publicationIsarModels.clear();
      await db.badgeIsarModels.clear();
      await db.syncCacheIsarModels.clear();
      await db.evenementIsarModels.clear();
    });
  }

  // ── Raccourcis vers les collections ────────────────────────────────────────
  static IsarCollection<PublicationIsarModel> get publications =>
      instance.publicationIsarModels;

  static IsarCollection<BadgeIsarModel> get badges =>
      instance.badgeIsarModels;

  static IsarCollection<SyncCacheIsarModel> get cache =>
      instance.syncCacheIsarModels;

  static IsarCollection<EvenementIsarModel> get evenements =>
      instance.evenementIsarModels;
}
