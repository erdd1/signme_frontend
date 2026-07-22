import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';

/// Barre de progression vers l'objectif financier d'un événement.
class ObjectifProgressBar extends StatelessWidget {
  const ObjectifProgressBar({
    super.key,
    required this.objectifMontant,
    required this.montantCollecte,
    required this.pourcentage,
  });

  final int objectifMontant;
  final int montantCollecte;
  final double pourcentage;

  @override
  Widget build(BuildContext context) {
    final ratio = (pourcentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Objectif : ${FinanceFormatters.fcfa(objectifMontant)}',
                style: SignmeTypography.labelSmall.copyWith(
                  color: SignmeColors.darkGray,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Text(
              '${pourcentage.toStringAsFixed(0)} %',
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: SignmeSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: SignmeColors.lightGray,
            valueColor: const AlwaysStoppedAnimation(SignmeColors.primaryLight),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${FinanceFormatters.fcfa(montantCollecte)} collectés',
          style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
        ),
      ],
    );
  }
}
