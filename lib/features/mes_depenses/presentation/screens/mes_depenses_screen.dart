import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/contribution_perso_entity.dart';
import '../../domain/entities/mes_depenses_stats_entity.dart';
import '../providers/mes_depenses_data_providers.dart';
import '../providers/mes_depenses_provider.dart';
import '../widgets/contribution_perso_card.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

/// Module "Mes dépenses" — accessible à tous les rôles.
/// Historique et statistiques des contributions du seul utilisateur connecté.
class MesDepensesScreen extends ConsumerWidget {
  const MesDepensesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = ref.watch(mesDepensesYearProvider);
    final month = ref.watch(mesDepensesMonthProvider);
    final statsAsync = ref.watch(mesDepensesStatsProvider);
    final listAsync = ref.watch(mesDepensesListProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () async {
          await Future.wait([
            ref.read(mesDepensesStatsProvider.notifier).refresh(),
            ref.read(mesDepensesListProvider.notifier).refresh(),
          ]);
        },
        // CustomScrollView + SliverList : seules les cartes visibles sont
        // construites, quel que soit le nombre de contributions accumulées.
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StatsHeader(statsAsync: statsAsync),
                    const SizedBox(height: SignmeSpacing.xl),
                    SignmeYearSelector(
                      year: year,
                      // Bornes strictes : ni recul illimité ni avancée illimitée,
                      // même fenêtre glissante que historique_personnel_screen.
                      minYear: DateTime.now().year,
                      maxYear: DateTime.now().year + 4,
                      onPrevious: () => ref.read(mesDepensesYearProvider.notifier).state = year - 1,
                      onNext: () => ref.read(mesDepensesYearProvider.notifier).state = year + 1,
                    ),
                    const SizedBox(height: SignmeSpacing.md),
                    _MonthFilterRow(selectedMonth: month),
                    const SizedBox(height: SignmeSpacing.lg),
                    Text(
                      'Historique de mes contributions aux événements',
                      style: SignmeTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: SignmeColors.primaryDark,
                      ),
                    ),
                    const SizedBox(height: SignmeSpacing.md),
                  ],
                ),
              ),
            ),
            ...SignmeAsyncValue.buildSlivers<List<ContributionPersoEntity>>(
              value: listAsync,
              onRetry: () => ref.read(mesDepensesListProvider.notifier).refresh(),
              emptyTitle: 'Aucune contribution',
              emptyMessage: 'Vos contributions aux événements apparaîtront ici.',
              isEmpty: (list) => list.isEmpty,
              data: (contributions) => [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => Padding(
                        padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
                        child: ContributionPersoCard(contribution: contributions[index]),
                      ),
                      childCount: contributions.length,
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(child: SizedBox(height: floatingNavInset(context))),
          ],
        ),
      ),
    );
  }
}

class _StatsHeader extends StatelessWidget {
  const _StatsHeader({required this.statsAsync});
  final AsyncValue<MesDepensesStatsEntity> statsAsync;

  @override
  Widget build(BuildContext context) {
    final stats = statsAsync.valueOrNull;
    final mois = stats?.moisSelectionne;
    final annee = stats?.anneeSelectionnee;
    final periodeLabel = mois != null && annee != null
        ? 'Total en ${AppStrings.moisFull[mois - 1]} $annee'
        : annee != null
            ? 'Total sur l\'année $annee'
            : 'Total sur la période sélectionnée';

    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: SignmeColors.primaryLight.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total donné jusqu\'à présent',
              style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withOpacity(0.8))),
          const SizedBox(height: 2),
          Text(
            FinanceFormatters.fcfa(stats?.totalDonne ?? 0),
            style: SignmeTypography.headlineLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: SignmeSpacing.md),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: SignmeSpacing.md),
          // Toujours visible : total sur la période (mois/année) actuellement
          // filtrée dans l'écran, mise à jour avec la sélection ci-dessous.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(periodeLabel,
                      style: SignmeTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.85))),
                ),
                Text(
                  FinanceFormatters.fcfa(stats?.totalPeriodeSelectionnee ?? 0),
                  style: SignmeTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          Row(
            children: [
              Expanded(child: _statColumn(Icons.calendar_today_rounded, 'Ce mois', stats?.ceMois ?? 0)),
              Container(width: 1, height: 32, color: Colors.white24),
              Expanded(child: _statColumn(Icons.bar_chart_rounded, 'Cette année', stats?.cetteAnnee ?? 0)),
            ],
          ),
          const SizedBox(height: SignmeSpacing.md),
          Row(
            children: [
              Expanded(
                child: _statColumn(
                  Icons.edit_note_rounded,
                  'Offrande signatures jusqu\'à présent',
                  stats?.totalSignatures ?? 0,
                ),
              ),
              Container(width: 1, height: 32, color: Colors.white24),
              Expanded(
                child: _statColumn(
                  Icons.event_rounded,
                  'Offrande événements jusqu\'à présent',
                  stats?.totalEvenements ?? 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statColumn(IconData icon, String label, int value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white.withOpacity(0.7)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: SignmeTypography.labelSmall.copyWith(color: Colors.white.withOpacity(0.7)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            FinanceFormatters.fcfa(value),
            style: SignmeTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _MonthFilterRow extends ConsumerWidget {
  const _MonthFilterRow({required this.selectedMonth});
  final int? selectedMonth;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _chip(ref, null, 'Tous'),
          for (var m = 1; m <= 12; m++) _chip(ref, m, AppStrings.moisShort[m - 1]),
        ],
      ),
    );
  }

  Widget _chip(WidgetRef ref, int? month, String label) {
    final selected = selectedMonth == month;
    return Padding(
      padding: const EdgeInsets.only(right: SignmeSpacing.sm),
      child: SignmePillChip(
        label: label,
        selected: selected,
        onTap: () => ref.read(mesDepensesMonthProvider.notifier).state = month,
      ),
    );
  }
}