import 'dart:convert';
import '../../../../core/local/isar_service.dart';
import '../../../../core/local/models/sync_cache_isar_model.dart';
import '../../domain/entities/contribution_entity.dart';
import '../models/contribution_model.dart';

/// Datasource local — Contributions événement (Isar SyncCache).
///
/// Clé : "contributions_treasury_all" → JSON brut (liste) de la vue
/// trésorerie ("Contributions événement", pasteur/secrétaire/trésorier).
class ContributionsLocalDataSource {
  static const _treasuryKey = 'contributions_treasury_all';

  /// Retourne les contributions en cache, ou `null` si aucun cache.
  Future<List<ContributionEntity>?> getTreasury() async {
    final entry = await IsarService.cache.getByCacheKey(_treasuryKey);
    if (entry == null) return null;
    final list = jsonDecode(entry.jsonData) as List;
    return list
        .cast<Map<String, dynamic>>()
        .map(ContributionModel.fromJson)
        .map((m) => m.toEntity())
        .toList();
  }

  /// Sauvegarde le JSON brut de la vue trésorerie.
  Future<void> saveTreasury(List<Map<String, dynamic>> rawList) async {
    final entry = SyncCacheIsarModel()
      ..cacheKey = _treasuryKey
      ..jsonData = jsonEncode(rawList)
      ..cachedAt = DateTime.now();
    await IsarService.instance.writeTxn(() async {
      await IsarService.cache.putByCacheKey(entry);
    });
  }
}
