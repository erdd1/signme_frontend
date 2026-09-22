import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/full_screen_photo_viewer.dart';
import '../../../../core/widgets/profile_photo_avatar.dart';
import '../../../home/presentation/widgets/expandable_text_block.dart';
import '../../domain/entities/evenement_entity.dart';
import 'evenement_actions_menu.dart';
import 'objectif_progress_bar.dart';

/// Carte événement — même chrome visuel que [NewsCard] (bandeau dégradé,
/// avatar auteur, pill date, Voir plus/Voir moins), avec en plus l'image de
/// l'événement, la barre de progression de l'objectif financier et le
/// bouton "Ajouter une contribution".
class EvenementCard extends ConsumerWidget {
  const EvenementCard({
    super.key,
    required this.evenement,
    required this.onContribuer,
  });

  final EvenementEntity evenement;
  final VoidCallback onContribuer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              border: Border.all(color: SignmeColors.lightGrayBorder),
              boxShadow: [
                BoxShadow(
                  color: SignmeColors.primaryDark.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EvenementImage(evenement: evenement),
                Padding(
                  padding: const EdgeInsets.only(
                    left: SignmeSpacing.lg + 6,
                    right: SignmeSpacing.lg,
                    top: SignmeSpacing.lg,
                    bottom: SignmeSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ProfilePhotoAvatar(
                            photoUrl: evenement.auteur.photoUrl,
                            displayName: evenement.auteur.nom,
                            radius: 20,
                          ),
                          const SizedBox(width: SignmeSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  evenement.auteur.nom,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SignmeTypography.labelMedium
                                      .copyWith(fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 2),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: SignmeColors.primaryLight.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'ÉVÉNEMENT',
                                    style: SignmeTypography.labelSmall.copyWith(
                                      color: SignmeColors.primaryLight,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: SignmeSpacing.sm),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: const Color(0xFFD0D9F5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.calendar_today_outlined,
                                    size: 11, color: Color(0xFF6B7BB5)),
                                const SizedBox(width: 5),
                                Text(
                                  evenement.formattedDate,
                                  style: SignmeTypography.bodySmall.copyWith(
                                    color: const Color(0xFF6B7BB5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: SignmeSpacing.md),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              evenement.titre,
                              style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (evenement.peutGerer) EvenementActionsMenu(evenement: evenement),
                        ],
                      ),
                      if (evenement.labelArchivage != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          evenement.labelArchivage!,
                          style: SignmeTypography.labelSmall.copyWith(
                            color: SignmeColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      const SizedBox(height: SignmeSpacing.sm),
                      ExpandableTextBlock(text: evenement.description, maxLines: 5),
                      if (evenement.aUnObjectif) ...[
                        const SizedBox(height: SignmeSpacing.md),
                        ObjectifProgressBar(
                          objectifMontant: evenement.objectifMontant!,
                          montantCollecte: evenement.montantCollecte,
                          pourcentage: evenement.pourcentageObjectif ?? 0,
                        ),
                      ],
                      const SizedBox(height: SignmeSpacing.md),
                      _ContribuerButton(
                        evenement: evenement,
                        onPressed: onContribuer,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(SignmeSpacing.radiusLg),
                bottomLeft: Radius.circular(SignmeSpacing.radiusLg),
              ),
              child: Container(
                width: 9,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFF1A3FA6), Color(0xFF5B9BD5)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EvenementImage extends StatelessWidget {
  const _EvenementImage({required this.evenement});
  final EvenementEntity evenement;

  @override
  Widget build(BuildContext context) {
    final url = evenement.imageUrl;
    final hasPhoto = url != null && url.isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(SignmeSpacing.radiusLg),
        topRight: Radius.circular(SignmeSpacing.radiusLg),
      ),
      child: SizedBox(
        height: 140,
        width: double.infinity,
        child: hasPhoto
            ? GestureDetector(
                // Ouvre la photo en plein écran (zoom, comme sur les
                // réseaux sociaux) — seulement si l'événement en a une.
                onTap: () => FullScreenPhotoViewer.show(
                  context,
                  images: [url],
                  initialIndex: 0,
                ),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.cover,
                  // Décodage borné à une largeur d'affichage réaliste (carte
                  // pleine largeur) plutôt que la résolution native de la
                  // photo — évite un décodage coûteux répété dans un fil qui
                  // peut afficher des dizaines de cartes.
                  memCacheWidth: 800,
                  placeholder: (_, __) => Container(color: SignmeColors.accentSky),
                  errorWidget: (_, __, ___) => _defaultImage(),
                ),
              )
            : _defaultImage(),
      ),
    );
  }

  Widget _defaultImage() {
    return Container(
      color: SignmeColors.accentSky,
      alignment: Alignment.center,
      child: SvgPicture.asset(
        SignmeAssets.evenementDefault,
        height: 90,
        fit: BoxFit.contain,
      ),
    );
  }
}

class _ContribuerButton extends StatelessWidget {
  const _ContribuerButton({required this.evenement, required this.onPressed});
  final EvenementEntity evenement;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final peutContribuer = evenement.peutContribuer;

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: peutContribuer
              ? const LinearGradient(colors: SignmeColors.buttonGradient)
              : null,
          color: peutContribuer ? null : SignmeColors.lightGray,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          boxShadow: peutContribuer
              ? [
                  BoxShadow(
                    color: SignmeColors.primaryLight.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: peutContribuer ? onPressed : null,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    peutContribuer ? Icons.volunteer_activism_rounded : Icons.lock_clock_rounded,
                    size: 18,
                    color: peutContribuer ? Colors.white : SignmeColors.mediumGray,
                  ),
                  const SizedBox(width: SignmeSpacing.sm),
                  Text(
                    evenement.labelBoutonContribution,
                    style: SignmeTypography.buttonText.copyWith(
                      fontSize: 14,
                      color: peutContribuer ? Colors.white : SignmeColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
