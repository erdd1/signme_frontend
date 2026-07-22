import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:signme/core/design_system/index.dart';

/// Reusable Onboarding/Welcome Section with illustration
class OnboardingSection extends StatelessWidget {
  final String svgPath;
  final String title;
  final String description;
  final double height;

  const OnboardingSection({
    Key? key,
    required this.svgPath,
    required this.title,
    required this.description,
    this.height = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
      child: Column(
        children: [
          // Illustration container
          Container(
            width: double.infinity,
            height: height,
            decoration: BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              border: Border.all(
                color: SignmeColors.lightGrayBorder,
                width: 1,
              ),
            ),
            child: Center(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Largeur relative à la carte (et non fixée à 160) pour
                  // que l'illustration profite de l'espace disponible sur
                  // tablette au lieu de rester minuscule.
                  final svgWidth = (constraints.maxWidth * 0.45).clamp(120.0, 220.0);
                  return SvgPicture.asset(
                    svgPath,
                    width: svgWidth,
                    height: height - 20,
                    fit: BoxFit.contain,
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: SignmeSpacing.lg),

          // Welcome text
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: SignmeTypography.labelLarge.copyWith(
                  color: SignmeColors.black,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                description,
                style: SignmeTypography.bodySmall.copyWith(
                  color: SignmeColors.darkGray,
                  height: 1.4,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
