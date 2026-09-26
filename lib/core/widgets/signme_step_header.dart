import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// En-tête d'un formulaire multi-étapes : barre de progression segmentée
/// (une pastille par étape) + libellé de l'étape courante — remplace un long
/// formulaire à défilement unique par un parcours guidé, une étape à la fois.
class SignmeStepHeader extends StatelessWidget {
  const SignmeStepHeader({
    super.key,
    required this.currentStep,
    required this.stepLabels,
  });

  /// Index 0-based de l'étape courante.
  final int currentStep;

  /// Un libellé par étape, dans l'ordre — sa longueur détermine le nombre
  /// de segments de la barre de progression.
  final List<String> stepLabels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var i = 0; i < stepLabels.length; i++) ...[
              if (i > 0) const SizedBox(width: SignmeSpacing.xs),
              Expanded(
                child: AnimatedContainer(
                  duration: SignmeSpacing.animationFast,
                  height: 5,
                  decoration: BoxDecoration(
                    color: i <= currentStep
                        ? SignmeColors.primaryLight
                        : SignmeColors.lightGrayBorder,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          'Étape ${currentStep + 1}/${stepLabels.length} — ${stepLabels[currentStep]}',
          style: SignmeTypography.labelMedium.copyWith(
            color: SignmeColors.primaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

/// Bouton "Retour" discret en tête d'une étape qui n'est pas la première.
class SignmeStepBackButton extends StatelessWidget {
  const SignmeStepBackButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm, vertical: SignmeSpacing.xs),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: SignmeColors.darkGray,
      ),
      icon: const Icon(Icons.arrow_back_rounded, size: 20),
      label: Text(
        'Retour',
        style: SignmeTypography.labelMedium.copyWith(
          color: SignmeColors.darkGray,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
