import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/chant_hub_entities.dart';

/// Ligne d'un chant référencé : vignette (ou icône de sa source), titre,
/// interprète, étoile si favori. Même langage visuel que les cartes de résultats.
class ChantReferenceTile extends StatelessWidget {
  const ChantReferenceTile({super.key, required this.chant, required this.onTap});

  final ChantReferenceEntity chant;
  final VoidCallback onTap;

  static IconData iconeDe(ChantSource source) => switch (source) {
        ChantSource.youtube => Icons.play_circle_rounded,
        ChantSource.paroles => Icons.lyrics_rounded,
        ChantSource.web => Icons.public_rounded,
      };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${chant.titre}${chant.artiste != null ? ', ${chant.artiste}' : ''}',
      child: InkWell(
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
            children: [
              _Vignette(chant: chant),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chant.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (chant.artiste != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        chant.artiste!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(iconeDe(chant.source), size: 14, color: SignmeColors.primaryLight),
                        const SizedBox(width: 4),
                        Text(
                          chant.lienCasse ? 'Source indisponible' : chant.source.label,
                          style: SignmeTypography.labelSmall.copyWith(
                            color: chant.lienCasse ? SignmeColors.error : SignmeColors.primaryLight,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (chant.personnes != null) ...[
                          const SizedBox(width: SignmeSpacing.sm),
                          Icon(Icons.local_fire_department_rounded, size: 14, color: SignmeColors.mediumGray),
                          const SizedBox(width: 2),
                          Text(
                            '${chant.personnes} personnes',
                            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (chant.favori) const Icon(Icons.star_rounded, color: Color(0xFFF5A623), size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _Vignette extends StatelessWidget {
  const _Vignette({required this.chant});

  final ChantReferenceEntity chant;

  @override
  Widget build(BuildContext context) {
    final fallback = Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: SignmeColors.accentSky,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      ),
      child: Icon(ChantReferenceTile.iconeDe(chant.source), color: SignmeColors.primaryLight, size: 26),
    );

    if (chant.thumb == null) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      child: CachedNetworkImage(
        imageUrl: chant.thumb!,
        width: 56,
        height: 56,
        fit: BoxFit.cover,
        placeholder: (_, __) => fallback,
        errorWidget: (_, __, ___) => fallback,
      ),
    );
  }
}
