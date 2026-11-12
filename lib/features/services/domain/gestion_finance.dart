import 'package:flutter/material.dart';

import '../../../core/permissions/app_permissions.dart';
import '../../../core/router/app_router.dart';
import '../../auth/domain/entities/user_entity.dart';
import 'gestion_action.dart';

/// Le service est proposé à qui peut utiliser au moins une de ses actions.
bool peutGererFinances(UserEntity user) => actionsGestionFinance(user).isNotEmpty;

/// Actions disponibles pour [user], avec exactement les droits de l'ancien menu
/// (pasteur et trésorier).
List<GestionAction> actionsGestionFinance(UserEntity user) => [
      if (AppPermissions.canViewFinances(user))
        const GestionAction(
          id: 'finances',
          titre: 'Finances',
          description: 'Rapport annuel et comparaison des années',
          icone: Icons.insights_rounded,
          route: AppRoutes.finances,
          estOnglet: true,
        ),
      if (AppPermissions.canViewSortiesFinancieres(user))
        const GestionAction(
          id: 'sorties',
          titre: 'Sorties financières',
          description: 'Registre des retraits effectués',
          icone: Icons.receipt_long_rounded,
          route: AppRoutes.sortiesFinancieres,
        ),
      if (AppPermissions.canViewRetraits(user))
        const GestionAction(
          id: 'retraits',
          titre: 'Retraits',
          description: 'Retirer l\'argent vers Orange Money ou MTN Mobile Money',
          icone: Icons.account_balance_wallet_rounded,
          route: AppRoutes.retraits,
        ),
    ];
