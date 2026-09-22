import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/publication_entity.dart';
import '../providers/publications_data_providers.dart';
import '../providers/publications_provider.dart';
import '../widgets/publication_card.dart';

class PublicationsListScreen extends ConsumerWidget {
  const PublicationsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    final filters = ref.watch(publicationFiltersProvider);
    final publicationsAsync = ref.watch(publicationsListProvider(filters));
    final canManage =
        user != null && AppPermissions.canManagePublications(user);
    final selectedType = ref.watch(publicationTypeFilterProvider);

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async {
        await ref.read(publicationsListProvider(filters).notifier).refresh();
        await ref
            .read(publicationsListProvider(const {'limit': 5}).notifier)
            .refresh();
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSection(
                  svgPath: SignmeAssets.onboardingAnnonce,
                  title: 'Annonces & méditations',
                  description:
                      'Publiez et gérez le fil d\'actualité de votre église.',
                ),
                if (canManage) ...[
                  const SizedBox(height: SignmeSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SignmeSpacing.lg,
                    ),
                    child: SignmePrimaryButton(
                      label: 'Nouvelle publication',
                      icon: Icons.add_rounded,
                      onPressed: () => context.push(AppRoutes.publicationCreate),
                    ),
                  ),
                ],
                const SizedBox(height: SignmeSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.lg,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _TypeChip(
                          label: 'Tous',
                          selected: selectedType.isEmpty,
                          onTap: () => ref
                              .read(publicationTypeFilterProvider.notifier)
                              .state = '',
                        ),
                        const SizedBox(width: SignmeSpacing.md),
                        _TypeChip(
                          label: 'Annonces',
                          selected: selectedType == 'annonce',
                          onTap: () => ref
                              .read(publicationTypeFilterProvider.notifier)
                              .state = 'annonce',
                        ),
                        if (user == null || AppPermissions.canViewMeditations(user)) ...[
                          const SizedBox(width: SignmeSpacing.md),
                          _TypeChip(
                            label: 'Méditations',
                            selected: selectedType == 'meditation',
                            onTap: () => ref
                                .read(publicationTypeFilterProvider.notifier)
                                .state = 'meditation',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: SignmeSpacing.lg),
              ],
            ),
          ),
          ...SignmeAsyncValue.buildSlivers<List<PublicationEntity>>(
            value: publicationsAsync,
            onRetry: () {
              ref.read(publicationsListProvider(filters).notifier).refresh();
              ref
                  .read(publicationsListProvider(const {'limit': 5}).notifier)
                  .refresh();
            },
            emptyTitle: 'Aucune publication',
            emptyMessage: canManage
                ? 'Créez votre première annonce ou méditation avec le bouton ci-dessus.'
                : 'Aucun contenu pour ce filtre. Revenez plus tard.',
            isEmpty: (list) => list.isEmpty,
            data: (publications) => [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg,
                  0,
                  SignmeSpacing.lg,
                  120,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final pub = publications[index];
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: SignmeSpacing.md),
                        child: PublicationCard(
                          publication: pub,
                          showActions: canManage,
                          onTap: () => context.push(
                            AppRoutes.publicationDetailPath(pub.id),
                          ),
                          onEdit: user != null &&
                                  AppPermissions.canEditPublication(
                                    user,
                                    pub.auteurId,
                                  )
                              ? () => context.push(
                                    AppRoutes.publicationEditPath(pub.id),
                                  )
                              : null,
                          onDelete: user != null &&
                                  AppPermissions.canDeletePublication(
                                    user,
                                    pub.auteurId,
                                  )
                              ? () => _confirmDelete(context, ref, pub)
                              : null,
                        ),
                      );
                    },
                    childCount: publications.length,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    PublicationEntity pub,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        ),
        title: Text(
          'Supprimer ?',
          style: SignmeTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          '« ${pub.titre} » sera définitivement supprimée.',
          style: SignmeTypography.bodyMedium,
        ),
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
    );

    if (ok != true || !context.mounted) return;

    try {
      await ref.read(publicationFormProvider.notifier).delete(pub.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publication supprimée'),
            backgroundColor: SignmeColors.success,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      AppSnackbar.error(context, messageFromError(e));
    }
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(
        label,
        style: SignmeTypography.labelMedium.copyWith(
          color: selected ? SignmeColors.white : SignmeColors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: SignmeColors.primaryLight,
      backgroundColor: SignmeColors.accentSky,
      checkmarkColor: SignmeColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      ),
      side: BorderSide(
        color:
            selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
      ),
    );
  }
}
