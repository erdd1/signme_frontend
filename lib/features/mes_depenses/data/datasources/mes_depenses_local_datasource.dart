import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Mes dépenses (Isar SyncCache).
///
/// Clés : "mes_depenses_{annee}_{mois}" pour la liste filtrée,
/// "mes_depenses_stats" pour les statistiques (total/mois/année courants).
class MesDepensesLocalDataSource {
  String _listKey(int? annee, int? mois) => 'mes_depenses_${annee ?? 'all'}_${mois ?? 'all'}';
  String _statsKey(int? annee, int? mois) => 'mes_depenses_stats_${annee ?? 'all'}_${mois ?? 'all'}';

  Future<List<Map<String, dynamic>>?> getList(int? annee, int? mois) async {
    final entry = await IsarService.cache.getByCacheKey(_listKey(annee, mois));
    if (entry == null) return null;
    final list = jsonDecode(entry.jsonData) as List;
    return list.cast<Map<String, dynamic>>();
  }

  Future<void> saveList(int? annee, int? mois, List<Map<String, dynamic>> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _listKey(annee, mois)
      ..jsonData = jsonEncode(data)
      ..cachedAt = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }

  Future<Map<String, dynamic>?> getStats(int? annee, int? mois) async {
    final entry = await IsarService.cache.getByCacheKey(_statsKey(annee, mois));
    if (entry == null) return null;
    return jsonDecode(entry.jsonData) as Map<String, dynamic>;
  }

  Future<void> saveStats(int? annee, int? mois, Map<String, dynamic> stats) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _statsKey(annee, mois)
      ..jsonData = jsonEncode(stats)
      ..cachedAt = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
