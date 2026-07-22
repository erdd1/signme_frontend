import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/evenement_entity.dart';
import '../../domain/evenement_gestion_statuts.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/providers/connectivity_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'cache_first_list_notifier.dart';
import 'evenements_data_providers.dart';

export '../../domain/evenement_gestion_statuts.dart';

/// Liste paginée — Offline-First. Affiche le cache Isar puis rafraîchit en
/// arrière-plan (même pattern que PublicationsListNotifier).
class EvenementsListNotifier extends StateNotifier<AsyncValue<List<EvenementEntity>>> {
  EvenementsListNotifier(this._ref) : super(const AsyncLoading()) {
    _loadFromCacheThenRefresh();
  }

  final Ref _ref;

  Future<void> _loadFromCacheThenRefresh() async {
    final local = _ref.read(evenementsLocalDataSourceProvider);
    final cached = await local.getAll();
    if (cached.isNotEmpty && mounted) {
      state = AsyncData(cached);
    }
    await refresh();
  }

  Future<void> refresh() async {
    final connectivity = _ref.read(connectivityServiceProvider);
    final isOnline = await connectivity.isOnline;
    if (!isOnline) return;

    final remote = _ref.read(evenementsRemoteDataSourceProvider);
    final local = _ref.read(evenementsLocalDataSourceProvider);

    try {
      final items = await remote.list(const {'per_page': 20});
      final entities = items.map((m) => m.toEntity()).toList();
      await local.saveAll(entities);
      if (mounted) state = AsyncData(entities);
    } catch (e, st) {
      if (mounted && !state.hasValue) {
        final cached = await local.getAll();
        state = cached.isNotEmpty ? AsyncData(cached) : AsyncError(e, st);
      }
    }
  }
}

final evenementsListProvider =
    StateNotifierProvider<EvenementsListNotifier, AsyncValue<List<EvenementEntity>>>(
  (ref) => EvenementsListNotifier(ref),
);

/// Détail d'un événement (offline-first : réseau puis fallback cache).
final evenementDetailProvider = FutureProvider.family<EvenementEntity, String>((ref, uuid) async {
  final remote = ref.read(evenementsRemoteDataSourceProvider);
  final local = ref.read(evenementsLocalDataSourceProvider);
  final connectivity = ref.read(connectivityServiceProvider);

  final isOnline = await connectivity.isOnline;
  if (isOnline) {
    try {
      final entity = (await remote.getByUuid(uuid)).toEntity();
      await local.save(entity);
      return entity;
    } catch (_) {
      // fallback cache ci-dessous
    }
  }

  final cached = await local.getByUuid(uuid);
  if (cached != null) return cached;
  throw Exception('Événement non disponible hors ligne.');
});

void invalidateEvenementsList(Ref ref) {
  ref.read(evenementsListProvider.notifier).refresh();
}

