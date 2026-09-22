import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/rapport_annuel_entity.dart';
import '../../domain/entities/rapport_comparaison_entity.dart'
    show AnneeFinanciereEntity, RapportComparaisonEntity;
import '../../domain/entities/rapport_mensuel_entity.dart';
import '../providers/finances_provider.dart';
import '../widgets/finance_formatters.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final notifier = ref.read(financesProvider.notifier);
      await notifier.loadIfNeeded();
      await notifier.refreshSilently();
    });
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final UserEntity? user = authState.auth?.user;

    if (user == null || !AppPermissions.canViewFinances(user)) {
      return _AccessDeniedWidget(role: user?.role ?? '');
    }

    return Column(
      children: [
        Material(
          color: SignmeColors.white,
          child: TabBar(
            controller: _tab,
            labelColor: SignmeColors.primaryLight,
            unselectedLabelColor: SignmeColors.mediumGray,
            indicatorColor: SignmeColors.primaryLight,
            labelStyle: SignmeTypography.labelSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: AppStrings.rapportAnnuel),
              Tab(text: AppStrings.comparaison),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tab,
            children: [
              _RapportAnnuelTab(churchName: user.churchNom),
              const _ComparaisonTab(),
            ],
          ),
        ),
      ],
    );
  }
}

class _AccessDeniedWidget extends StatelessWidget {
  const _AccessDeniedWidget({required this.role});
  final String role;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(SignmeSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: SignmeColors.accentSky,
                shape: BoxShape.circle,
              ),
              child: Image.asset(
                SignmeAssets.lock,
                width: 36,
                height: 36,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: SignmeSpacing.lg),
            Text(
              AppStrings.accessDenied,
              style: SignmeTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            Text(
              AppStrings.accessDeniedSub,
              textAlign: TextAlign.center,
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.mediumGray,
                height: 1.6,
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: SignmeColors.accentSky,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
              ),
              child: Text(
                'Votre rôle : ${AppPermissions.roleLabel(role)}',
                style: SignmeTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: SignmeColors.primaryDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RapportAnnuelTab extends ConsumerWidget {
  const _RapportAnnuelTab({this.churchName});
  final String? churchName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(financesBootstrapProvider);
    final state = ref.watch(financesProvider);
    final year = state.currentYear;
    final annual = state.currentAnnual;
    final isLoadingAnnual = state.isLoadingAnnual(year);
    final selectedIdx =
        state.selectedMonthIndex ?? (DateTime.now().month - 1);
    final monthKey = annual.monthlyData[selectedIdx].monthKey.isNotEmpty
        ? annual.monthlyData[selectedIdx].monthKey
        : '$year-${(selectedIdx + 1).toString().padLeft(2, '0')}';
    final monthDetail = state.monthDetailsByKey[monthKey];
    final isLoadingMonth = state.isLoadingMonthKey(monthKey);

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(financesProvider.notifier).refresh(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          SignmeSpacing.lg,
          SignmeSpacing.md,
          SignmeSpacing.lg,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (churchName != null && churchName!.isNotEmpty) ...[
              Text(
                churchName!,
                style: SignmeTypography.labelMedium.copyWith(
                  color: SignmeColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: SignmeSpacing.sm),
            ],
            SignmeYearSelector(
              year: year,
              label: 'Rapport financier',
              minYear: 2026,
              maxYear: DateTime.now().year + 4,
              onPrevious: () =>
                  ref.read(financesProvider.notifier).previousYear(),
              onNext: () => ref.read(financesProvider.notifier).nextYear(),
            ),
            const SizedBox(height: SignmeSpacing.md),
            PdfDownloadButton(
              label: 'Télécharger le rapport (PDF)',
              path: ApiConfig.rapportAnnuelPdf,
              filename: 'rapport-financier-$year.pdf',
              queryParameters: {'year': year},
            ),
            if (state.annualError != null && !state.hasAnnualFor(year)) ...[
              const SizedBox(height: SignmeSpacing.md),
              SignmeErrorState(
                title: 'Rapport indisponible',
                message: state.annualError!,
                onRetry: () =>
                    ref.read(financesProvider.notifier).loadAnnual(year),
              ),
            ],
            const SizedBox(height: SignmeSpacing.lg),
            _AnnualSummaryGrid(
              annual: annual,
              isLoading: isLoadingAnnual,
            ),
            const SizedBox(height: SignmeSpacing.lg),
            if (annual.isEmpty &&
                !isLoadingAnnual &&
                state.hasAnnualFor(year))
              const SignmeEmptyState(
                icon: Icons.pie_chart_outline_rounded,
                title: 'Aucune donnée financière',
                message:
                    'Aucune signature complétée pour cette année. Les montants apparaîtront après les premières signatures.',
              )
            else ...[
              _MonthlyTable(
                monthly: annual.monthlyData,
                selectedIdx: selectedIdx,
                isLoading: isLoadingAnnual,
                onSelect: (i) =>
                    ref.read(financesProvider.notifier).selectMonth(i),
              ),
              const SizedBox(height: SignmeSpacing.lg),
              _MonthDetailPanel(
                month: annual.monthlyData[selectedIdx],
                detail: monthDetail,
                isLoading: isLoadingAnnual || isLoadingMonth,
                error: state.monthError,
                onRetry: () =>
                    ref.read(financesProvider.notifier).selectMonth(selectedIdx),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _AnnualSummaryGrid extends StatelessWidget {
  const _AnnualSummaryGrid({
    required this.annual,
    required this.isLoading,
  });

  final RapportAnnuelEntity annual;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SummaryHeroCard(annual: annual, isLoading: isLoading),
        const SizedBox(height: SignmeSpacing.md),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Offrandes présentiel',
                value: FinanceFormatters.fcfaShort(annual.totalPresentiel),
                icon: Icons.person_pin_circle_rounded,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                label: 'Offrandes distance',
                value: FinanceFormatters.fcfaShort(annual.totalDistance),
                icon: Icons.phone_android_rounded,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _MiniStatCard(
                label: 'Frais',
                value: FinanceFormatters.fcfaShort(annual.totalFees),
                icon: Icons.receipt_long_rounded,
                isLoading: isLoading,
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Expanded(
              child: _MiniStatCard(
                label: 'Encaissé',
                value: FinanceFormatters.fcfaShort(annual.totalEncaisse),
                icon: Icons.payments_rounded,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SummaryHeroCard extends StatelessWidget {
  const _SummaryHeroCard({
    required this.annual,
    required this.isLoading,
  });

  final RapportAnnuelEntity annual;
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
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: isLoading
                ? const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppShimmerBox(width: 140, height: 10, radius: 4),
                      SizedBox(height: 8),
                      AppShimmerBox(width: 180, height: 18, radius: 6),
                      SizedBox(height: 6),
                      AppShimmerBox(width: 120, height: 10, radius: 4),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total offrandes ${annual.year}',
                        style: SignmeTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      Text(
                        FinanceFormatters.fcfa(annual.totalAmount),
                        style: SignmeTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${annual.totalSignatures} ${AppStrings.signaturesEnregistrees}',
                        style: SignmeTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
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
    required this.label,
    required this.value,
    required this.icon,
    required this.isLoading,
  });

  final String label;
  final String value;
  final IconData icon;
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
          Icon(icon, size: 20, color: SignmeColors.primaryLight),
          const SizedBox(height: 6),
          Text(
            label,
            style: SignmeTypography.labelSmall.copyWith(
              color: SignmeColors.mediumGray,
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: AppShimmerBox(width: 72, height: 14, radius: 4),
            )
          else
            Text(
              value,
              style: SignmeTypography.labelLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _MonthlyTable extends StatelessWidget {
  const _MonthlyTable({
    required this.monthly,
    required this.selectedIdx,
    required this.isLoading,
    required this.onSelect,
  });

  final List<DonneeMensuelleEntity> monthly;
  final int selectedIdx;
  final bool isLoading;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(
              color: SignmeColors.accentSky,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(SignmeSpacing.radiusLg),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text('Mois', style: _headerStyle()),
                ),
                Expanded(child: Text('Sign.', textAlign: TextAlign.center, style: _headerStyle())),
                Expanded(
                  flex: 2,
                  child: Text('Offrandes', textAlign: TextAlign.right, style: _headerStyle()),
                ),
              ],
            ),
          ),
          ...List.generate(monthly.length, (i) {
            final m = monthly[i];
            final isSel = i == selectedIdx;
            final label = m.monthName.isNotEmpty
                ? m.monthName
                : AppStrings.moisFull[i];
            return Column(
              children: [
                InkWell(
                  onTap: () => onSelect(i),
                  child: Container(
                    color: isSel
                        ? SignmeColors.accentSky.withOpacity(0.45)
                        : Colors.transparent,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            label,
                            style: SignmeTypography.bodyMedium.copyWith(
                              fontWeight:
                                  isSel ? FontWeight.bold : FontWeight.normal,
                              color: isSel
                                  ? SignmeColors.primaryLight
                                  : SignmeColors.black,
                            ),
                          ),
                        ),
                        Expanded(
                          child: isLoading
                              ? const TableCellShimmer(width: 28, height: 10)
                              : Text(
                                  m.count > 0 ? '${m.count}' : '–',
                                  textAlign: TextAlign.center,
                                  style: _cellStyle(m.count > 0),
                                ),
                        ),
                        Expanded(
                          flex: 2,
                          child: isLoading
                              ? const Align(
                                  alignment: Alignment.centerRight,
                                  child: TableCellShimmer(width: 44, height: 10),
                                )
                              : Text(
                                  m.amount > 0
                                      ? FinanceFormatters.fcfaShort(m.amount)
                                      : '–',
                                  textAlign: TextAlign.right,
                                  style: _cellStyle(m.amount > 0),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < monthly.length - 1)
                  Divider(
                    height: 1,
                    color: SignmeColors.lightGrayBorder.withOpacity(0.6),
                    indent: 12,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  TextStyle _headerStyle() => SignmeTypography.labelSmall.copyWith(
        fontWeight: FontWeight.bold,
        color: SignmeColors.primaryDark,
      );

  TextStyle _cellStyle(bool active) => SignmeTypography.labelMedium.copyWith(
        color: active ? SignmeColors.black : SignmeColors.mediumGray,
        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
      );
}

class _MonthDetailPanel extends StatelessWidget {
  const _MonthDetailPanel({
    required this.month,
    required this.detail,
    required this.isLoading,
    this.error,
    this.onRetry,
  });

  final DonneeMensuelleEntity month;
  final RapportMensuelEntity? detail;
  final bool isLoading;
  final String? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final title = month.monthName.isNotEmpty
        ? month.monthName
        : AppStrings.moisFull[month.monthIndex];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Détail — $title',
            style: SignmeTypography.labelLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: SignmeColors.primaryDark,
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          Row(
            children: [
              _DetailChip(
                label: 'Présentiel',
                value: '${month.countPresentiel} · ${FinanceFormatters.fcfaShort(month.amountPresentiel)}',
              ),
              const SizedBox(width: SignmeSpacing.sm),
              _DetailChip(
                label: 'Distance',
                value: '${month.countDistance} · ${FinanceFormatters.fcfaShort(month.amountDistance)}',
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.lg),
          if (isLoading)
            const _MonthDetailShimmer()
          else if (error != null)
            SignmeErrorState(
              title: 'Détail indisponible',
              message: error!,
              onRetry: onRetry,
            )
          else if (detail == null || detail!.nbTotal == 0)
            Text(
              'Aucune signature pour ce mois.',
              style: SignmeTypography.bodyMedium.copyWith(
                color: SignmeColors.mediumGray,
              ),
            )
          else
            Text(
              '${detail!.nbTotal} signature(s) · ${FinanceFormatters.fcfa(detail!.montantTotal)}',
              style: SignmeTypography.bodySmall.copyWith(
                color: SignmeColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: SignmeColors.accentSky.withOpacity(0.35),
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: SignmeTypography.labelSmall),
            Text(
              value,
              style: SignmeTypography.labelMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ComparaisonTab extends ConsumerWidget {
  const _ComparaisonTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(financesBootstrapProvider);
    final state = ref.watch(financesProvider);
    final cmp = state.comparison;
    final isLoading = state.isLoadingComparison && !state.hasLoadedComparison;

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () =>
          ref.read(financesProvider.notifier).loadComparison(force: true),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          SignmeSpacing.lg,
          SignmeSpacing.lg,
          SignmeSpacing.lg,
          120,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoading)
              const _ComparaisonShimmer()
            else if (cmp == null)
              SignmeEmptyState(
                icon: Icons.compare_arrows_rounded,
                title: 'Comparaison indisponible',
                message: 'Impossible de charger la comparaison.',
                action: SignmePrimaryButton(
                  label: 'Réessayer',
                  onPressed: () =>
                      ref.read(financesProvider.notifier).loadComparison(
                            force: true,
                          ),
                ),
              )
            else ...[
              _EvolutionBanner(comparison: cmp),
              const SizedBox(height: SignmeSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: _YearCompareCard(
                      title: 'Année ${cmp.current.year}',
                      data: cmp.current,
                      highlighted: true,
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: _YearCompareCard(
                      title: 'Année ${cmp.previous.year}',
                      data: cmp.previous,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EvolutionBanner extends StatelessWidget {
  const _EvolutionBanner({required this.comparison});
  final RapportComparaisonEntity comparison;

  @override
  Widget build(BuildContext context) {
    final sens = comparison.evolutionSens;
    final color = sens == 'hausse'
        ? SignmeColors.success
        : sens == 'baisse'
            ? SignmeColors.error
            : SignmeColors.mediumGray;
    final icon = sens == 'hausse'
        ? Icons.trending_up_rounded
        : sens == 'baisse'
            ? Icons.trending_down_rounded
            : Icons.trending_flat_rounded;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: SignmeSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Évolution des offrandes',
                  style: SignmeTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  FinanceFormatters.percent(comparison.evolutionPercent),
                  style: SignmeTypography.headlineSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  'Écart : ${FinanceFormatters.fcfa(comparison.difference)}',
                  style: SignmeTypography.bodySmall.copyWith(
                    color: SignmeColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _YearCompareCard extends StatelessWidget {
  const _YearCompareCard({
    required this.title,
    required this.data,
    this.highlighted = false,
  });

  final String title;
  final AnneeFinanciereEntity data;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: highlighted
            ? SignmeColors.accentSky.withOpacity(0.4)
            : SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(
          color: highlighted
              ? SignmeColors.primaryLight
              : SignmeColors.lightGrayBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: SignmeTypography.labelMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: SignmeColors.primaryDark,
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          Text(
            FinanceFormatters.fcfa(data.totalOffrandes),
            style: SignmeTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${data.nbSignatures} signatures',
            style: SignmeTypography.bodySmall.copyWith(
              color: SignmeColors.mediumGray,
            ),
          ),
          Text(
            'Encaissé ${FinanceFormatters.fcfaShort(data.totalEncaisse)}',
            style: SignmeTypography.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _MonthDetailShimmer extends StatelessWidget {
  const _MonthDetailShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        4,
        (_) => const Padding(
          padding: EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: AppShimmerBox(
            width: double.infinity,
            height: 36,
            radius: SignmeSpacing.radiusMd,
          ),
        ),
      ),
    );
  }
}

class _ComparaisonShimmer extends StatelessWidget {
  const _ComparaisonShimmer();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AppShimmerBox(
          width: double.infinity,
          height: 88,
          radius: SignmeSpacing.radiusLg,
        ),
        const SizedBox(height: SignmeSpacing.lg),
        Row(
          children: [
            Expanded(
              child: AppShimmerBox(
                width: double.infinity,
                height: 120,
                radius: SignmeSpacing.radiusLg,
              ),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: AppShimmerBox(
                width: double.infinity,
                height: 120,
                radius: SignmeSpacing.radiusLg,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
