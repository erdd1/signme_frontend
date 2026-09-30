import 'dart:io';
import 'package:flutter/material.dart';
import '../design_system/index.dart';
import '../utils/photo_url_utils.dart';
import 'profile_photo_viewer.dart';

/// Avatar cliquable : aperçu photo au tap, modification via l'icône appareil.
class ProfilePhotoAvatar extends StatelessWidget {
  const ProfilePhotoAvatar({
    super.key,
    this.photoUrl,
    this.localFile,
    this.displayName,
    this.radius = 32,
    this.onChangePhoto,
    this.showViewerOnTap = true,
    this.bustNetworkCache, // FIX: Renommé pour correspondre à l'appel dans profile_screen.dart
  });

  final String? photoUrl;
  final File? localFile;
  final String? displayName;
  final double radius;
  final VoidCallback? onChangePhoto;
  final bool showViewerOnTap;

  /// Token stable (ms epoch) fixé une fois après upload — pas à chaque rebuild.
  final int? bustNetworkCache;

  @override
  Widget build(BuildContext context) {
    final resolvedUrl = normalizePhotoUrl(photoUrl);
    String? networkUrl;
    if (resolvedUrl != null) {
      networkUrl = profilePhotoDisplayUrl(resolvedUrl);
      if (bustNetworkCache != null) {
        networkUrl = photoUrlWithCacheBust(networkUrl, bust: bustNetworkCache!);
      }
    }

    final canView =
        (networkUrl != null && networkUrl.isNotEmpty) || localFile != null;
    final canChange = onChangePhoto != null;

    Widget avatar = _buildAvatar(networkUrl);

    if (canChange) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onChangePhoto,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: SignmeColors.primaryLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: SignmeColors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (!canView && !canChange) {
      return avatar;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: canView && showViewerOnTap
            ? () {
                if (localFile != null) {
                  return;
                }
                if (resolvedUrl != null) {
                  ProfilePhotoViewer.show(
                    context,
                    photoUrl: resolvedUrl,
                    title: displayName,
                  );
                }
              }
            : null,
        child: avatar,
      ),
    );
  }

  Widget _buildAvatar(String? networkUrl) {
    final size = radius * 2;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: SignmeColors.primaryLight, width: 2),
        color: SignmeColors.accentSky,
      ),
      child: ClipOval(
        child: localFile != null
            ? Image.file(
                localFile!,
                fit: BoxFit.cover,
                width: size,
                height: size,
              )
            : networkUrl != null && networkUrl.isNotEmpty
                ? _NetworkCircleImage(
                    key: ValueKey(networkUrl),
                    imageUrl: networkUrl,
                    size: size,
                  )
                : _placeholderIcon(),
      ),
    );
  }

  Widget _placeholderIcon() {
    return Icon(
      Icons.person_rounded,
      size: radius,
      color: SignmeColors.primaryLight,
    );
  }
}

/// Image réseau fiable (évite le spinner infini de CachedNetworkImage + imageBuilder).
class _NetworkCircleImage extends StatelessWidget {
  const _NetworkCircleImage({
    super.key,
    required this.imageUrl,
    required this.size,
  });

  final String imageUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    // Décoder directement à la taille d'affichage réelle (en pixels physiques)
    // plutôt que la pleine résolution de la photo (souvent plusieurs Mo) :
    // évite un décodage coûteux répété à chaque avatar affiché, sur chaque
    // écran — cause principale du délai perçu sur les icônes/avatars.
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final targetSize = (size * devicePixelRatio).round();

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: size,
      height: size,
      cacheWidth: targetSize,
      cacheHeight: targetSize,
      gaplessPlayback: true,
      filterQuality: FilterQuality.medium,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }
        return Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            Icons.broken_image_outlined,
            size: size * 0.4,
            color: SignmeColors.mediumGray,
          ),
        );
      },
    );
  }
}
