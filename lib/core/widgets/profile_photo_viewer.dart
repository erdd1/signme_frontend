import 'package:flutter/material.dart';
import '../design_system/index.dart';
import '../utils/photo_url_utils.dart';

/// Affiche la photo de profil en plein écran (zoom).
class ProfilePhotoViewer {
  ProfilePhotoViewer._();

  static void show(
    BuildContext context, {
    required String photoUrl,
    String? title,
  }) {
    final url = profilePhotoDisplayUrl(photoUrl);
    if (url.isEmpty) return;

    showDialog<void>(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) {
        // Taille relative à l'écran (et non fixée à 280) pour que le zoom
        // profite de l'espace disponible sur tablette plutôt que de rester
        // un petit carré perdu au centre.
        final screenSize = MediaQuery.of(ctx).size;
        final viewerSize = (screenSize.shortestSide * 0.8).clamp(240.0, 600.0);
        return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(SignmeSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null && title.isNotEmpty) ...[
              Text(
                title,
                style: SignmeTypography.labelLarge.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: SignmeSpacing.md),
            ],
            ClipRRect(
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Image.network(
                  url,
                  fit: BoxFit.contain,
                  width: viewerSize,
                  height: viewerSize,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return SizedBox(
                      width: viewerSize,
                      height: viewerSize,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: SignmeColors.primaryLight,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (_, __, ___) => Container(
                    width: viewerSize,
                    height: viewerSize,
                    color: SignmeColors.accentSky,
                    child: const Icon(
                      Icons.broken_image_rounded,
                      size: 48,
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Fermer',
                style: SignmeTypography.labelMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        );
      },
    );
  }
}
