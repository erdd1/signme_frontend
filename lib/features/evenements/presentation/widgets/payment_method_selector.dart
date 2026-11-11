import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../providers/contribution_form_provider.dart';

/// Choix du moyen de paiement : Mobile Money ou carte bancaire.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({super.key, required this.selected, required this.onChanged});

  /// [ContributionFormState.methodMobileMoney] ou [ContributionFormState.methodCard].
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
            isSelected: selected == ContributionFormState.methodMobileMoney,
            onTap: () => onChanged(ContributionFormState.methodMobileMoney),
          ),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: _MethodOption(
            icon: Icons.credit_card_rounded,
            title: 'Carte bancaire',
            subtitle: 'Visa · Mastercard',
            isSelected: selected == ContributionFormState.methodCard,
            onTap: () => onChanged(ContributionFormState.methodCard),
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
            color: isSelected ? SignmeColors.primaryLight.withValues(alpha: 0.08) : SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(
              color: isSelected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(icon, color: isSelected ? SignmeColors.primaryLight : SignmeColors.darkGray, size: 26),
                  if (isSelected)
                    const Icon(Icons.check_circle_rounded, color: SignmeColors.primaryLight, size: 18),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
