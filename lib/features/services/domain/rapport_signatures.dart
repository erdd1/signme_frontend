import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';
import 'gestion_action.dart';

/// Type de badge des signatures non vues (voir `BadgeNotifier.markRead`).
const badgeHistoriqueSignatures = 'historique_signatures';

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool peutVoirRapportSignatures(UserEntity user) => actionsRapportSignatures(user).isNotEmpty;

/// Actions disponibles pour [user], avec exactement les droits de l'ancien menu :
/// historique = pasteur/ancien ; rapport secrétaire = pasteur/secrétaire.
List<GestionAction> actionsRapportSignatures(UserEntity user) => [
      if (AppPermissions.canViewHistoriqueSignatures(user))
        const GestionAction(
          id: 'historique',
          titre: 'Historique signatures',
          description: 'Signatures effectuées par les membres',
          icone: Icons.history_edu_rounded,
          route: AppRoutes.historiqueSignatures,
          badgeType: badgeHistoriqueSignatures,
        ),
      if (AppPermissions.canViewRapportSecretaire(user))
        const GestionAction(
          id: 'rapport',
          titre: 'Rapport secrétaire',
          description: 'Qui a signé et qui n\'a pas signé, montant collecté',
          icone: Icons.assignment_rounded,
          route: AppRoutes.rapportSecretaire,
        ),
    ];
