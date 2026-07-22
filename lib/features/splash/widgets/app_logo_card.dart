import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// App logo displayed in a square card with rounded corners.
/// Shows the logo asset; falls back to a branded icon if the asset is missing.
class AppLogoCard extends StatelessWidget {
  const AppLogoCard({super.key, this.size = 96.0});

  /// Width and height of the card.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: SignmeColors.surface,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXxl), // 24 px
        boxShadow: [
          // Soft ambient shadow
          BoxShadow(
            color: SignmeColors.primary.withOpacity(0.12),
            blurRadius: 28,
            spreadRadius: 0,
            offset: const Offset(0, 8),
          ),
          // Subtle crisp shadow for depth
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        // Thin border for a card-like premium feel
        border: Border.all(
          color: SignmeColors.lightGrayBorder,
          width: SignmeSpacing.borderThin,
        ),
      ),
      padding: EdgeInsets.all(size * 0.18), // proportional inner padding
      child: Image.asset(
        'assets/icones/logo_signme.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Icon(
          Icons.verified_user_rounded,
          size: size * 0.5,
          color: SignmeColors.primary,
        ),
      ),
    );
  }
}