/// Vue "Gérer les événements" (pasteur/secrétaire/trésorier), filtrée par
/// statut ([kEvenementsGestionActifs] | [kEvenementsGestionArchives]).
/// Offline-first : affiche le cache Isar partagé avec [evenementsListProvider]
/// (filtré localement par statut) puis rafraîchit en arrière-plan sans
/// jamais repasser par un état vide/"loading".
final evenementsGestionProvider = StateNotifierProvider.family<
    CacheFirstListNotifier<EvenementEntity>,
    AsyncValue<List<EvenementEntity>>,
    String>((ref, statut) {
  final remote = ref.watch(evenementsRemoteDataSourceProvider);
  final local = ref.watch(evenementsLocalDataSourceProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final statuts = statut.split(',');

  return CacheFirstListNotifier<EvenementEntity>(
    readCache: () => local.getByStatuts(statuts),
    fetchAndCache: () async {
      final models = await remote.listGestion(statut: statut);
      final entities = models.map((m) => m.toEntity()).toList();
      await local.saveAll(entities);
      return entities;
    },
    isOnline: () => connectivity.isOnline,
  );
});

void invalidateEvenementsGestion(Ref ref) {
  ref.read(evenementsGestionProvider(kEvenementsGestionActifs).notifier).refresh();
  ref.read(evenementsGestionProvider(kEvenementsGestionArchives).notifier).refresh();
}

/// Précharge "Gérer les événements" au login (utilisateurs autorisés).
final evenementsGestionBootstrapProvider = Provider<void>((ref) {
  ref.keepAlive();
  ref.listen<AuthState>(
    authNotifierProvider,
    (previous, next) {
      final user = next.auth?.user;
      final canView = next.isInitialized &&
          next.isAuthenticated &&
          user != null &&
          AppPermissions.canManageEvenements(user);

      if (canView) {
        Future<void>.microtask(() {
          ref.read(evenementsGestionProvider(kEvenementsGestionActifs).notifier).refresh();
          ref.read(evenementsGestionProvider(kEvenementsGestionArchives).notifier).refresh();
        });
      }
    },
    fireImmediately: true,
  );
});

/// Formulaire de création/modification d'un événement (pasteur/secrétaire).
class EvenementFormNotifier extends StateNotifier<AsyncValue<void>> {
  EvenementFormNotifier(this._ref) : super(const AsyncData(null));

  final Ref _ref;

  Future<EvenementEntity?> create({
    required String titre,
    required String description,
    required DateTime dateDebut,
    DateTime? dateFin,
    int? objectifMontant,
    required String mode, // brouillon | immediate | planifie
    DateTime? scheduledPublishAt,
    File? image,
  }) async {
    state = const AsyncLoading();
    try {
      final remote = _ref.read(evenementsRemoteDataSourceProvider);
      final model = await remote.create({
        'titre': titre,
        'description': description,
        'dateDebut': dateDebut.toIso8601String().split('T').first,
        if (dateFin != null) 'dateFin': dateFin.toIso8601String(),
        if (objectifMontant != null) 'objectifMontant': objectifMontant,
        'mode': mode,
        if (scheduledPublishAt != null)
          'scheduledPublishAt': scheduledPublishAt.toIso8601String(),
      }, image: image);
      final entity = model.toEntity();
      await _ref.read(evenementsLocalDataSourceProvider).save(entity);
      invalidateEvenementsList(_ref);
      state = const AsyncData(null);
      return entity;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<EvenementEntity?> update({
    required String uuid,
    String? titre,
    String? description,
    DateTime? dateFin,
    int? objectifMontant,
    File? image,
  }) async {
    state = const AsyncLoading();
    try {
      final remote = _ref.read(evenementsRemoteDataSourceProvider);
      final model = await remote.update(uuid, {
        if (titre != null) 'titre': titre,
        if (description != null) 'description': description,
        if (dateFin != null) 'dateFin': dateFin.toIso8601String(),
        if (objectifMontant != null) 'objectifMontant': objectifMontant,
      }, image: image);
      final entity = model.toEntity();
      await _ref.read(evenementsLocalDataSourceProvider).save(entity);
      _ref.invalidate(evenementDetailProvider(uuid));
      invalidateEvenementsList(_ref);
      state = const AsyncData(null);
      return entity;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> _applyAction(
    String uuid,
    Future<dynamic> Function(String uuid) action,
  ) async {
    state = const AsyncLoading();
    try {
      final result = await action(uuid);
      final entity = result.toEntity();
      await _ref.read(evenementsLocalDataSourceProvider).save(entity);
      _ref.invalidate(evenementDetailProvider(uuid));
      invalidateEvenementsList(_ref);
      invalidateEvenementsGestion(_ref);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> publish(String uuid) =>
      _applyAction(uuid, (u) => _ref.read(evenementsRemoteDataSourceProvider).publish(u));

  /// Annule un événement planifié pas encore publié — suppression définitive
  /// (aucune entité retournée par le backend, contrairement aux autres
  /// transitions : on purge simplement le cache local).
  Future<void> cancelScheduled(String uuid) async {
    state = const AsyncLoading();
    try {
      await _ref.read(evenementsRemoteDataSourceProvider).cancelScheduled(uuid);
      await _ref.read(evenementsLocalDataSourceProvider).deleteByUuid(uuid);
      _ref.invalidate(evenementDetailProvider(uuid));
      invalidateEvenementsList(_ref);
      invalidateEvenementsGestion(_ref);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> terminer(String uuid) =>
      _applyAction(uuid, (u) => _ref.read(evenementsRemoteDataSourceProvider).terminer(u));

  Future<void> archiver(String uuid) =>
      _applyAction(uuid, (u) => _ref.read(evenementsRemoteDataSourceProvider).archiver(u));

  Future<void> desarchiver(String uuid) =>
      _applyAction(uuid, (u) => _ref.read(evenementsRemoteDataSourceProvider).desarchiver(u));
}

final evenementFormProvider = StateNotifierProvider<EvenementFormNotifier, AsyncValue<void>>(
  (ref) => EvenementFormNotifier(ref),
);
