import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/celebrations_local_datasource.dart';
import '../../data/datasources/celebrations_remote_datasource.dart';
import '../../domain/entities/celebration_entity.dart';

final celebrationsRemoteDataSourceProvider = Provider<CelebrationsRemoteDataSource>((ref) {
  return CelebrationsRemoteDataSource(ref.watch(dioProvider));
});

final celebrationsLocalDataSourceProvider = Provider<CelebrationsLocalDataSource>((ref) {
  return CelebrationsLocalDataSource();
});

final celebrationsProvider =
    StateNotifierProvider<CelebrationsNotifier, AsyncValue<List<CelebrationEntity>>>(
  (ref) => CelebrationsNotifier(
    ref.watch(celebrationsRemoteDataSourceProvider),
    ref.watch(celebrationsLocalDataSourceProvider),
  ),
);

/// Nombre de célébrations non lues — alimente un éventuel badge.
final unreadCelebrationsCountProvider = Provider<int>((ref) {
  final list = ref.watch(celebrationsProvider).asData?.value ?? const [];
  return list.where((c) => !c.isRead).length;
});

/// Résout une célébration par uuid pour la boîte de dialogue (deep-link
/// push) — cherche d'abord dans la liste déjà en mémoire (instantané), sinon
/// va la chercher directement (ex. notification tapée avant tout chargement
/// de la liste).
final celebrationByUuidProvider =
    FutureProvider.family<CelebrationEntity, String>((ref, uuid) async {
  final cached = ref.read(celebrationsProvider).asData?.value;
  final found = cached?.where((c) => c.uuid == uuid).firstOrNull;
  if (found != null) return found;

  return ref.read(celebrationsRemoteDataSourceProvider).fetchByUuid(uuid);
});

class CelebrationsNotifier extends StateNotifier<AsyncValue<List<CelebrationEntity>>> {
  CelebrationsNotifier(this._remote, this._local) : super(const AsyncValue.loading()) {
    load();
  }

  final CelebrationsRemoteDataSource _remote;
  final CelebrationsLocalDataSource _local;

  /// Hydrate depuis le cache Isar (si présent) puis rafraîchit depuis le
  /// réseau — pattern offline-first identique à Finances/AboutChurch.
  Future<void> load() async {
    final cachedRaw = await _local.getList();
    if (cachedRaw != null) {
      try {
        state = AsyncValue.data(_parseAndSort(cachedRaw));
      } catch (_) {
        // Cache corrompu/format obsolète : ignoré, on retombe sur le réseau.
      }
    }
    if (!state.hasValue) state = const AsyncValue.loading();
    await _fetchAndSet();
  }

  Future<void> refresh() => _fetchAndSet();

  Future<void> _fetchAndSet() async {
    try {
      final raw = await _remote.fetchListRaw();
      await _local.saveList(raw);
      state = AsyncValue.data(_parseAndSort(raw));
    } catch (e, st) {
      // Réseau en échec : si une donnée (cache ou précédent succès) est déjà
      // affichée, on la conserve plutôt que d'écraser par un écran d'erreur.
      if (!state.hasValue) state = AsyncValue.error(e, st);
    }
  }

  List<CelebrationEntity> _parseAndSort(List<Map<String, dynamic>> raw) {
    final items = raw.map(CelebrationEntity.fromJson).toList();
    items.sort((a, b) => b.occursOn.compareTo(a.occursOn));
    return items;
  }

  Future<void> markRead(String uuid) async {
    try {
      await _remote.markRead(uuid);
    } catch (_) {
      // Échec réseau : on marque quand même localement pour l'UX (le
      // prochain refresh se resynchronisera avec le serveur).
    }
    final current = state.asData?.value;
    if (current == null) return;
    state = AsyncValue.data([
      for (final c in current)
        if (c.uuid == uuid) c.copyWith(isRead: true) else c,
    ]);
  }
}
