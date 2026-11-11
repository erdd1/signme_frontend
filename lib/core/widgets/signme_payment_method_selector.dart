import 'package:flutter/material.dart';

import '../design_system/index.dart';

/// Valeurs `paymentMethod` échangées avec l'API de paiement.
abstract final class SignmePaymentMethod {
  static const mobileMoney = 'mobile_money';
  static const card = 'card';
}

/// Choix du moyen de paiement : Mobile Money ou carte bancaire. Partagé par
/// les contributions, les dons et les signatures à distance.
class SignmePaymentMethodSelector extends StatelessWidget {
  const SignmePaymentMethodSelector(
      {super.key, required this.selected, required this.onChanged});

  /// [SignmePaymentMethod.mobileMoney] ou [SignmePaymentMethod.card].
  final String selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodOption(
            icon: Icons.smartphone_rounded,
            title: 'Mobile Money',
            subtitle: 'Orange · MTN',
            isSelected: selected == SignmePaymentMethod.mobileMoney,
            onTap: () => onChanged(SignmePaymentMethod.mobileMoney),
          ),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: _MethodOption(
            icon: Icons.credit_card_rounded,
            title: 'Carte bancaire',
            subtitle: 'Visa · Mastercard',
            isSelected: selected == SignmePaymentMethod.card,
            onTap: () => onChanged(SignmePaymentMethod.card),
          ),
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title, $subtitle',
      button: true,
      selected: isSelected,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: SignmeSpacing.animationFast,
          padding: const EdgeInsets.all(SignmeSpacing.md),
          decoration: BoxDecoration(
            color: isSelected
                ? SignmeColors.primaryLight.withValues(alpha: 0.08)
                : SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(
              color: isSelected
                  ? SignmeColors.primaryLight
                  : SignmeColors.lightGrayBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon,
                      color: isSelected
                          ? SignmeColors.primaryLight
                          : SignmeColors.darkGray,
                      size: 26),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded,
                        color: SignmeColors.primaryLight, size: 18),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelSmall
                    .copyWith(color: SignmeColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
