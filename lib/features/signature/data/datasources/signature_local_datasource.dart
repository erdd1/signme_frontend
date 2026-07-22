import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';

/// Datasource local — Ma Carte & Historique Signatures (Isar SyncCache).
///
/// Clés :
///   - "ma_carte_{year}"       → données MaCarteData (JSON)
///   - "historique_sig_p{page}" → page d'historique signatures (JSON list)
///
/// Note technique Isar 3.x : utiliser [getByCacheKey] / [putByCacheKey]
/// générés automatiquement pour les champs @Index(unique).
class SignatureLocalDataSource {
  // ── Ma Carte ─────────────────────────────────────────────────────────────

  String _maCarteKey(int year) => 'ma_carte_$year';

  /// Retourne les données brutes JSON de Ma Carte pour [year], ou null.
  Future<Map<String, dynamic>?> getMaCarte(int year) async {
    final entry = await IsarService.cache.getByCacheKey(_maCarteKey(year));
    if (entry == null) return null;
    return jsonDecode(entry.jsonData) as Map<String, dynamic>?;
  }

  /// Sauvegarde les données JSON brutes de Ma Carte pour [year].
  Future<void> saveMaCarte(int year, Map<String, dynamic> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _maCarteKey(year)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }

  // ── Historique Signatures ─────────────────────────────────────────────────

  String _histSigKey(Map<String, dynamic> filters) {
    final year   = filters['year']   ?? 'all';
    final status = filters['status'] ?? 'all';
    return 'historique_sig_${year}_$status';
  }

  /// Retourne la liste brute JSON de l'historique signatures pour [filters].
  Future<List<Map<String, dynamic>>?> getHistoriqueSignatures(
      Map<String, dynamic> filters) async {
    final entry = await IsarService.cache.getByCacheKey(_histSigKey(filters));
    if (entry == null) return null;
    final list = jsonDecode(entry.jsonData) as List;
    return list.cast<Map<String, dynamic>>();
  }

  /// Sauvegarde l'historique signatures correspondant à [filters].
  Future<void> saveHistoriqueSignatures(
      Map<String, dynamic> filters, List<Map<String, dynamic>> data) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _histSigKey(filters)
      ..jsonData  = jsonEncode(data)
      ..cachedAt  = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }

  // ── Utilitaires ────────────────────────────────────────────────────────

  /// Retourne [true] si un cache Ma Carte existe pour [year].
  Future<bool> hasMaCarte(int year) async {
    final entry = await IsarService.cache.getByCacheKey(_maCarteKey(year));
    return entry != null;
  }
}
