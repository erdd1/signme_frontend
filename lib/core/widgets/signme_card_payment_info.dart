import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// Information affichée à la place de l'opérateur et du numéro quand le
/// paiement se fait par carte : la saisie se fait sur la page sécurisée du
/// fournisseur, jamais dans SignMe.
class SignmeCardPaymentInfo extends StatelessWidget {
  const SignmeCardPaymentInfo({super.key, this.feesLabel});

  /// Frais de carte déjà formatés (ex. « 106 FCFA »), ou null s'ils sont inconnus.
  final String? feesLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
            color: SignmeColors.primaryLight.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_rounded,
                  color: SignmeColors.primaryLight, size: 20),
              const SizedBox(width: SignmeSpacing.sm),
              Text(
                'Paiement sécurisé',
                style: SignmeTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            'Vous serez redirigé vers une page sécurisée pour saisir votre carte. '
            'Vos données bancaires ne passent jamais par SignMe.',
            style: SignmeTypography.bodySmall
                .copyWith(color: SignmeColors.darkGray, height: 1.4),
          ),
          if (feesLabel != null) ...[
            const SizedBox(height: SignmeSpacing.sm),
            Text(
              'Frais de carte : $feesLabel',
              style: SignmeTypography.labelSmall
                  .copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );
  }
}
