import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/onboarding_entity.dart';

/// Widget affichant une page d'onboarding
class OnboardingPage extends StatelessWidget {
  final OnboardingEntity page;
  final Animation<double> fadeAnimation;

  const OnboardingPage({
    super.key,
    required this.page,
    required this.fadeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.lg,
          vertical: SignmeSpacing.xxl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: SignmeSpacing.xl),

            // ── Onboarding illustration SVG ──────────────────────────
            // Taille relative à la largeur de l'écran (et non fixée à 280)
            // pour ne pas rester minuscule sur une tablette.
            Builder(
              builder: (context) {
                final size = (MediaQuery.of(context).size.width * 0.7).clamp(200.0, 320.0);
                return SvgPicture.asset(
                  page.imagePath,
                  width: size,
                  height: size,
                  fit: BoxFit.contain,
                );
              },
            ),

            const SizedBox(height: SignmeSpacing.xxxl),

            // ── Title ────────────────────────────────────────────────
            Text(
              page.title,
              style: SignmeTypography.displaySmall.copyWith(
                color: SignmeColors.black,
                fontWeight: FontWeight.w700,
                fontSize: 28,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: SignmeSpacing.sm),

            // ── Subtitle ─────────────────────────────────────────────
            Text(
              page.subtitle,
              style: SignmeTypography.bodyLarge.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: SignmeSpacing.lg),

            // ── Description ──────────────────────────────────────────
            Text(
              page.description,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.mediumGray,
                height: 1.6,
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
