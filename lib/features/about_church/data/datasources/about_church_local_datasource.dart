import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — payload "À propos de mon Église" (Isar SyncCache).
///
/// Une seule entrée en cache : le payload dépend uniquement de l'église de
/// l'utilisateur connecté (jamais partagé entre comptes — purgé au logout
/// comme le reste du cache via [IsarService.clearAll]).
class AboutChurchLocalDataSource {
  static const _key = 'about_church_payload';

  Future<Map<String, dynamic>?> getPayload() async {
    final entry = await IsarService.cache.getByCacheKey(_key);
    if (entry == null) return null;
    return jsonDecode(entry.jsonData) as Map<String, dynamic>?;
  }

  Future<void> savePayload(Map<String, dynamic> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _key
      ..jsonData = jsonEncode(data)
      ..cachedAt = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
