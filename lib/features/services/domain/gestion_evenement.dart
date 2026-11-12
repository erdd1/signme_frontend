import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';

/// Rubriques de l'écran « Gestion événement ».
abstract final class GestionSections {
  static const evenements = 'Événements';
  static const finances = 'Finances';
}

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
    required this.section,
    this.estOnglet = false,
  });

  final String id;
  final String titre;
  final String description;
  final IconData icone;
  final String route;
  final String section;

  /// Vrai pour un écran qui est un onglet de l'application (Finances) : on y
  /// accède comme depuis l'ancien menu, plutôt qu'en le empilant.
  final bool estOnglet;
}

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool aDesActionsGestion(UserEntity user) => actionsGestionEvenement(user).isNotEmpty;

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
          section: GestionSections.evenements,
        ),
      if (AppPermissions.canViewContributionsEvenement(user)) ...const [
        GestionEvenementAction(
          id: 'gerer',
          titre: 'Gérer les événements',
          description: 'Actifs et archivés, montant collecté, nombre de contributeurs',
          icone: Icons.event_note_rounded,
          route: AppRoutes.gestionEvenements,
          section: GestionSections.evenements,
        ),
        GestionEvenementAction(
          id: 'contributions',
          titre: 'Contributions événement',
          description: 'Suivi des contributions reçues, par événement',
          icone: Icons.payments_rounded,
          route: AppRoutes.contributionsEvenement,
          section: GestionSections.evenements,
        ),
      ],
      if (AppPermissions.canViewFinances(user))
        const GestionEvenementAction(
          id: 'finances',
          titre: 'Finances',
          description: 'Rapport annuel et comparaison des années',
          icone: Icons.insights_rounded,
          route: AppRoutes.finances,
          section: GestionSections.finances,
          estOnglet: true,
        ),
      if (AppPermissions.canViewSortiesFinancieres(user))
        const GestionEvenementAction(
          id: 'sorties',
          titre: 'Sorties financières',
          description: 'Registre des retraits effectués',
          icone: Icons.receipt_long_rounded,
          route: AppRoutes.sortiesFinancieres,
          section: GestionSections.finances,
        ),
      if (AppPermissions.canViewRetraits(user))
        const GestionEvenementAction(
          id: 'retraits',
          titre: 'Retraits',
          description: 'Retirer l\'argent vers Orange Money ou MTN Mobile Money',
          icone: Icons.account_balance_wallet_rounded,
          route: AppRoutes.retraits,
          section: GestionSections.finances,
        ),
    ];
