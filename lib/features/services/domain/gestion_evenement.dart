import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';

/// Une action du service « Gestion événement ». Chaque action ouvre l'écran
/// qui existait déjà dans le menu : seul leur REGROUPEMENT a changé, jamais ce
/// qu'elles font ni qui y a droit.
class GestionEvenementAction {
  const GestionEvenementAction({
    required this.id,
    required this.titre,
    required this.description,
    required this.icone,
    required this.route,
  });

  final String id;
  final String titre;
  final String description;
  final IconData icone;
  final String route;
}

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool peutGererEvenements(UserEntity user) =>
    AppPermissions.canManageEvenements(user) || AppPermissions.canViewContributionsEvenement(user);

/// Actions disponibles pour [user], avec exactement les droits de l'ancien menu :
/// créer = pasteur/secrétaire ; gérer et contributions = pasteur/secrétaire/trésorier.
List<GestionEvenementAction> actionsGestionEvenement(UserEntity user) => [
      if (AppPermissions.canManageEvenements(user))
        const GestionEvenementAction(
          id: 'creer',
          titre: 'Créer un événement',
          description: 'Lancer une collecte de fonds pour l\'église',
          icone: Icons.add_circle_outline_rounded,
          route: AppRoutes.evenementCreate,
        ),
      if (AppPermissions.canViewContributionsEvenement(user)) ...const [
        GestionEvenementAction(
          id: 'gerer',
          titre: 'Gérer les événements',
          description: 'Actifs et archivés, montant collecté, nombre de contributeurs',
          icone: Icons.event_note_rounded,
          route: AppRoutes.gestionEvenements,
        ),
        GestionEvenementAction(
          id: 'contributions',
          titre: 'Contributions événement',
          description: 'Suivi des contributions reçues, par événement',
          icone: Icons.payments_rounded,
          route: AppRoutes.contributionsEvenement,
        ),
      ],
    ];
