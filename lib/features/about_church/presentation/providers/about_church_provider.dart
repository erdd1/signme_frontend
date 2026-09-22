import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/datasources/about_church_local_datasource.dart';
import '../../data/datasources/about_church_remote_data_source.dart';
import '../../domain/entities/about_article_entity.dart';
import '../../domain/entities/about_church_payload_entity.dart';
import '../../domain/entities/church_about_info_entity.dart';
final aboutChurchRemoteDataSourceProvider = Provider<AboutChurchRemoteDataSource>((ref) {
  return AboutChurchRemoteDataSource(ref.watch(dioProvider));
});

final aboutChurchLocalDataSourceProvider = Provider<AboutChurchLocalDataSource>((ref) {
  return AboutChurchLocalDataSource();
});

/// Filtre de catégorie actuellement sélectionné dans la barre — purement
/// local (aucun appel réseau au changement de filtre, voir specs : "ce sont
/// des filtres, pas des pages différentes").
final aboutChurchCategoryFilterProvider = StateProvider<String>((ref) => AboutChurchCategory.all);

/// Valeurs possibles du filtre de catégorie.
abstract final class AboutChurchCategory {
  static const all = 'all';
  static const pastor = AboutArticleEntity.typePastor;
  static const group = AboutArticleEntity.typeGroup;
  static const activity = AboutArticleEntity.typeActivity;
}

final aboutChurchProvider =
    StateNotifierProvider<AboutChurchNotifier, AsyncValue<AboutChurchPayloadEntity>>(
  (ref) => AboutChurchNotifier(
    ref.watch(aboutChurchRemoteDataSourceProvider),
    ref.watch(aboutChurchLocalDataSourceProvider),
  ),
);

class AboutChurchNotifier extends StateNotifier<AsyncValue<AboutChurchPayloadEntity>> {
  AboutChurchNotifier(this._remote, this._local) : super(const AsyncValue.loading()) {
    load();
  }

  final AboutChurchRemoteDataSource _remote;
  final AboutChurchLocalDataSource _local;

  /// Hydrate depuis le cache Isar (si présent) puis rafraîchit depuis le
  /// réseau — même pattern offline-first que Finances/Évènements : jamais
  /// d'écran d'erreur plein écran tant qu'une donnée en cache existe.
  Future<void> load() async {
    final cachedRaw = await _local.getPayload();
    if (cachedRaw != null) {
      try {
        state = AsyncValue.data(AboutChurchPayloadEntity.fromJson(cachedRaw));
      } catch (_) {
        // Cache corrompu/format obsolète : ignoré, on retombe sur le réseau.
      }
    }
    if (!state.hasValue) state = const AsyncValue.loading();
    await _fetchAndSet();
  }

  Future<void> refresh() async {
    await _fetchAndSet();
  }

  Future<void> _fetchAndSet() async {
    try {
      final raw = await _remote.fetchRaw();
      await _local.savePayload(raw);
      state = AsyncValue.data(AboutChurchPayloadEntity.fromJson(raw));
    } catch (e, st) {
      // Réseau en échec : si une donnée (cache ou précédent succès) est déjà
      // affichée, on la conserve plutôt que d'écraser par un écran d'erreur.
      if (!state.hasValue) state = AsyncValue.error(e, st);
    }
  }

  // ── Mutations — chacune rafraîchit le payload complet après succès pour
  // rester cohérente avec les règles serveur (quotas d'épinglage, ordre) ──

  Future<ChurchAboutInfoEntity> updateInfo(Map<String, dynamic> body) async {
    final info = await _remote.updateInfo(body);
    await refresh();
    return info;
  }

  Future<AboutArticleEntity> createArticle({
    required String type,
    required String titre,
    required String contenu,
    String? statutPasteur,
    List<File> images = const [],
  }) async {
    final article = await _remote.createArticle(
      type: type,
      titre: titre,
      contenu: contenu,
      statutPasteur: statutPasteur,
      images: images,
    );
    await refresh();
    return article;
  }

  Future<AboutArticleEntity> updateArticle({
    required String uuid,
    String? titre,
    String? contenu,
    String? statutPasteur,
    bool photosTouched = false,
    List<String> keepImages = const [],
    List<File> images = const [],
  }) async {
    final article = await _remote.updateArticle(
      uuid: uuid,
      titre: titre,
      contenu: contenu,
      statutPasteur: statutPasteur,
      photosTouched: photosTouched,
      keepImages: keepImages,
      images: images,
    );
    await refresh();
    return article;
  }

  Future<void> deleteArticle(String uuid) async {
    await _remote.deleteArticle(uuid);
    await refresh();
  }

  Future<void> pinArticle(String uuid) async {
    await _remote.pinArticle(uuid);
    await refresh();
  }

  Future<void> unpinArticle(String uuid) async {
    await _remote.unpinArticle(uuid);
    await refresh();
  }
}
