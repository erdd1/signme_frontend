import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';
import 'gestion_action.dart';

/// Rubriques de l'écran « Gestion actualités » (mêmes mots que le fil d'accueil).
abstract final class ActualitesSections {
  static const evenements = 'Événements';
  static const publications = 'Publications';
}

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool peutGererActualites(UserEntity user) => actionsGestionActualites(user).isNotEmpty;

/// Actions disponibles pour [user], avec exactement les droits de l'ancien menu :
/// événements : créer = pasteur/secrétaire ; gérer et contributions =
/// pasteur/secrétaire/trésorier. Publications : pasteur/secrétaire.
List<GestionAction> actionsGestionActualites(UserEntity user) => [
      if (AppPermissions.canManageEvenements(user))
        const GestionAction(
          id: 'creer',
          titre: 'Créer un événement',
          description: 'Lancer une collecte de fonds pour l\'église',
          icone: Icons.add_circle_outline_rounded,
          route: AppRoutes.evenementCreate,
          section: ActualitesSections.evenements,
        ),
      if (AppPermissions.canViewContributionsEvenement(user)) ...const [
        GestionAction(
          id: 'gerer',
          titre: 'Gérer les événements',
          description: 'Actifs et archivés, montant collecté, nombre de contributeurs',
          icone: Icons.event_note_rounded,
          route: AppRoutes.gestionEvenements,
          section: ActualitesSections.evenements,
        ),
        GestionAction(
          id: 'contributions',
          titre: 'Contributions événement',
          description: 'Suivi des contributions reçues, par événement',
          icone: Icons.payments_rounded,
          route: AppRoutes.contributionsEvenement,
          section: ActualitesSections.evenements,
        ),
      ],
      if (AppPermissions.canManagePublications(user)) ...const [
        GestionAction(
          id: 'publication-creer',
          titre: 'Nouvelle publication',
          description: 'Rédiger une annonce ou une méditation',
          icone: Icons.edit_note_rounded,
          route: AppRoutes.publicationCreate,
          section: ActualitesSections.publications,
        ),
        GestionAction(
          id: 'publications',
          titre: 'Gérer les publications',
          description: 'Annonces et méditations de votre église',
          icone: Icons.newspaper_rounded,
          route: AppRoutes.publications,
          section: ActualitesSections.publications,
        ),
      ],
    ];
