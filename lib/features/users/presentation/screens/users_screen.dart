import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';

class UsersScreen extends ConsumerStatefulWidget {
  const UsersScreen({super.key});

  @override
  ConsumerState<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends ConsumerState<UsersScreen> {
  final _scrollCtrl = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(usersListProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(usersListProvider);
    final currentUser = ref.watch(authNotifierProvider).auth?.user;
    final canManage =
        currentUser != null && AppPermissions.canManageMembers(currentUser);
    final users = state.filtered;

    if (currentUser != null && !AppPermissions.canViewMembers(currentUser)) {
      return _AccessDenied();
    }

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(usersListProvider.notifier).refresh(),
      child: CustomScrollView(
        controller: _scrollCtrl,
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                const OnboardingSection(
                  svgPath: SignmeAssets.onboardingUsers,
                  title: 'Gérer les utilisateurs',
                  description:
                      'Consultez, créez et gérez les membres de votre église.',
                ),
                if (canManage) ...[
                  const SizedBox(height: SignmeSpacing.lg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SignmeSpacing.lg,
                    ),
                    child: SignmePrimaryButton(
                      label: 'Nouveau membre',
                      icon: Icons.person_add_rounded,
                      onPressed: () => context.push(AppRoutes.userCreate),
                    ),
                  ),
                  const SizedBox(height: SignmeSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SignmeSpacing.lg,
                    ),
                    child: SignmeSecondaryButton(
                      label: 'Statistiques fidèles',
                      icon: Icons.bar_chart_rounded,
                      onPressed: () => context.push(AppRoutes.userStats),
                    ),
                  ),
                ],
                const SizedBox(height: SignmeSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.lg,
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) =>
                        ref.read(usersListProvider.notifier).search(v),
                    style: SignmeTypography.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Rechercher un membre…',
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: SignmeColors.mediumGray,
                      ),
                      filled: true,
                      fillColor: SignmeColors.accentSky.withOpacity(0.3),
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(SignmeSpacing.radiusMd),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: SignmeSpacing.lg),
              ],
            ),
          ),
          if (state.isLoading && state.users.isEmpty)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: SignmeSpacing.md),
                    child: AppShimmerBox(
                      height: 80,
                      width: double.infinity,
                      radius: SignmeSpacing.radiusLg,
                    ),
                  ),
                  childCount: 5,
                ),
              ),
            )
          else if (state.error != null && state.users.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: SignmeErrorState(
                title: 'Chargement impossible',
                message: state.error!,
                onRetry: () => ref.read(usersListProvider.notifier).refresh(),
              ),
            )
          else if (users.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: SignmeEmptyState(
                icon: Icons.people_outline_rounded,
                title: 'Aucun membre',
                message:
                    'Aucun résultat pour cette recherche. Créez un membre si besoin.',
              ),
            )
          else
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
                    if (index >= users.length) {
                      return const Padding(
                        padding: EdgeInsets.all(SignmeSpacing.lg),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: SignmeColors.primaryLight,
                            strokeWidth: 2,
                          ),
                        ),
                      );
                    }
                    final user = users[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
                      child: UserCard(
                        user: user,
                        onTap: () =>
                            context.push(AppRoutes.userDetailPath(user.id)),
                      ),
                    );
                  },
                  childCount: users.length + (state.isLoading ? 1 : 0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _AccessDenied extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SignmeSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              SignmeAssets.lock,
              width: 64,
              height: 64,
              color: SignmeColors.mediumGray,
            ),
            const SizedBox(height: SignmeSpacing.lg),
            Text(
              'Accès réservé',
              style: SignmeTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            Text(
              'Seuls le pasteur et le secrétaire peuvent gérer les membres.',
              textAlign: TextAlign.center,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
