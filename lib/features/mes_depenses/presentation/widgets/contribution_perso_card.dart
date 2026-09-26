import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/contribution_perso_entity.dart';

/// Carte "Mes dépenses" : nom événement, moyen de paiement (si mobile money),
/// montant total payé, date. La ventilation frais/contribution et la
/// référence de transaction sont un détail de gestion interne — sans intérêt
/// pour l'utilisateur, elles ne sont plus affichées ici (voir trésorerie
/// pour la vue détaillée côté pasteur/secrétaire/trésorier).
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
        'failed' => 'Paiement échoué',
        _ => 'En cours de traitement',
      };

  @override
  Widget build(BuildContext context) {
    final paymentColor = paymentOperatorColor(contribution.paymentOperator);

    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.black.withOpacity(0.4)),
      ),
      child: Row(
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
                const SizedBox(height: 6),
                Text(
                  FinanceFormatters.fcfa(contribution.montantTotal),
                  style: SignmeTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SignmeColors.black,
                  ),
                ),
                if (paymentColor != null) ...[
                  const SizedBox(height: 6),
                  SignmePaymentMethodInfo(
                    color: paymentColor,
                    label: paymentOperatorLabel(contribution.paymentOperator),
                    phoneNumber: contribution.paymentNumber,
                  ),
                ],
                const SizedBox(height: 6),
                Text(
                  DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(contribution.createdAt),
                  style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
