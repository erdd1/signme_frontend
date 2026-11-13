import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../main/presentation/screens/main_shell.dart' show kFloatingNavClearance;
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/lookup_providers.dart';
import '../providers/users_provider.dart';
import '../widgets/user_card.dart';
import '../../../../core/network/dio_exception_mapper.dart';

/// Tableau de bord "Gérer utilisateurs" — stats démographiques (total
/// fidèles, Cameroun/Diaspora, Hommes/Femmes) + 4 filtres (mois de
/// naissance, quartier, groupe, région d'origine). Accès pasteur/secrétaire.
class GestionUtilisateursScreen extends ConsumerWidget {
  const GestionUtilisateursScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authNotifierProvider).auth?.user;

    if (currentUser == null || !AppPermissions.canManageMembers(currentUser)) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(SignmeSpacing.xl),
            child: Text(
              'Seuls le pasteur et le secrétaire peuvent accéder à ce tableau de bord.',
              textAlign: TextAlign.center,
              style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
            ),
          ),
        ),
      );
    }

    final statsAsync = ref.watch(userStatsProvider);
    final quartiersAsync = ref.watch(quartiersListProvider);
    final groupesAsync = ref.watch(groupesListProvider);

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
          'Statistiques fidèles',
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () async => ref.invalidate(userStatsProvider),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            // Assez d'espace pour que le menu du dernier filtre (Région,
            // jusqu'à 7 lignes de ~46px) puisse s'afficher entièrement
            // au-dessus de la navbar flottante une fois tout en bas.
            440,
          ),
          children: [
            Builder(builder: (context) {
              final stats = statsAsync.valueOrNull;
              final isLoadingStats = statsAsync.isLoading;

              if (statsAsync.hasError && stats == null) {
                return SignmeErrorState(
                  title: 'Statistiques indisponibles',
                  message: statsAsync.error.toString(),
                  onRetry: () => ref.invalidate(userStatsProvider),
                );
              }

              final total = (stats?.totalFideles ?? 0) == 0 ? 1 : stats!.totalFideles;
              String pct(int value) => '${(value / total * 100).toStringAsFixed(1).replaceAll('.', ',')}%';

              return Column(
                children: [
                  _SummaryHeroCard(
                    totalFideles: stats?.totalFideles ?? 0,
                    isLoading: isLoadingStats,
                  ),
                  const SizedBox(height: SignmeSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.male_rounded,
                          label: 'Hommes',
                          value: '${stats?.hommes ?? 0}',
                          percentage: pct(stats?.hommes ?? 0),
                          color: SignmeColors.primaryLight,
                          isLoading: isLoadingStats,
                        ),
                      ),
                      const SizedBox(width: SignmeSpacing.md),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.female_rounded,
                          label: 'Femmes',
                          value: '${stats?.femmes ?? 0}',
                          percentage: pct(stats?.femmes ?? 0),
                          color: Colors.pinkAccent,
                          isLoading: isLoadingStats,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: SignmeSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.flag_rounded,
                          label: 'Au Cameroun',
                          value: '${stats?.auCameroun ?? 0}',
                          percentage: pct(stats?.auCameroun ?? 0),
                          color: SignmeColors.success,
                          isLoading: isLoadingStats,
                        ),
                      ),
                      const SizedBox(width: SignmeSpacing.md),
                      Expanded(
                        child: _MiniStatCard(
                          icon: Icons.public_rounded,
                          label: 'Diaspora',
                          value: '${stats?.horsCameroun ?? 0}',
                          percentage: pct(stats?.horsCameroun ?? 0),
                          color: SignmeColors.primaryCyan,
                          isLoading: isLoadingStats,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            }),
            const SizedBox(height: SignmeSpacing.xxxl),

            // ── Filtre : mois de naissance ─────────────────────────────
            _SectionTitle('Filtrer par mois de naissance'),
            const SizedBox(height: SignmeSpacing.md),
            Wrap(
              spacing: SignmeSpacing.sm,
              runSpacing: SignmeSpacing.sm,
              children: List.generate(12, (i) {
                final mois = i + 1;
                return SignmePillChip(
                  label: AppStrings.moisShort[i],
                  selected: false,
                  onTap: () => _openResults(
                    context,
                    title: 'Nés en ${AppStrings.moisFull[i]}',
                    filters: {'moisNaissance': mois},
                  ),
                );
              }),
            ),
            const SizedBox(height: SignmeSpacing.xxxl),

            // ── Filtre : quartier ───────────────────────────────────────
            const SignmeFilterSectionHeader(
              icon: Icons.location_on_rounded,
              color: SignmeColors.primaryLight,
              title: 'Filtrer par quartier de résidence',
              description: 'Sélectionnez le quartier de résidence',
            ),
            const SizedBox(height: SignmeSpacing.md),
            quartiersAsync.when(
              loading: () => const AppShimmerBox(width: double.infinity, height: 52, radius: SignmeSpacing.radiusMd),
              error: (e, _) => Text('Chargement impossible', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
              data: (quartiers) => quartiers.isEmpty
                  ? Text('Aucun quartier enregistré.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray))
                  : SignmeCompactDropdown<QuartierRef>(
                      label: 'Quartier',
                      value: null,
                      items: quartiers,
                      itemLabel: (q) => q.nom,
                      hint: 'Sélectionner un quartier',
                      onChanged: (q) {
                        if (q == null) return;
                        _openResults(
                          context,
                          title: 'Quartier : ${q.nom}',
                          filters: {'quartierId': q.id},
                        );
                      },
                    ),
            ),
            const SizedBox(height: SignmeSpacing.xxxl),

            // ── Filtre : groupe ─────────────────────────────────────────
            const SignmeFilterSectionHeader(
              icon: Icons.groups_rounded,
              color: SignmeColors.success,
              title: 'Filtrer par groupe',
              description: 'Sélectionnez le groupe',
            ),
            const SizedBox(height: SignmeSpacing.md),
            groupesAsync.when(
              loading: () => const AppShimmerBox(width: double.infinity, height: 52, radius: SignmeSpacing.radiusMd),
              error: (e, _) => Text('Chargement impossible', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
              data: (groupes) => groupes.isEmpty
                  ? Text('Aucun groupe enregistré.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray))
                  : SignmeCompactDropdown<GroupeRef>(
                      label: 'Groupe',
                      value: null,
                      items: groupes,
                      itemLabel: (g) => g.nom,
                      hint: 'Sélectionner un groupe',
                      onChanged: (g) {
                        if (g == null) return;
                        _openResults(
                          context,
                          title: 'Groupe : ${g.nom}',
                          filters: {'groupeId': g.id},
                        );
                      },
                    ),
            ),
            const SizedBox(height: SignmeSpacing.xxxl),

            // ── Filtre : région d'origine ────────────────────────────────
            const SignmeFilterSectionHeader(
              icon: Icons.public_rounded,
              color: Colors.deepPurpleAccent,
              title: 'Filtrer par région d\'origine',
              description: 'Sélectionnez la région d\'origine',
            ),
            const SizedBox(height: SignmeSpacing.md),
            SignmeCompactDropdown<String>(
              label: 'Région',
              value: null,
              items: AppStrings.regionsCameroun,
              itemLabel: (r) => r,
              hint: 'Sélectionner une région',
              onChanged: (region) {
                if (region == null) return;
                _openResults(
                  context,
                  title: 'Originaires de $region',
                  filters: {'originaireDe': region},
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openResults(
    BuildContext context, {
    required String title,
    required Map<String, dynamic> filters,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FilteredMembersResultScreen(title: title, filters: filters),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({required this.totalFideles, required this.isLoading});
  final int totalFideles;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total fidèles de la communauté',
                  style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.85)),
                ),
                if (isLoading)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: AppShimmerBox(width: 60, height: 22, radius: 6),
                  )
                else
                  Text(
                    '$totalFideles',
                    style: SignmeTypography.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.percentage,
    required this.color,
    required this.isLoading,
  });

  final IconData icon;
  final String label;
  final String value;
  final String percentage;
  final Color color;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 20, color: color),
              if (isLoading)
                const AppShimmerBox(width: 34, height: 16, radius: SignmeSpacing.radiusFull)
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                  child: Text(
                    percentage,
                    style: SignmeTypography.labelSmall.copyWith(color: color, fontWeight: FontWeight.w700, fontSize: 10),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(label, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray)),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: AppShimmerBox(width: 28, height: 14, radius: 4),
            )
          else
            Text(value, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Écran de résultats d'un filtre du tableau de bord — carte d'en-tête +
/// recherche locale + liste exacte, réutilise [UserCard].
class FilteredMembersResultScreen extends ConsumerStatefulWidget {
  const FilteredMembersResultScreen({
    super.key,
    required this.title,
    required this.filters,
  });

  final String title;
  final Map<String, dynamic> filters;

  @override
  ConsumerState<FilteredMembersResultScreen> createState() => _FilteredMembersResultScreenState();
}

class _FilteredMembersResultScreenState extends ConsumerState<FilteredMembersResultScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asyncUsers = ref.watch(userFilteredListProvider(widget.filters));

    // "Groupe : Ancien" → label "Groupe", nom "Ancien" ; sinon la carte
    // affiche le titre complet comme nom, avec un label générique.
    final parts = widget.title.split(' : ');
    final headerLabel = parts.length == 2 ? parts[0] : 'Résultats';
    final headerName = parts.length == 2 ? parts[1] : widget.title;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.title,
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
        ),
      ),
      body: asyncUsers.when(
        loading: () => const SignmePageSkeleton(itemHeight: 90),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: () => ref.invalidate(userFilteredListProvider(widget.filters)),
        ),
        data: (users) {
          if (users.isEmpty) {
            return const SignmeEmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Aucun résultat',
              message: 'Aucun membre ne correspond à ce filtre.',
            );
          }

          final filtered = _query.isEmpty
              ? users
              : users.where((u) => u.nom.toLowerCase().contains(_query.toLowerCase())).toList();

          // CustomScrollView + SliverList : en-tête (carte + recherche) fixe
          // au-dessus, cartes membres construites paresseusement — un filtre
          // large (ex. tout un mois de naissance) peut retourner des
          // centaines de membres.
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.md, SignmeSpacing.lg, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _GroupHeaderCard(label: headerLabel, name: headerName, memberCount: users.length),
                      const SizedBox(height: SignmeSpacing.xxl),
                      Text(
                        'Membres du groupe',
                        style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      const SizedBox(height: SignmeSpacing.md),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) => setState(() => _query = v),
                        style: SignmeTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Rechercher...',
                          hintStyle: SignmeTypography.placeholder,
                          prefixIcon: const Icon(Icons.search_rounded, color: SignmeColors.mediumGray),
                          filled: true,
                          fillColor: SignmeColors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                            borderSide: const BorderSide(color: SignmeColors.lightGrayBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                            borderSide: const BorderSide(color: SignmeColors.lightGrayBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                            borderSide: const BorderSide(color: SignmeColors.primaryLight),
                          ),
                        ),
                      ),
                      const SizedBox(height: SignmeSpacing.lg),
                    ],
                  ),
                ),
              ),
              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.xxl),
                    child: Text(
                      'Aucun membre ne correspond à la recherche.',
                      textAlign: TextAlign.center,
                      style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
                    ),
                  ),
                )
              else
                SliverPadding(
                  // Padding bas dynamique : dégage la navbar flottante sur
                  // tous les appareils (voir kFloatingNavClearance).
                  padding: EdgeInsets.fromLTRB(
                    SignmeSpacing.lg,
                    0,
                    SignmeSpacing.lg,
                    kFloatingNavClearance + MediaQuery.of(context).padding.bottom + SignmeSpacing.xl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
                        child: UserCard(
                          user: filtered[index],
                          onTap: () => context.push(AppRoutes.userDetailPath(filtered[index].id)),
                        ),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _GroupHeaderCard extends StatelessWidget {
  const _GroupHeaderCard({required this.label, required this.name, required this.memberCount});

  final String label;
  final String name;
  final int memberCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: const Icon(Icons.groups_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.85))),
                Text(
                  name,
                  style: SignmeTypography.displaySmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$memberCount membre${memberCount > 1 ? 's' : ''}',
                  style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.85)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.people_alt_rounded, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$memberCount',
                  style: SignmeTypography.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
