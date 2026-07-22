import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';

/// En-tête commun login / mot de passe oublié / reset.
/// Logo affiché en asset brut (sans carte de fond), titre en gradient.
class AuthScreenHeader extends StatelessWidget {
  const AuthScreenHeader({
    super.key,
    this.title = 'SignMe',
    this.subtitle,
    this.logoSize = 120,
  });

  final String title;
  final String? subtitle;
  final double logoSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Logo brut, sans fond ───────────────────────────────────────
        Image.asset(
          SignmeAssets.logo,
          width: logoSize,
          height: logoSize,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Icon(
            Icons.verified_user_rounded,
            size: logoSize * 0.7,
            color: SignmeColors.primary,
          ),
        ),

        const SizedBox(height: SignmeSpacing.sm),

        // ── Titre en gradient bleu ────────────────────────────────────
        ShaderMask(
          shaderCallback: (bounds) => const LinearGradient(
            colors: SignmeColors.primaryGradient,
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds),
          child: Text(
            title,
            style: SignmeTypography.displaySmall.copyWith(
              color: SignmeColors.white, // doit être blanc pour ShaderMask
              fontWeight: FontWeight.w800,
              fontSize: 32,
              letterSpacing: 0.5,
            ),
          ),
        ),

        // ── Subtitle ──────────────────────────────────────────────────
        if (subtitle != null) ...[
          const SizedBox(height: SignmeSpacing.sm),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.xl),
            child: Text(
              subtitle!,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.mediumGray,
                fontSize: 14,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ],
    );
  }
}
