import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../publications/domain/entities/publication_entity.dart';
import '../../../publications/presentation/providers/publications_provider.dart';
import '../../../evenements/domain/entities/evenement_entity.dart';
import '../../../evenements/presentation/providers/evenements_provider.dart';

/// Élément du fil d'actualité — soit une publication (annonce/méditation),
/// soit un événement (module collecte de fonds). Les deux s'affichent avec
/// le même chrome visuel mais des cartes différentes (NewsCard/EvenementCard).
sealed class HomeFeedItem {
  DateTime get sortDate;
}

class HomeFeedPublication extends HomeFeedItem {
  HomeFeedPublication(this.publication);
  final PublicationEntity publication;

  @override
  DateTime get sortDate => publication.date;
}

class HomeFeedEvenement extends HomeFeedItem {
  HomeFeedEvenement(this.evenement);
  final EvenementEntity evenement;

  @override
  DateTime get sortDate => evenement.publishedAt ?? evenement.createdAt;
}

/// Catégorie d'actualité affichée dans l'onglet actif du fil Home.
///
/// Correspond 1:1 aux types de badges backend (voir BadgeService côté API :
/// annonces | meditations | evenements) — [badgeType] est directement le
/// `type` attendu par `POST /notifications/badges/mark-read`.
enum ActualiteCategory {
  evenements,
  annonces,
  meditations;

  String get badgeType => switch (this) {
        ActualiteCategory.evenements => 'evenements',
        ActualiteCategory.annonces => 'annonces',
        ActualiteCategory.meditations => 'meditations',
      };

  String get label => switch (this) {
        ActualiteCategory.evenements => 'Événements',
        ActualiteCategory.annonces => 'Annonces',
        ActualiteCategory.meditations => 'Méditations',
      };
}

/// Onglet Actualités actuellement sélectionné sur le Home — état partagé
/// entre [HomeScreen] (qui l'affiche/le modifie) et [MainShell] (qui doit
/// savoir quel badge marquer comme lu au moment où l'onglet Accueil de la
/// navbar est tapé). Par défaut "Événements", à l'image de la maquette.
final selectedActualiteCategoryProvider =
    StateProvider<ActualiteCategory>((ref) => ActualiteCategory.evenements);

/// Filtre le fil fusionné pour ne garder que les items d'une catégorie.
List<HomeFeedItem> filterHomeFeedByCategory(
  List<HomeFeedItem> items,
  ActualiteCategory category,
) {
  return items.where((item) {
    return switch (item) {
      HomeFeedEvenement() => category == ActualiteCategory.evenements,
      HomeFeedPublication(:final publication) => switch (category) {
          ActualiteCategory.annonces => publication.isAnnonce,
          ActualiteCategory.meditations => publication.isMeditation,
          ActualiteCategory.evenements => false,
        },
    };
  }).toList();
}

/// Fusionne les publications et les événements visibles dans un seul fil,
/// trié par date décroissante (le plus récent en premier).
final homeFeedProvider = Provider<AsyncValue<List<HomeFeedItem>>>((ref) {
  final publicationsAsync = ref.watch(homePublicationsProvider);
  final evenementsAsync = ref.watch(evenementsListProvider);

  // Le fil affiche les données dès que l'une des deux sources est prête,
  // sans jamais bloquer sur l'autre si elle échoue (chaque module reste
  // indépendant : une panne d'un module n'empêche pas l'affichage de l'autre).
  final publications = publicationsAsync.valueOrNull ?? const <PublicationEntity>[];
  final evenements = (evenementsAsync.valueOrNull ?? const <EvenementEntity>[])
      .where((e) => e.isActif || e.isTermine)
      .toList();

  if (publicationsAsync.isLoading && evenementsAsync.isLoading &&
      publications.isEmpty && evenements.isEmpty) {
    return const AsyncLoading();
  }

  final items = <HomeFeedItem>[
    ...publications.map(HomeFeedPublication.new),
    ...evenements.map(HomeFeedEvenement.new),
  ]..sort((a, b) => b.sortDate.compareTo(a.sortDate));

  if (items.isEmpty && publicationsAsync.hasError && evenementsAsync.hasError) {
    return AsyncError(publicationsAsync.error!, publicationsAsync.stackTrace!);
  }

  return AsyncData(items);
});

/// Contrôleur de défilement de l'écran d'accueil — tenu en vie tant que
/// [HomeScreen] est affiché (via `ref.watch`). Permet à [MainShell] de
/// remonter le fil en haut lorsque l'utilisateur retape sur l'item "Accueil"
/// de la navbar alors qu'il est déjà sur cet onglet (même geste que
/// WhatsApp sur l'item "Discussions").
final homeScrollControllerProvider = Provider.autoDispose<ScrollController>((ref) {
  final controller = ScrollController();
  ref.onDispose(controller.dispose);
  return controller;
});
