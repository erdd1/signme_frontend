import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/groupes_remote_datasource.dart';
import '../../data/datasources/quartiers_remote_datasource.dart';
import '../../data/datasources/villes_remote_datasource.dart';

/// Notifier générique pour une liste gérée (Groupe/Quartier/Ville) : charge la
/// liste au démarrage, permet d'ajouter un nouvel élément localement après
/// création réussie (évite un rechargement réseau complet).
class LookupListNotifier<T> extends StateNotifier<AsyncValue<List<T>>> {
  LookupListNotifier(this._loader) : super(const AsyncLoading()) {
    load();
  }

  final Future<List<T>> Function() _loader;

  Future<void> load() async {
    state = const AsyncLoading();
    try {
      final items = await _loader();
      state = AsyncData(items);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  void addItem(T item) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData([...current, item]);
  }

  void removeItem(T item) {
    final current = state.valueOrNull ?? const [];
    state = AsyncData(current.where((e) => e != item).toList());
  }
}

/// Notifier générique pour l'action "créer une entrée" (bottom sheet d'ajout
/// rapide) — état de chargement/erreur séparé de la liste elle-même.
class LookupCreateNotifier<T> extends StateNotifier<AsyncValue<void>> {
  LookupCreateNotifier() : super(const AsyncData(null));

  Future<T?> submit(Future<T> Function() action) async {
    state = const AsyncLoading();
    try {
      final result = await action();
      state = const AsyncData(null);
      return result;
    } catch (e, st) {
      state = AsyncError(e, st);
      return null;
    }
  }

  String errorMessage(Object error) => messageFromError(error);
}

// ── Groupes ──────────────────────────────────────────────────────────────

final groupesRemoteDataSourceProvider = Provider<GroupesRemoteDataSource>(
  (ref) => GroupesRemoteDataSource(ref.watch(dioProvider)),
);

final groupesListProvider =
    StateNotifierProvider<LookupListNotifier<GroupeRef>, AsyncValue<List<GroupeRef>>>(
  (ref) => LookupListNotifier<GroupeRef>(
    () => ref.watch(groupesRemoteDataSourceProvider).list(),
  ),
);

final groupeCreateProvider =
    StateNotifierProvider<LookupCreateNotifier<GroupeRef>, AsyncValue<void>>(
  (ref) => LookupCreateNotifier<GroupeRef>(),
);

// ── Quartiers ────────────────────────────────────────────────────────────

final quartiersRemoteDataSourceProvider = Provider<QuartiersRemoteDataSource>(
  (ref) => QuartiersRemoteDataSource(ref.watch(dioProvider)),
);

final quartiersListProvider = StateNotifierProvider<
    LookupListNotifier<QuartierRef>, AsyncValue<List<QuartierRef>>>(
  (ref) => LookupListNotifier<QuartierRef>(
    () => ref.watch(quartiersRemoteDataSourceProvider).list(),
  ),
);

final quartierCreateProvider =
    StateNotifierProvider<LookupCreateNotifier<QuartierRef>, AsyncValue<void>>(
  (ref) => LookupCreateNotifier<QuartierRef>(),
);

// ── Villes ───────────────────────────────────────────────────────────────

final villesRemoteDataSourceProvider = Provider<VillesRemoteDataSource>(
  (ref) => VillesRemoteDataSource(ref.watch(dioProvider)),
);

final villesListProvider =
    StateNotifierProvider<LookupListNotifier<VilleRef>, AsyncValue<List<VilleRef>>>(
  (ref) => LookupListNotifier<VilleRef>(
    () => ref.watch(villesRemoteDataSourceProvider).list(),
  ),
);

final villeCreateProvider =
    StateNotifierProvider<LookupCreateNotifier<VilleRef>, AsyncValue<void>>(
  (ref) => LookupCreateNotifier<VilleRef>(),
);
