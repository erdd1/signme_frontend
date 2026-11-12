import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';
import 'gestion_action.dart';

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool peutGererEvenements(UserEntity user) => actionsGestionEvenement(user).isNotEmpty;

/// Actions disponibles pour [user], avec exactement les droits de l'ancien menu :
/// créer = pasteur/secrétaire ; gérer et contributions = pasteur/secrétaire/trésorier.
List<GestionAction> actionsGestionEvenement(UserEntity user) => [
      if (AppPermissions.canManageEvenements(user))
        const GestionAction(
          id: 'creer',
          titre: 'Créer un événement',
          description: 'Lancer une collecte de fonds pour l\'église',
          icone: Icons.add_circle_outline_rounded,
          route: AppRoutes.evenementCreate,
        ),
      if (AppPermissions.canViewContributionsEvenement(user)) ...const [
        GestionAction(
          id: 'gerer',
          titre: 'Gérer les événements',
          description: 'Actifs et archivés, montant collecté, nombre de contributeurs',
          icone: Icons.event_note_rounded,
          route: AppRoutes.gestionEvenements,
        ),
        GestionAction(
          id: 'contributions',
          titre: 'Contributions événement',
          description: 'Suivi des contributions reçues, par événement',
          icone: Icons.payments_rounded,
          route: AppRoutes.contributionsEvenement,
        ),
      ],
    ];
