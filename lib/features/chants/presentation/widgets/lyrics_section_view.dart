import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/chant_entity.dart';

/// Un bloc de paroles. Le refrain est mis en valeur (fond bleu pâle + filet
/// d'accent) ; les strophes portent leur numéro.
class LyricsSectionView extends StatelessWidget {
  const LyricsSectionView({
    super.key,
    required this.section,
    required this.textScale,
    this.strophe,
  });

  final LyricsSectionEntity section;
  final double textScale;

  /// Numéro de la strophe (1, 2, 3…) — null pour un refrain.
  final int? strophe;

  @override
  Widget build(BuildContext context) {
    final isRefrain = section.type == LyricsSectionType.refrain;
    final label = isRefrain ? 'Refrain' : 'Strophe $strophe';

    final lyricsStyle = SignmeTypography.bodyLarge.copyWith(
      fontSize: 17 * textScale,
      height: 1.6,
      color: SignmeColors.onSurface,
      fontWeight: isRefrain ? FontWeight.w600 : FontWeight.w400,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: isRefrain ? SignmeColors.accentSky.withValues(alpha: 0.6) : SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: isRefrain
            ? const Border(left: BorderSide(color: SignmeColors.primaryLight, width: 4))
            : Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: SignmeTypography.labelSmall.copyWith(
              color: isRefrain ? SignmeColors.primaryLight : SignmeColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(section.text, style: lyricsStyle),
        ],
      ),
    );
  }
}
