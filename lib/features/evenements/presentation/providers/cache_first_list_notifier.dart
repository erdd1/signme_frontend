import 'package:flutter_riverpod/flutter_riverpod.dart';

/// StateNotifier générique "cache local d'abord, puis rafraîchissement
/// silencieux" — hydrate l'état depuis [readCache] au démarrage (aucun
/// flash de chargement si des données sont déjà en cache), puis tente un
/// [fetchAndCache] réseau qui ne repasse JAMAIS par un état vide/"loading"
/// une fois que des données ont été affichées. Si le réseau échoue ou est
/// absent, les données déjà affichées restent visibles.
///
/// Réutilisé par tous les écrans de liste offline-first de ce module
/// (Gérer les événements, Contributions événement) qui n'ont pas besoin
/// d'un état plus riche que `AsyncValue<List<T>>`.
class CacheFirstListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  CacheFirstListNotifier({
    required Future<List<T>?> Function() readCache,
    required Future<List<T>> Function() fetchAndCache,
    required Future<bool> Function() isOnline,
  })  : _readCache = readCache,
        _fetchAndCache = fetchAndCache,
        _isOnline = isOnline,
        super(const AsyncLoading()) {
    _loadFromCacheThenRefresh();
  }

  final Future<List<T>?> Function() _readCache;
  final Future<List<T>> Function() _fetchAndCache;
  final Future<bool> Function() _isOnline;

  Future<void> _loadFromCacheThenRefresh() async {
    final cached = await _readCache();
    if (cached != null && cached.isNotEmpty && mounted) {
      state = AsyncData(cached);
    }
    await refresh();
  }

  /// Rafraîchit depuis le réseau (si en ligne) et persiste en cache local.
  /// Appelé à chaque ouverture d'écran / pull-to-refresh — ne marque jamais
  /// un état "loading" si des données sont déjà affichées.
  Future<void> refresh() async {
    if (!await _isOnline()) return;

    try {
      final items = await _fetchAndCache();
      if (mounted) state = AsyncData(items);
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        final cached = await _readCache();
        state = (cached != null && cached.isNotEmpty) ? AsyncData(cached) : AsyncError(e, st);
      }
      // Sinon : réseau en échec mais données déjà affichées → on les garde.
    }
  }
}
