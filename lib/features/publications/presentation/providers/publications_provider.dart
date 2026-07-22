import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/publication_entity.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import 'publications_data_providers.dart';

// ── Liste paginée — Offline-First ──────────────────────────────────────────
//
// Affiche immédiatement le cache Isar puis rafraîchit en arrière-plan, sans
// jamais repasser par un état "loading" vide une fois que des données ont
// été affichées (évite le flicker à chaque navigation/invalidation).

class PublicationsListNotifier
    extends StateNotifier<AsyncValue<List<PublicationEntity>>> {
  PublicationsListNotifier(this._ref, this._filters)
      : super(const AsyncLoading()) {
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;
  final Map<String, dynamic> _filters;

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(publicationsLocalDataSourceProvider);
    final typeFilter = _filters['type']?.toString();
    final cached = await local.getAll(type: typeFilter);
    if (cached.isNotEmpty && mounted) {
      state = AsyncData(cached);
    }
    await refresh();
  }

  /// Rafraîchit depuis l'API et persiste en cache Isar.
  Future<void> refresh() async {
    final connectivity = _ref.read(connectivityServiceProvider);
    final isOnline = await connectivity.isOnline;
    if (!isOnline) return;

    final remote = _ref.read(publicationsRemoteDataSourceProvider);
    final local = _ref.read(publicationsLocalDataSourceProvider);
    final typeFilter = _filters['type']?.toString();

    try {
      final items = await remote.list(_filters);
      final entities = items.map((m) => m.toEntity()).toList();
      await local.saveAll(entities);
      if (mounted) state = AsyncData(entities);
    } catch (e, st) {
      // Réseau en échec : on garde les données déjà affichées. On ne
      // propage l'erreur que si on n'a vraiment rien à montrer.
      if (mounted && !state.hasValue) {
        final cached = await local.getAll(type: typeFilter);
        state = cached.isNotEmpty ? AsyncData(cached) : AsyncError(e, st);
      }
    }
  }
}

final publicationsListProvider = StateNotifierProvider.family<
    PublicationsListNotifier,
    AsyncValue<List<PublicationEntity>>,
    Map<String, dynamic>>(
  (ref, filters) => PublicationsListNotifier(ref, filters),
);

// ── 5 dernières publications pour la Home ──────────────────────────────────

final homePublicationsProvider =
    Provider<AsyncValue<List<PublicationEntity>>>((ref) {
  return ref.watch(publicationsListProvider(const {'per_page': 5}));
});

// ── Détail d'une publication ────────────────────────────────────────────────

final publicationDetailProvider =
    FutureProvider.family<PublicationEntity, int>((ref, id) async {
  final remote       = ref.read(publicationsRemoteDataSourceProvider);
  final local        = ref.read(publicationsLocalDataSourceProvider);
  final connectivity = ref.read(connectivityServiceProvider);

  final isOnline = await connectivity.isOnline;

  if (isOnline) {
    try {
      final entity = (await remote.getById(id)).toEntity();
      await local.save(entity);
      return entity;
    } catch (_) {
      // Fallback cache ci-dessous
    }
  }

  final cached = await local.getById(id);
  if (cached != null) return cached;
  throw Exception('Publication non disponible hors ligne.');
});

/// Rafraîchit la liste avec les filtres courants (sans recréer le notifier,
/// pour ne pas faire clignoter l'écran avec un état loading vide).
void invalidatePublicationsList(Ref ref) {
  final filters = ref.read(publicationFiltersProvider);
  ref.read(publicationsListProvider(filters).notifier).refresh();
  ref.read(publicationsListProvider(const {'per_page': 5}).notifier).refresh();
}

class PublicationFormNotifier extends StateNotifier<AsyncValue<void>> {
  PublicationFormNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<PublicationEntity?> create({
    required String titre,
    required String contenu,
    required String type,
    String? referenceBiblique,
  }) async {
    state = const AsyncLoading();
    try {
      final remote = _ref.read(publicationsRemoteDataSourceProvider);
      final model = await remote.create({
        'titre': titre,
        'contenu': contenu,
        'type': type,
        'referenceBiblique':
            type == 'meditation' ? referenceBiblique : null,
      });
      final entity = model.toEntity();
      await _ref.read(publicationsLocalDataSourceProvider).save(entity);
      invalidatePublicationsList(_ref);
      // Rafraîchir les badges : une nouvelle pub existe pour les autres utilisateurs
      _ref.read(badgeNotifierProvider.notifier).refresh();
      state = const AsyncData(null);
      return entity;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<PublicationEntity?> update({
    required int id,
    required String titre,
    required String contenu,
    String? referenceBiblique,
    required bool isMeditation,
  }) async {
    state = const AsyncLoading();
    try {
      final remote = _ref.read(publicationsRemoteDataSourceProvider);
      final model = await remote.update(id, {
        'titre': titre,
        'contenu': contenu,
        'referenceBiblique': isMeditation ? referenceBiblique : null,
      });
      final entity = model.toEntity();
      await _ref.read(publicationsLocalDataSourceProvider).save(entity);
      _ref.invalidate(publicationDetailProvider(id));
      invalidatePublicationsList(_ref);
      state = const AsyncData(null);
      return entity;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> delete(int id) async {
    state = const AsyncLoading();
    try {
      await _ref.read(publicationsRemoteDataSourceProvider).delete(id);
      await _ref.read(publicationsLocalDataSourceProvider).deleteByServerId(id);
      _ref.invalidate(publicationDetailProvider(id));
      invalidatePublicationsList(_ref);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }
}

final publicationFormProvider =
    StateNotifierProvider<PublicationFormNotifier, AsyncValue<void>>(
  (ref) => PublicationFormNotifier(ref),
);
