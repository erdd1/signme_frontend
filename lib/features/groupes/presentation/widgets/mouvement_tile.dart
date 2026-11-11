import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/groupe_entities.dart';

/// Une ligne de l'historique de la caisse : icône d'entrée/sortie, qui, quoi,
/// montant signé. Une entrée cash annulée reste visible, barrée.
class MouvementTile extends StatelessWidget {
  const MouvementTile({super.key, required this.mouvement, this.onTap});

  final MouvementEntity mouvement;
  final VoidCallback? onTap;

  static final _date = DateFormat('dd/MM/yyyy');

  (IconData, String) get _visuel => switch (mouvement.type) {
        'cash' => (Icons.payments_rounded, 'Cash'),
        'retrait' => (Icons.call_made_rounded, 'Retrait'),
        'don' => (Icons.volunteer_activism_rounded, 'Don'),
        _ => (Icons.campaign_rounded, 'Contribution'),
      };

  @override
  Widget build(BuildContext context) {
    final (icon, type) = _visuel;
    final entree = mouvement.estEntree;
    final couleur = mouvement.annule
        ? SignmeColors.mediumGray
        : entree
            ? SignmeColors.success
            : SignmeColors.error;
    final date = DateTime.tryParse(mouvement.date)?.toLocal();
    final detail = [
      if (mouvement.libelle != null && mouvement.libelle!.isNotEmpty) mouvement.libelle!,
      if (mouvement.note != null && mouvement.note!.isNotEmpty) mouvement.note!,
    ].join(' · ');

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: couleur.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
              child: Icon(icon, size: 20, color: couleur),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mouvement.acteur?.isNotEmpty == true ? '$type — ${mouvement.acteur}' : type,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  if (detail.isNotEmpty)
                    Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                    ),
                  if (date != null)
                    Text(
                      _date.format(date),
                      style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray, fontSize: 11),
                    ),
                ],
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Text(
              '${entree ? '+' : '−'} ${FinanceFormatters.fcfaShort(mouvement.montant)}',
              style: SignmeTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w800,
                color: couleur,
                decoration: mouvement.annule ? TextDecoration.lineThrough : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
