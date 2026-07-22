import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/widgets/profile_photo_avatar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/publications_provider.dart';

class PublicationDetailScreen extends ConsumerWidget {
  const PublicationDetailScreen({super.key, required this.publicationId});

  final int publicationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    final asyncPub = ref.watch(publicationDetailProvider(publicationId));

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Publication',
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          asyncPub.maybeWhen(
            data: (pub) {
              if (user == null) return const SizedBox.shrink();
              final canEdit =
                  AppPermissions.canEditPublication(user, pub.auteurId);
              final canDelete =
                  AppPermissions.canDeletePublication(user, pub.auteurId);
              if (!canEdit && !canDelete) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                onSelected: (v) async {
                  if (v == 'edit') {
                    context.push(AppRoutes.publicationEditPath(pub.id));
                  } else if (v == 'delete') {
                    final ok = await _confirmDelete(context, pub.titre);
                    if (ok && context.mounted) {
                      try {
                        await ref
                            .read(publicationFormProvider.notifier)
                            .delete(pub.id);
                        if (context.mounted) {
                          context.pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Publication supprimée'),
                              backgroundColor: SignmeColors.success,
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          AppSnackbar.error(context, messageFromError(e));
                        }
                      }
                    }
                  }
                },
                itemBuilder: (_) => [
                  if (canEdit)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Modifier'),
                    ),
                  if (canDelete)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Supprimer',
                        style: TextStyle(color: SignmeColors.error),
                      ),
                    ),
                ],
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncPub.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SignmeColors.primaryLight),
        ),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: () =>
              ref.invalidate(publicationDetailProvider(publicationId)),
        ),
        data: (pub) => SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            120,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Color(pub.typeColor).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      pub.typeLabel.toUpperCase(),
                      style: SignmeTypography.labelSmall.copyWith(
                        color: Color(pub.typeColor),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.sm),
                  Flexible(
                    child: Text(
                      pub.formattedDateTime,
                      style: SignmeTypography.labelSmall.copyWith(
                        color: SignmeColors.mediumGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.lg),
              Row(
                children: [
                  // ✅ FIX: Utilisation du composant unifié pour la photo de l'auteur
                  ProfilePhotoAvatar(
                    photoUrl: pub.auteurPhotoUrl,
                    displayName: pub.auteurNom,
                    radius: 22,
                    showViewerOnTap: true,
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          pub.auteurNom,
                          style: SignmeTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (pub.churchName != null)
                          Text(
                            pub.churchName!,
                            style: SignmeTypography.bodySmall.copyWith(
                              color: SignmeColors.mediumGray,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.xl),
              Text(
                pub.titre,
                style: SignmeTypography.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
              ),
              if (pub.isMeditation && pub.referenceBiblique != null) ...[
                const SizedBox(height: SignmeSpacing.md),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(SignmeSpacing.md),
                  decoration: BoxDecoration(
                    color: SignmeColors.primaryLight.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                    border: Border.all(
                      color: SignmeColors.primaryLight.withOpacity(0.25),
                    ),
                  ),
                  child: Text(
                    '📖 ${pub.referenceBiblique}',
                    style: SignmeTypography.labelMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SignmeColors.primaryDark,
                    ),
                  ),
                ),
              ],
              const SizedBox(height: SignmeSpacing.lg),
              Text(
                pub.contenu,
                style: SignmeTypography.bodyMedium.copyWith(height: 1.65),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context, String titre) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Supprimer ?'),
            content: Text('« $titre » sera définitivement supprimée.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: SignmeColors.error),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }
}
