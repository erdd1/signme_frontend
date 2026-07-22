import 'package:isar/isar.dart';

part 'sync_cache_isar_model.g.dart';

/// Collection Isar générique pour les données complexes (Ma Carte, Historique,
/// Anciens…).
///
/// Pattern clé-valeur :
///   - [cacheKey]  → identifiant unique de l'entrée, p.ex. "ma_carte_2026"
///   - [jsonData]  → payload JSON sérialisé de l'API (String)
///   - [cachedAt]  → horodatage du dernier rafraîchissement
///
/// Ce modèle générique évite de créer un schéma Isar complet pour chaque
/// feature dont les données ne nécessitent pas de requêtes complexes.
@collection
class SyncCacheIsarModel {
  Id id = Isar.autoIncrement;

  /// Clé unique de l'entrée de cache.
  /// Convention : "{feature}_{paramètres}", p.ex. "historique_perso_2026-06".
  @Index(unique: true, replace: true)
  late String cacheKey;

  /// Payload JSON encodé en chaîne (via `jsonEncode`).
  late String jsonData;

  /// Horodatage du dernier rafraîchissement depuis le backend.
  DateTime cachedAt = DateTime.now();
}
