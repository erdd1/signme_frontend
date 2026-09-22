import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/contribution_entity.dart';
import '../../domain/entities/contribution_filter_event_entity.dart';
import '../providers/contributions_treasury_filter_provider.dart';

/// Tableau de bord financier « Contributions événement »
/// (Pasteur / Secrétaire / Trésorier).
///
/// Architecture :
/// - Stats globales et filtrées → backend (SUM SQL)
/// - Liste → pagination infinie (load-more au scroll)
/// - Dropdowns Événement et Groupe → données backend exhaustives
class ContributionsEvenementScreen extends ConsumerStatefulWidget {
  const ContributionsEvenementScreen({super.key});

  @override
  ConsumerState<ContributionsEvenementScreen> createState() =>
      _ContributionsEvenementScreenState();
}

class _ContributionsEvenementScreenState
    extends ConsumerState<ContributionsEvenementScreen> {
  // ── Filtres actifs ──────────────────────────────────────────────────────────
  var _filters = ContributionsTreasuryFilter.empty;

  // ── Scroll controller pour le load-more ─────────────────────────────────────
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    // Chargement initial : page 1 sans filtre
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(contributionsTreasuryListProvider.notifier)
          .fetch(_filters, reset: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      final listState = ref.read(contributionsTreasuryListProvider);
      if (!listState.isLoading && listState.hasMore) {
        ref.read(contributionsTreasuryListProvider.notifier).loadMore(_filters);
      }
    }
  }

  void _onFilterChanged(ContributionsTreasuryFilter newFilters) {
    setState(() => _filters = newFilters);
    ref
        .read(contributionsTreasuryListProvider.notifier)
        .fetch(newFilters, reset: true);
  }

  void _resetFilters() => _onFilterChanged(ContributionsTreasuryFilter.empty);

  @override
  Widget build(BuildContext context) {
    final listState = ref.watch(contributionsTreasuryListProvider);
    final currentUser = ref.watch(authNotifierProvider).auth?.user;
    final canDownload =
        currentUser != null && AppPermissions.canDownloadContributionsPdf(currentUser);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () => ref
            .read(contributionsTreasuryListProvider.notifier)
            .refresh(_filters),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // ── Card bleu — synthèse globale (toujours sans filtre) ───────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.lg,
                  SignmeSpacing.lg, SignmeSpacing.md,
                ),
                child: _SynthesisCard(globalFilter: ContributionsTreasuryFilter.empty),
              ),
            ),

            // ── Section filtres ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                child: _FilterSection(
                  filters: _filters,
                  onChanged: _onFilterChanged,
                  onReset: _resetFilters,
                ),
              ),
            ),

            // ── Résumé de la sélection ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.md,
                  SignmeSpacing.lg, SignmeSpacing.md,
                ),
                child: _SelectionSummaryCard(filters: _filters),
              ),
            ),

            // ── Téléchargement PDF (pasteur/trésorier uniquement) ──────────────
            if (canDownload)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SignmeSpacing.lg, 0,
                    SignmeSpacing.lg, SignmeSpacing.md,
                  ),
                  child: PdfDownloadButton(
                    label: _filters.eventId != null
                        ? 'Télécharger cet événement (PDF)'
                        : 'Télécharger toutes les contributions (PDF)',
                    path: ApiConfig.contributionsEvenementsExportPdf,
                    filename: 'contributions-evenement.pdf',
                    queryParameters: _filters.toQueryParams(),
                  ),
                ),
              ),

            // ── En-tête liste ─────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.sm,
                  SignmeSpacing.lg, SignmeSpacing.sm,
                ),
                child: Row(
                  children: [
                    Text(
                      'Liste des contributions',
                      style: SignmeTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    if (listState.items.isNotEmpty)
                      Text(
                        '${listState.items.length} résultat${listState.items.length > 1 ? 's' : ''}',
                        style: SignmeTypography.bodySmall
                            .copyWith(color: SignmeColors.mediumGray),
                      ),
                  ],
                ),
              ),
            ),

            // ── Liste de contributions ────────────────────────────────────────
            if (listState.error != null && listState.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.wifi_off_rounded,
                            size: 48, color: SignmeColors.mediumGray),
                        const SizedBox(height: SignmeSpacing.md),
                        Text('Impossible de charger les contributions.',
                            style: SignmeTypography.bodyMedium
                                .copyWith(color: SignmeColors.mediumGray)),
                        const SizedBox(height: SignmeSpacing.md),
                        TextButton.icon(
                          onPressed: () => ref
                              .read(contributionsTreasuryListProvider.notifier)
                              .refresh(_filters),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (listState.items.isEmpty && listState.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (listState.items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_rounded,
                            size: 48, color: SignmeColors.mediumGray),
                        const SizedBox(height: SignmeSpacing.md),
                        Text(
                          'Aucune contribution pour cette sélection.',
                          style: SignmeTypography.bodyMedium
                              .copyWith(color: SignmeColors.mediumGray),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                sliver: SliverList.separated(
                  itemCount: listState.items.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: SignmeSpacing.md),
                  itemBuilder: (context, i) =>
                      _ContributionCard(contribution: listState.items[i]),
                ),
              ),

            // ── Load-more / indicateur bas de liste ───────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  SignmeSpacing.lg, SignmeSpacing.md,
                  SignmeSpacing.lg, 120,
                ),
                child: _LoadMoreIndicator(
                  isLoading: listState.isLoading && listState.items.isNotEmpty,
                  hasMore: listState.hasMore,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// _SynthesisCard — grand card bleu de synthèse globale
// ─────────────────────────────────────────────────────────────────────────────

class _SynthesisCard extends ConsumerWidget {
  const _SynthesisCard({required this.globalFilter});

  /// Toujours [ContributionsTreasuryFilter.empty] : le card bleu affiche
  /// les stats GLOBALES (sans aucun filtre appliqué).
  final ContributionsTreasuryFilter globalFilter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync =
        ref.watch(contributionsTreasuryStatsProvider(globalFilter));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
        ),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryLight.withValues(alpha: 0.30),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // En-tête
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: Colors.white70, size: 18),
              const SizedBox(width: SignmeSpacing.sm),
              Text(
                'Aperçu global',
                style: SignmeTypography.labelLarge.copyWith(
                  color: Colors.white70,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 130),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SignmeSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius:
                        BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                  child: Text(
                    'Données actuelles',
                    style: SignmeTypography.labelSmall
                        .copyWith(color: Colors.white70, fontSize: 10),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.lg),

          // Métriques
          statsAsync.when(
            loading: _buildSkeleton,
            error: (_, __) => Text(
              'Stats indisponibles',
              style:
                  SignmeTypography.bodySmall.copyWith(color: Colors.white70),
            ),
            data: (stats) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Ligne 1 : Total contributions + Total frais perçus
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _StatTile(
                        icon: Icons.wallet_rounded,
                        label: 'Total contributions',
                        value: FinanceFormatters.fcfa(stats.netRecu),
                        sublabel: 'Montant net reversé',
                      ),
                    ),
                    const SizedBox(width: SignmeSpacing.md),
                    Expanded(
                      child: _StatTile(
                        icon: Icons.receipt_rounded,
                        label: 'Total frais',
                        value: FinanceFormatters.fcfa(stats.totalFrais),
                        sublabel: 'Frais de transaction',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: SignmeSpacing.md),

                // Ligne 2 : Reçu par l'église — pleine largeur
                Container(
                  padding: const EdgeInsets.all(SignmeSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(SignmeSpacing.radiusMd),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius:
                              BorderRadius.circular(SignmeSpacing.radiusSm),
                        ),
                        child: const Icon(Icons.church_rounded,
                            color: SignmeColors.primaryCyan, size: 20),
                      ),
                      const SizedBox(width: SignmeSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Reçu par l\'église',
                              style: SignmeTypography.labelSmall
                                  .copyWith(color: Colors.white70),
                            ),
                            Text(
                              FinanceFormatters.fcfa(stats.netRecu),
                              style: SignmeTypography.labelLarge.copyWith(
                                color: SignmeColors.primaryCyan,
                                fontWeight: FontWeight.w900,
                                fontSize: 17,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Montant net',
                        style: SignmeTypography.labelSmall
                            .copyWith(color: Colors.white54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),

          // Total payé
          statsAsync.maybeWhen(
            data: (stats) => Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: SignmeSpacing.md, vertical: SignmeSpacing.sm),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: Colors.white70, size: 16),
                  const SizedBox(width: SignmeSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Total Encaissé : ${FinanceFormatters.fcfa(stats.totalPaye)}',
                          style: SignmeTypography.labelMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Contributions + Frais',
                          style: SignmeTypography.labelSmall
                              .copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(
            2,
            (_) => Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: SignmeSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      height: 10,
                      width: 70,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      height: 18,
                      width: 90,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white12,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _StatTile — tuile compacte pour la ligne 2 colonnes
// ─────────────────────────────────────────────────────────────────────────────

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sublabel,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sublabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
              ),
              child: Icon(icon, color: Colors.white, size: 16),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Expanded(
              child: Text(
                label,
                style: SignmeTypography.labelSmall
                    .copyWith(color: Colors.white70),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          value,
          style: SignmeTypography.labelLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          sublabel,
          style: SignmeTypography.labelSmall.copyWith(color: Colors.white54),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// _FilterSection — 4 dropdowns 2×2 + bouton réinitialiser
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSection extends ConsumerWidget {
  const _FilterSection({
    required this.filters,
    required this.onChanged,
    required this.onReset,
  });

  final ContributionsTreasuryFilter filters;
  final ValueChanged<ContributionsTreasuryFilter> onChanged;
  final VoidCallback onReset;

  static const _months = [
    'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
    'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre',
  ];

  List<int> _years() {
    final now = DateTime.now().year;
    return List.generate(6, (i) => now - i);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(contributionsFilterEventsProvider);
    final groupesAsync = ref.watch(contributionsFilterGroupesProvider);

    final events = eventsAsync.valueOrNull ?? <ContributionFilterEventEntity>[];
    final groupes = groupesAsync.valueOrNull ?? <GroupeRef>[];

    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête filtres
          Row(
            children: [
              const Icon(Icons.tune_rounded,
                  color: SignmeColors.primaryLight, size: 18),
              const SizedBox(width: SignmeSpacing.sm),
              Text(
                'Filtres',
                style: SignmeTypography.labelLarge
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              if (filters.hasAnyFilter)
                GestureDetector(
                  onTap: onReset,
                  child: Row(
                    children: [
                      const Icon(Icons.refresh_rounded,
                          color: SignmeColors.primaryLight, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        'Réinitialiser',
                        style: SignmeTypography.labelSmall.copyWith(
                          color: SignmeColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.md),

          // Ligne 1 : Événement + Groupe
          Row(
            children: [
              Expanded(
                child: SignmeCompactDropdown<ContributionFilterEventEntity?>(
                  label: 'Événement',
                  value: events.where((e) => e.id == filters.eventId).firstOrNull,
                  items: events,
                  itemLabel: (e) => e == null ? 'Tous les événements' : e.titre,
                  hint: 'Tous les événements',
                  onChanged: (e) => onChanged(
                    filters.copyWith(
                      eventId: e?.id,
                      eventLabel: e?.titre,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: SignmeCompactDropdown<GroupeRef?>(
                  label: 'Groupe',
                  value: groupes.where((g) => g.id == filters.groupeId).firstOrNull,
                  items: groupes,
                  itemLabel: (g) => g == null ? 'Tous les groupes' : g.nom,
                  hint: 'Tous les groupes',
                  onChanged: (g) => onChanged(
                    filters.copyWith(
                      groupeId: g?.id,
                      groupeLabel: g?.nom,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),

          // Ligne 2 : Année + Mois
          Row(
            children: [
              Expanded(
                child: SignmeCompactDropdown<int?>(
                  label: 'Année',
                  value: filters.year,
                  items: _years(),
                  itemLabel: (y) => y == null ? 'Toutes' : y.toString(),
                  hint: 'Toutes les années',
                  onChanged: (y) => onChanged(filters.copyWith(year: y)),
                ),
              ),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: SignmeCompactDropdown<int?>(
                  label: 'Mois',
                  value: filters.month,
                  items: List.generate(12, (i) => i + 1),
                  itemLabel: (m) => m == null ? 'Tous les mois' : _months[m - 1],
                  hint: 'Tous les mois',
                  onChanged: (m) => onChanged(filters.copyWith(month: m)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _SelectionSummaryCard — résumé dynamique de la sélection
// ─────────────────────────────────────────────────────────────────────────────

class _SelectionSummaryCard extends ConsumerWidget {
  const _SelectionSummaryCard({required this.filters});

  final ContributionsTreasuryFilter filters;

  String get _periodeLabel {
    if (filters.year == null) return 'Toutes périodes';
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc',
    ];
    if (filters.month != null) {
      return '${months[filters.month! - 1]} ${filters.year}';
    }
    return 'An ${filters.year}';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(contributionsTreasuryStatsProvider(filters));

    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryDark.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Résumé de la sélection',
            style: SignmeTypography.labelLarge
                .copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: SignmeSpacing.sm),

          // Étiquettes de la sélection
          Row(
            children: [
              _FilterChip(
                icon: Icons.calendar_today_rounded,
                label: 'Période',
                value: _periodeLabel,
              ),
              const SizedBox(width: SignmeSpacing.sm),
              _FilterChip(
                icon: Icons.event_rounded,
                label: 'Événement',
                value: filters.eventLabel ?? 'Tous',
              ),
              const SizedBox(width: SignmeSpacing.sm),
              _FilterChip(
                icon: Icons.group_rounded,
                label: 'Groupe',
                value: filters.groupeLabel ?? 'Tous',
              ),
            ],
          ),
          const Divider(height: SignmeSpacing.lg, color: SignmeColors.lightGrayBorder),

          // Stats filtrées
          statsAsync.when(
            loading: () => const Center(
              child: SizedBox(
                  height: 32,
                  width: 32,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (_, __) => Text(
              'Impossible de charger les statistiques.',
              style: SignmeTypography.bodySmall
                  .copyWith(color: SignmeColors.mediumGray),
            ),
            data: (stats) => Row(
              children: [
                _SummaryStatColumn(
                  label: 'Contributeurs',
                  value: _formatCount(stats.nombreContributeurs),
                  color: SignmeColors.primaryLight,
                  icon: Icons.people_alt_rounded,
                ),
                _SummaryStatColumn(
                  label: 'Total frais',
                  value: FinanceFormatters.fcfa(stats.totalFrais),
                  color: SignmeColors.warning,
                  icon: Icons.receipt_rounded,
                ),
                _SummaryStatColumn(
                  label: 'Contributions',
                  value: FinanceFormatters.fcfa(stats.netRecu),
                  color: SignmeColors.success,
                  icon: Icons.church_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatCount(int n) {
    if (n >= 1000) return '${(n ~/ 1000)}.${((n % 1000) ~/ 100)}k';
    return n.toString();
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: SignmeColors.primaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: SignmeTypography.labelSmall
                      .copyWith(color: SignmeColors.mediumGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: SignmeTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: SignmeColors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryStatColumn extends StatelessWidget {
  const _SummaryStatColumn({
    required this.label,
    required this.value,
    required this.color,
    this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon!, size: 12, color: color),
                const SizedBox(width: 4),
              ],
              Expanded(
                child: Text(
                  label,
                  style: SignmeTypography.labelSmall
                      .copyWith(color: SignmeColors.darkGray),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: SignmeTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w800,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
// ─────────────────────────────────────────────────────────────────────────────
// _LoadMoreIndicator — bas de liste
// ─────────────────────────────────────────────────────────────────────────────

class _LoadMoreIndicator extends StatelessWidget {
  const _LoadMoreIndicator({required this.isLoading, required this.hasMore});

  final bool isLoading;
  final bool hasMore;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(SignmeSpacing.md),
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (!hasMore) return const SizedBox.shrink();
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _ContributionCard — carte individuelle (inchangée par rapport à l'original)
// ─────────────────────────────────────────────────────────────────────────────

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.contribution});
  final ContributionEntity contribution;

  Color get _statutColor => switch (contribution.statut) {
        'completed' => SignmeColors.success,
        'failed' => SignmeColors.error,
        _ => SignmeColors.warning,
      };

  String get _statutLabel => switch (contribution.statut) {
        'completed' => 'Payé',
        'failed' => 'Échoué',
        _ => 'En attente',
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        boxShadow: [
          BoxShadow(
            color: SignmeColors.primaryDark.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // clipBehavior au lieu de ClipRRect imbriqué — évite le double-clip
      // qui coupait les caractères proches des coins arrondis.
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(width: 4, color: _statutColor),
              Expanded(
                child: Padding(
                  // padding horizontal = lg (20px) > radiusLg (16px) :
                  // le texte est toujours hors de la zone coupée par le coin.
                  padding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.lg,
                    vertical: SignmeSpacing.md,
                  ),
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SignmeLeadingIconAvatar(
                icon: Icons.event_rounded, color: _statutColor),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          contribution.evenementTitre ?? 'Événement',
                          style: SignmeTypography.labelLarge
                              .copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _statutColor.withOpacity(0.1),
                          borderRadius:
                              BorderRadius.circular(SignmeSpacing.radiusFull),
                        ),
                        child: Text(
                          _statutLabel,
                          style: SignmeTypography.labelSmall.copyWith(
                            color: _statutColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          contribution.contributeurNom ?? 'Contributeur',
                          style: SignmeTypography.bodySmall
                              .copyWith(color: SignmeColors.mediumGray),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: SignmeSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: SignmeColors.accentSky,
                          borderRadius:
                              BorderRadius.circular(SignmeSpacing.radiusFull),
                        ),
                        child: Text(
                          contribution.contributeurGroupeNom ?? 'Sans groupe',
                          style: SignmeTypography.labelSmall.copyWith(
                            color: SignmeColors.primaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Divider(
            height: SignmeSpacing.lg, color: SignmeColors.lightGrayBorder),
        Row(
          children: [
            Expanded(
                child: _infoColumn(
                    'Montant', FinanceFormatters.fcfaShort(contribution.montant))),
            Expanded(
                child: _infoColumn(
                    'Frais', FinanceFormatters.fcfaShort(contribution.frais))),
            Expanded(
                child: _infoColumn(
                    'Payé (Total)',
                    FinanceFormatters.fcfaShort(contribution.montantTotal),
                    highlight: true)),
          ],
        ),
        const SizedBox(height: SignmeSpacing.sm),
        Text(
          DateFormat('dd MMM yyyy à HH:mm', 'fr_FR')
              .format(contribution.createdAt),
          style: SignmeTypography.labelSmall
              .copyWith(color: SignmeColors.mediumGray),
        ),
        if (contribution.paymentReference != null) ...[
          const SizedBox(height: 2),
          Text(
            'Réf. trx.${contribution.paymentReference}',
            style: SignmeTypography.labelSmall
                .copyWith(color: SignmeColors.mediumGray),
          ),
        ],
        if (contribution.paymentNumber != null) ...[
          const SizedBox(height: 2),
          Text(
            '${contribution.paymentOperator ?? ''} · ${contribution.paymentNumber}',
            style: SignmeTypography.labelSmall
                .copyWith(color: SignmeColors.mediumGray),
          ),
        ],
        if (contribution.note != null && contribution.note!.isNotEmpty) ...[
          const SizedBox(height: SignmeSpacing.sm),
          Container(
            padding: const EdgeInsets.all(SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: SignmeColors.accentSky.withOpacity(0.4),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
            ),
            child: Text(
              contribution.note!,
              style: SignmeTypography.bodySmall
                  .copyWith(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ],
    );
  }

  Widget _infoColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: SignmeTypography.labelSmall
                .copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: 2),
        Text(
          value,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
          ),
        ),
      ],
    );
  }
}
