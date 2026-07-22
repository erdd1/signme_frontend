import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// Widget pour les boutons d'action de la welcome page
class WelcomeActionButtons extends StatelessWidget {
  final int currentPage;
  final int totalPages;
  final VoidCallback onNext;
  final VoidCallback onSkip;

  const WelcomeActionButtons({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onNext,
    required this.onSkip,
  });

  bool get _isLastPage => currentPage == totalPages - 1;
  String get _nextButtonText => _isLastPage ? 'Commencer' : 'Suivant';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      child: Column(
        children: [
          // ── Bouton Primary (Next/Commencer) ──────────────────────────
          GestureDetector(
            onTap: onNext,
            child: Container(
              width: double.infinity,
              height: SignmeSpacing.buttonHeight,
              decoration: BoxDecoration(
                gradient: SignmeColors.buttonGradientLinear,
                 borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                boxShadow: [
                  BoxShadow(
                    color: SignmeColors.primaryDark.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  _nextButtonText,
                  style: SignmeTypography.labelLarge.copyWith(
                    color: SignmeColors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: SignmeSpacing.lg),

          // ── Bouton Secondary (Skip) ─────────────────────────────────
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Passer',
              style: SignmeTypography.labelLarge.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
