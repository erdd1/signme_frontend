import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Anciens & Désignations (Isar SyncCache).
///
/// Clés : "anciens_{mois}_{annee}"
///
/// Note technique Isar 3.x : utiliser [getByCacheKey] / [putByCacheKey]
/// générés automatiquement pour les champs @Index(unique).
class AnciensLocalDataSource {
  String _key(int mois, int annee) => 'anciens_${mois}_$annee';

  // ── Lecture ───────────────────────────────────────────────────────────────

  /// Retourne la liste JSON des anciens pour [mois]/[annee], ou null.
  Future<List<Map<String, dynamic>>?> get(int mois, int annee) async {
    final entry = await IsarService.cache.getByCacheKey(_key(mois, annee));
    if (entry == null) return null;
    final list = jsonDecode(entry.jsonData) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // ── Écriture ──────────────────────────────────────────────────────────────

  /// Sauvegarde la liste des anciens pour [mois]/[annee].
  Future<void> save(
      int mois, int annee, List<Map<String, dynamic>> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _key(mois, annee)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }

  /// Retourne [true] si un cache existe pour ce [mois]/[annee].
  Future<bool> has(int mois, int annee) async {
    final entry = await IsarService.cache.getByCacheKey(_key(mois, annee));
    return entry != null;
  }
}
