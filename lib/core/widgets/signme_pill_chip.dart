import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// PILL CHIP - Chip pilule sélectionnable (filtre mois, etc.)
///
/// Pleine bleue + coche quand sélectionnée, blanche bordée sinon.
/// Remplace les `ChoiceChip` Material par défaut pour un rendu plus moderne
/// et cohérent avec le reste du design system.
///
/// Usage:
/// ```dart
/// SignmePillChip(
///   label: 'Tous',
///   selected: true,
///   onTap: () {},
/// )
/// ```
class SignmePillChip extends StatelessWidget {
  const SignmePillChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  /// Contenu optionnel avant le libellé (ex. emoji, icône).
  final String? leading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: SignmeSpacing.animationFast,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? SignmeColors.primaryLight : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
          border: Border.all(
            color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: Colors.white),
              const SizedBox(width: 4),
            ] else if (leading != null) ...[
              Text(leading!, style: const TextStyle(fontSize: 13)),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: SignmeTypography.labelSmall.copyWith(
                color: selected ? Colors.white : SignmeColors.darkGray,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
