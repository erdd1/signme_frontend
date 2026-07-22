import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Historique Personnel (Isar SyncCache).
///
/// Clés : "historique_perso_{year}_{month}_{status}"
/// Stocke la liste combinée (distance + présentiel) en JSON.
///
/// Note technique Isar 3.x : pour un champ @Index(unique), utiliser les méthodes
/// générées [getByCacheKey] / [putByCacheKey] plutôt que les QueryBuilders
/// qui exposent [findFirst] / [count] uniquement via l'état [QAfterSortBy].
class HistoriquePersoLocalDataSource {
  // ── Clé de cache ─────────────────────────────────────────────────────────

  String _key(Map<String, dynamic> filters) {
    final year   = filters['year']   ?? 'all';
    final month  = filters['month']  ?? 'all';
    final status = filters['status'] ?? 'all';
    return 'historique_perso_${year}_${month}_$status';
  }

  // ── Lecture ───────────────────────────────────────────────────────────────

  /// Retourne la liste JSON en cache pour les [filters] donnés, ou null.
  Future<List<Map<String, dynamic>>?> get(Map<String, dynamic> filters) async {
    final entry = await IsarService.cache.getByCacheKey(_key(filters));
    if (entry == null) return null;
    final list = jsonDecode(entry.jsonData) as List;
    return list.cast<Map<String, dynamic>>();
  }

  // ── Écriture ──────────────────────────────────────────────────────────────

  /// Sauvegarde la liste combinée distance+présentiel en cache.
  Future<void> save(
      Map<String, dynamic> filters, List<Map<String, dynamic>> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _key(filters)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }

  /// Retourne [true] si un cache existe pour ces [filters].
  Future<bool> has(Map<String, dynamic> filters) async {
    final entry = await IsarService.cache.getByCacheKey(_key(filters));
    return entry != null;
  }
}
