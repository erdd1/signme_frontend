import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/about_article_entity.dart';
import '../providers/about_church_provider.dart';
import 'content_pager.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/network/dio_exception_mapper.dart';

/// NB : cette version affiche le contenu intégral. Le découpage en pages
/// horizontales (~10 lignes/page, swipe interne) sera ajouté à l'étape 6
/// via un widget dédié qui remplacera le [Text] du contenu ci-dessous, sans
/// changer la structure globale de la card (photos + titre + badge restent
/// identiques).
class ArticleCard extends ConsumerWidget {
  const ArticleCard({super.key, required this.article});

  final AboutArticleEntity article;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (article.images.isNotEmpty) _ArticleImages(images: article.images),
          Padding(
            padding: const EdgeInsets.all(SignmeSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (article.isPastor)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                    child: _PastorBadge(isActuel: article.isPasteurActuel),
                  ),
                Text(
                  article.titre,
                  style: SignmeTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: SignmeColors.primaryDark,
                  ),
                ),
                const SizedBox(height: SignmeSpacing.sm),
                ContentPager(
                  text: article.contenu,
                  style: SignmeTypography.bodyMedium.copyWith(
                    color: SignmeColors.textSecondary,
                    height: 1.5,
                  ),
                  linesPerPage: 10,
                ),
              ],
            ),
          ),
        ],
      ),
        ),
        // Menu d'actions (épingler / modifier / supprimer) pour autorisés
        Positioned(
          right: 8,
          top: 8,
          child: Builder(builder: (ctx) {
            final user = ref.watch(authNotifierProvider).auth?.user;
            if (user == null || !AppPermissions.canManageAboutChurch(user)) return const SizedBox.shrink();

            Future<void> handlePinToggle() async {
              try {
                final notifier = ref.read(aboutChurchProvider.notifier);
                if (article.isPinned) {
                  await notifier.unpinArticle(article.uuid);
                } else {
                  await notifier.pinArticle(article.uuid);
                }
              } catch (e) {
                if (ctx.mounted) {
                  AppSnackbar.error(ctx, messageFromError(e));
                }
              }
            }

            Future<void> handleDelete() async {
              final confirm = await signmeConfirm(
                ctx,
                title: 'Confirmer',
                message: 'Supprimer définitivement l\'article "${article.titre}" ?',
                confirmLabel: 'Supprimer',
                isDangerous: true,
              );
              if (confirm != true) return;
              try {
                await ref.read(aboutChurchProvider.notifier).deleteArticle(article.uuid);
              } catch (e) {
                if (ctx.mounted) {
                  AppSnackbar.error(ctx, messageFromError(e));
                }
              }
            }

            return SignmeAnchoredActionMenu(
              items: [
                SignmeAnchoredActionMenuItem(
                  icon: article.isPinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                  label: article.isPinned ? 'Désépingler' : 'Épingler',
                  onTap: handlePinToggle,
                ),
                SignmeAnchoredActionMenuItem(
                  icon: Icons.edit_rounded,
                  label: 'Modifier',
                  onTap: () => ctx.pushNamed(
                    'about-church-edit',
                    pathParameters: {'uuid': article.uuid},
                  ),
                ),
                SignmeAnchoredActionMenuItem(
                  icon: Icons.delete_outline_rounded,
                  label: 'Supprimer',
                  onTap: handleDelete,
                ),
              ],
              builder: (context, onTap) => Container(
                decoration: BoxDecoration(
                  color: SignmeColors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.more_vert_rounded, size: 20),
                  color: SignmeColors.black,
                  onPressed: onTap,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _ArticleImages extends StatelessWidget {
  const _ArticleImages({required this.images});
  final List<String> images;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.of(context).devicePixelRatio;

    // Une seule photo : pleine largeur. 2 ou 3 : bande horizontale.
    // Chaque photo s'ouvre en plein écran (zoom, glisser) au tap.
    if (images.length == 1) {
      final width = MediaQuery.of(context).size.width;
      return AspectRatio(
        aspectRatio: 16 / 10,
        child: GestureDetector(
          onTap: () => FullScreenPhotoViewer.show(context, images: images, initialIndex: 0),
          child: Image.network(
            images.first,
            fit: BoxFit.cover,
            // Décodage borné à la largeur d'écran réelle plutôt qu'à la
            // résolution native de la photo.
            cacheWidth: (width * dpr).round(),
            errorBuilder: _errorBuilder,
          ),
        ),
      );
    }
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.md),
        itemCount: images.length,
        separatorBuilder: (_, __) => const SizedBox(width: SignmeSpacing.sm),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => FullScreenPhotoViewer.show(context, images: images, initialIndex: i),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            child: Image.network(
              images[i],
              width: 220,
              fit: BoxFit.cover,
              cacheWidth: (220 * dpr).round(),
              errorBuilder: _errorBuilder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorBuilder(BuildContext context, Object error, StackTrace? st) => Container(
        color: SignmeColors.accentSky.withOpacity(0.3),
        child: const Icon(Icons.image_rounded, color: SignmeColors.primaryLight),
      );
}

class _PastorBadge extends StatelessWidget {
  const _PastorBadge({required this.isActuel});
  final bool isActuel;

  @override
  Widget build(BuildContext context) {
    final color = isActuel ? SignmeColors.success : SignmeColors.mediumGray;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
      ),
      child: Text(
        isActuel ? 'Pasteur Actuel' : 'Ancien Pasteur',
        style: SignmeTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
