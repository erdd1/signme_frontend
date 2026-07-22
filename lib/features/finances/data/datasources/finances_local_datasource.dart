import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Rapport Annuel Finances (Isar SyncCache).
///
/// Clé : "finances_annual_{year}" → JSON brut de RapportAnnuelEntity.
class FinancesLocalDataSource {
  String _annualKey(int year) => 'finances_annual_$year';

  /// Retourne le rapport annuel brut en cache pour [year], ou null.
  Future<Map<String, dynamic>?> getAnnual(int year) async {
    final entry = await IsarService.cache.getByCacheKey(_annualKey(year));
    if (entry == null) return null;
    return jsonDecode(entry.jsonData) as Map<String, dynamic>?;
  }

  /// Sauvegarde le rapport annuel brut pour [year].
  Future<void> saveAnnual(int year, Map<String, dynamic> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _annualKey(year)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
