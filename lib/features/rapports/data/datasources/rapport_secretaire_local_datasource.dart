import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Rapport Secrétaire (Isar SyncCache).
///
/// Clé : "rapport_secretaire_{month}" → JSON brut de RapportSecretaireEntity.
class RapportSecretaireLocalDataSource {
  String _key(String month) => 'rapport_secretaire_$month';

  /// Retourne le rapport brut en cache pour [month], ou null.
  Future<Map<String, dynamic>?> get(String month) async {
    final entry = await IsarService.cache.getByCacheKey(_key(month));
    if (entry == null) return null;
    return jsonDecode(entry.jsonData) as Map<String, dynamic>?;
  }

  /// Sauvegarde le rapport brut pour [month].
  Future<void> save(String month, Map<String, dynamic> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _key(month)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
