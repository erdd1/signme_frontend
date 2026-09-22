import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — liste des célébrations (Isar SyncCache), même pattern
/// que Finances/AboutChurch. Une seule entrée : la liste dépend uniquement
/// de l'utilisateur connecté.
class CelebrationsLocalDataSource {
  static const _key = 'celebrations_list';

  Future<List<Map<String, dynamic>>?> getList() async {
    final entry = await IsarService.cache.getByCacheKey(_key);
    if (entry == null) return null;
    final decoded = jsonDecode(entry.jsonData) as List?;
    return decoded?.cast<Map<String, dynamic>>();
  }

  Future<void> saveList(List<Map<String, dynamic>> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _key
      ..jsonData = jsonEncode(data)
      ..cachedAt = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
