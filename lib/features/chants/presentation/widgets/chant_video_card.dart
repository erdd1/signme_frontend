import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/chant_hub_entities.dart';

/// Vidéo YouTube trouvée par la recherche : grande vignette, bouton lecture,
/// titre et chaîne. Elle est lue dans l'app (lecteur officiel intégré).
class ChantVideoCard extends StatelessWidget {
  const ChantVideoCard({super.key, required this.video, required this.onTap});

  final ChantVideoEntity video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Lire la vidéo ${video.titre}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(color: SignmeColors.accentSky),
                    if (video.thumb != null)
                      CachedNetworkImage(
                        imageUrl: video.thumb!,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.55),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 34),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(SignmeSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                    ),
                    if (video.artiste != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        video.artiste!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
