import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/router/app_router.dart';
import '../../../publications/presentation/providers/publications_provider.dart';
import '../../../evenements/presentation/providers/evenements_provider.dart';
import '../../../evenements/presentation/widgets/evenement_card.dart';
import '../providers/home_feed_provider.dart';
import '../widgets/news_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.auth?.user;
    final feedAsync = ref.watch(homeFeedProvider);
    final scrollController = ref.watch(homeScrollControllerProvider);

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async {
        await Future.wait([
          ref.read(publicationsListProvider(const {'limit': 5}).notifier).refresh(),
          ref.read(evenementsListProvider.notifier).refresh(),
        ]);
      },
      // CustomScrollView + SliverList (au lieu d'un Column qui construirait
      // TOUTES les cartes du fil d'actualité d'un coup) : le fil affiche
      // désormais tout l'historique local (publications + événements,
      // synchronisés en delta — voir evenements_provider.dart/
      // publications_provider.dart), potentiellement des centaines d'entrées
      // à terme. Seules les cartes visibles à l'écran sont construites.
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _UserHeader(user: user, ref: ref),
                const SizedBox(height: SignmeSpacing.lg),
                _ChurchCard(churchName: user?.churchNom),
                const SizedBox(height: SignmeSpacing.lg),
                const OnboardingSection(
                  svgPath: SignmeAssets.onboardingHome,
                  title: 'Ravis de vous revoir',
                  description: "Que voulez-vous faire aujourd'hui Mme/Mr ?",
                ),
                const SizedBox(height: SignmeSpacing.xxxl),
                const _ActualitesHeader(),
                const SizedBox(height: SignmeSpacing.md),
              ],
            ),
          ),
          ..._buildActualitesSlivers(
            feedAsync: feedAsync,
            onRetry: () {
              ref.read(publicationsListProvider(const {'limit': 5}).notifier).refresh();
              ref.read(evenementsListProvider.notifier).refresh();
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({this.user, required this.ref});
  final UserEntity? user;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.sm, SignmeSpacing.lg, 0),
      child: Row(
        children: [
          ProfilePhotoAvatar(
            photoUrl: user?.photoUrl,
            displayName: user?.nom,
            radius: 32,
          ),
          const SizedBox(width: SignmeSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour,',
                  style: SignmeTypography.bodySmall.copyWith(
                    color: SignmeColors.darkGray,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  user?.nom ?? 'Membre',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.w800,
                    color: SignmeColors.black,
                  ),
                ),
              ],
            ),
          ),
          if (user != null) SignmeRoleBadge(role: user!.role, compact: true),
        ],
      ),
    );
  }
}

class _ChurchCard extends StatelessWidget {
  const _ChurchCard({this.churchName});
  final String? churchName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
      child: Container(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
          boxShadow: [
            BoxShadow(
              color: SignmeColors.primaryDark.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: SignmeColors.primaryLight,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                child: Image.asset(
                  SignmeAssets.eeclogo,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    churchName ?? 'Ma paroisse',
                    style: SignmeTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Membre actif',
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.verified_rounded,
              color: SignmeColors.success.withOpacity(0.85),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}



class _ActualitesHeader extends StatelessWidget {
  const _ActualitesHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Actualités',
            style: SignmeTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SignmeSpacing.sm,
              vertical: SignmeSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
            ),
            child: Text(
              'À la une',
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Slivers du fil d'actualité — [SliverList] + [SliverChildBuilderDelegate] :
/// seules les cartes visibles à l'écran sont construites, quelle que soit la
/// taille du fil accumulé localement (voir commentaire dans [HomeScreen]).
List<Widget> _buildActualitesSlivers({
  required AsyncValue<List<HomeFeedItem>> feedAsync,
  required VoidCallback onRetry,
}) {
  return SignmeAsyncValue.buildSlivers<List<HomeFeedItem>>(
    value: feedAsync,
    onRetry: onRetry,
    emptyTitle: 'Pas encore d\'actualités',
    emptyMessage:
        'Les annonces, méditations et événements de votre église apparaîtront ici.',
    isEmpty: (list) => list.isEmpty,
    data: (items) => [
      SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
                child: switch (item) {
                  HomeFeedPublication(:final publication) => NewsCard(publication: publication),
                  HomeFeedEvenement(:final evenement) => EvenementCard(
                      evenement: evenement,
                      onContribuer: () => context.push(
                        AppRoutes.contributionFormPath(evenement.uuid),
                        extra: evenement,
                      ),
                    ),
                },
              );
            },
            childCount: items.length,
          ),
        ),
      ),
    ],
  );
}
