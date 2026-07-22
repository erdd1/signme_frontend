import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/evenement_entity.dart';
import 'evenement_actions_menu.dart';
import 'objectif_progress_bar.dart';

/// Carte compacte pour l'écran "Gérer les événements" — montant collecté,
/// nombre de contributeurs distincts, statut, et menu de gestion contextuel.
class EvenementGestionCard extends StatelessWidget {
  const EvenementGestionCard({super.key, required this.evenement});

  final EvenementEntity evenement;

  Color get _statutColor => switch (evenement.statut) {
        'actif' => SignmeColors.success,
        'archive' => SignmeColors.mediumGray,
        'termine' => SignmeColors.warning,
        'planifie' => SignmeColors.primaryLight,
        _ => SignmeColors.darkGray,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(color: SignmeColors.primaryDark.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  evenement.titre,
                  style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _statutColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                ),
                child: Text(
                  evenement.statutLabel,
                  style: SignmeTypography.labelSmall.copyWith(color: _statutColor, fontWeight: FontWeight.w700),
                ),
              ),
              if (evenement.peutGerer) EvenementActionsMenu(evenement: evenement),
            ],
          ),
          if (evenement.labelArchivage != null) ...[
            const SizedBox(height: 2),
            Text(
              evenement.labelArchivage!,
              style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.warning, fontWeight: FontWeight.w600),
            ),
          ],
          const Divider(height: SignmeSpacing.lg, color: SignmeColors.lightGrayBorder),
          Row(
            children: [
              Expanded(
                child: _statColumn(
                  'Montant collecté',
                  FinanceFormatters.fcfa(evenement.montantCollecte),
                  highlight: true,
                ),
              ),
              Expanded(
                child: _statColumn(
                  'Contributeurs',
                  (evenement.nombreContributeurs ?? evenement.nombreContributions).toString(),
                ),
              ),
            ],
          ),
          if (evenement.aUnObjectif) ...[
            const SizedBox(height: SignmeSpacing.md),
            ObjectifProgressBar(
              objectifMontant: evenement.objectifMontant!,
              montantCollecte: evenement.montantCollecte,
              pourcentage: evenement.pourcentageObjectif ?? 0,
            ),
          ],
        ],
      ),
    );
  }

  Widget _statColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: 2),
        Text(
          value,
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
          ),
        ),
      ],
    );
  }
}
