import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/contribution_perso_entity.dart';

/// Carte "Mes dépenses" : nom événement, église, montant, frais, montant
/// payé, date, statut, référence.
class ContributionPersoCard extends StatelessWidget {
  const ContributionPersoCard({super.key, required this.contribution});

  final ContributionPersoEntity contribution;

  Color get _statutColor => switch (contribution.statut) {
        'completed' => SignmeColors.success,
        'failed' => SignmeColors.error,
        _ => SignmeColors.warning,
      };

  String get _statutLabel => switch (contribution.statut) {
        'completed' => 'Payé',
        'failed' => 'Échoué',
        _ => 'En attente',
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SignmeLeadingIconAvatar(icon: Icons.volunteer_activism_rounded),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            contribution.evenementTitre ?? 'Événement',
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
                            _statutLabel,
                            style: SignmeTypography.labelSmall.copyWith(color: _statutColor, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),
                    if (contribution.eglise != null) ...[
                      const SizedBox(height: 2),
                      Text(contribution.eglise!,
                          style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: SignmeSpacing.lg, color: SignmeColors.lightGrayBorder),
          Row(
            children: [
              Expanded(child: _infoColumn('Contribution', FinanceFormatters.fcfaShort(contribution.montant))),
              Expanded(child: _infoColumn('Frais', FinanceFormatters.fcfaShort(contribution.frais))),
              Expanded(
                child: _infoColumn('Payé', FinanceFormatters.fcfaShort(contribution.montantTotal), highlight: true),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(contribution.createdAt),
            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
          ),
          if (contribution.paymentReference != null) ...[
            const SizedBox(height: 2),
            Text(
              'Réf. ${contribution.paymentReference}',
              style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: 2),
        Text(
          value,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
          ),
        ),
      ],
    );
  }
}
