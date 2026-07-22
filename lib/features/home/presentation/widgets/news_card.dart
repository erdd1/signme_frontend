import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/profile_photo_avatar.dart';
import '../../../publications/domain/entities/publication_entity.dart';
import '../utils/home_display_formatters.dart';
import 'expandable_text_block.dart';

class NewsCard extends StatelessWidget {
  const NewsCard({
    super.key,
    required this.publication,
  });

  final PublicationEntity publication;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Stack(
          children: [
            // ── Container principal ──
            Container(
              padding: const EdgeInsets.only(
                left: SignmeSpacing.lg + 6,
                right: SignmeSpacing.lg,
                top: SignmeSpacing.lg,
                bottom: SignmeSpacing.lg,
              ),
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
                  // ── Header : avatar + nom/type + date ──
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfilePhotoAvatar(
                        photoUrl: publication.auteurPhotoUrl,
                        displayName: publication.auteurNom,
                        radius: 20,
                      ),
                      const SizedBox(width: SignmeSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              HomeDisplayFormatters.authorName(
                                publication.auteurNom,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: SignmeTypography.labelMedium.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: SignmeColors.primaryLight.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                publication.typeLabel.toUpperCase(),
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

                      // ── Pill date ──
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: const Color(0xFFD0D9F5),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.calendar_today_outlined,
                              size: 11,
                              color: Color(0xFF6B7BB5),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              publication.formattedDate,
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

                  // ── Titre ──
                  Text(
                    publication.titre,
                    style: SignmeTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: SignmeSpacing.sm),

                  // ── Contenu ──
                  ExpandableTextBlock(
                    text: publication.contenu,
                    maxLines: 5,
                  ),
                ],
              ),
            ),

            // ── Bande dégradé gauche ──
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
                      colors: [
                        Color(0xFF1A3FA6),
                        Color(0xFF5B9BD5),
                      ],
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