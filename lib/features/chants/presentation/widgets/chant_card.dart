import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/chant_entity.dart';

/// Carte d'un chant dans les résultats : titre, interprète, début des
/// paroles (pour le reconnaître) et nombre de versions disponibles.
class ChantCard extends StatelessWidget {
  const ChantCard({super.key, required this.chant, required this.onTap});

  final ChantSummaryEntity chant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final versionsCount = chant.versions.length;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: SignmeColors.accentSky,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: const Icon(
                Icons.music_note_rounded,
                color: SignmeColors.primaryLight,
                size: 24,
              ),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chant.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  if (chant.artist.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      chant.artist,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.labelSmall.copyWith(
                        color: SignmeColors.primaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (chant.excerpt.isNotEmpty) ...[
                    const SizedBox(height: SignmeSpacing.sm),
                    Text(
                      chant.excerpt.join(' · '),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.bodySmall.copyWith(
                        color: SignmeColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (versionsCount > 1) ...[
                    const SizedBox(height: SignmeSpacing.sm),
                    Text(
                      '$versionsCount versions',
                      style: SignmeTypography.labelSmall.copyWith(
                        color: SignmeColors.darkGray,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            const Padding(
              padding: EdgeInsets.only(top: SignmeSpacing.md),
              child: Icon(Icons.chevron_right_rounded, color: SignmeColors.mediumGray),
            ),
          ],
        ),
      ),
    );
  }
}
