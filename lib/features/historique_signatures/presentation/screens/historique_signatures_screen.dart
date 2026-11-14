import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/historique_signatures_entity.dart';
import '../providers/historique_signatures_provider.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../../main/presentation/screens/main_shell.dart' show floatingNavInset;

class HistoriqueSignaturesScreen extends ConsumerStatefulWidget {
  const HistoriqueSignaturesScreen({super.key});

  @override
  ConsumerState<HistoriqueSignaturesScreen> createState() =>
      _HistoriqueSignaturesScreenState();
}

class _HistoriqueSignaturesScreenState extends ConsumerState<HistoriqueSignaturesScreen> {
  late String _selectedYear = DateTime.now().year.toString();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Rafraîchit silencieusement à chaque ouverture de l'écran (les données
    // déjà en cache restent affichées pendant la mise à jour en arrière-plan).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historiqueSignaturesProvider(_selectedYear).notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historiqueAsync = ref.watch(historiqueSignaturesProvider(_selectedYear));

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: const SignmePageAppBar(title: 'Historique signatures'),
      body: RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async {
        await ref.read(historiqueSignaturesProvider(_selectedYear).notifier).refresh();
        // Marquer le badge historique signatures comme lu
        await ref
            .read(badgeNotifierProvider.notifier)
            .markRead('historique_signatures');
      },
      // CustomScrollView unique (au lieu d'un SingleChildScrollView contenant
      // une ListView bornée en hauteur) : un seul scroll pour tout l'écran,
      // comme le module Mes dépenses — plus de double défilement imbriqué.
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const OnboardingSection(
                  svgPath: 'assets/images/unboarding_historique_signature.svg',
                  title: 'Historique des Signatures',
                  description:
                  'Consultez ici toutes les signatures que vous avez effectuées en présentiel.',
                ),
                const SizedBox(height: SignmeSpacing.lg),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        style: SignmeTypography.bodyMedium,
                        decoration: InputDecoration(
                          hintText: 'Rechercher un paroissien...',
                          prefixIcon: const Icon(Icons.search_rounded,
                              color: SignmeColors.mediumGray),
                          filled: true,
                          fillColor: SignmeColors.accentSky.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(SignmeSpacing.radiusMd),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: SignmeSpacing.md),
                      _buildYearFilter(),
                    ],
                  ),
                ),
                const SizedBox(height: SignmeSpacing.md),
              ],
            ),
          ),
          ...SignmeAsyncValue.buildSlivers<List<HistoriqueSignaturesEntity>>(
            value: historiqueAsync,
            onRetry: () => ref.read(historiqueSignaturesProvider(_selectedYear).notifier).refresh(),
            emptyIcon: Icons.history_rounded,
            emptyTitle: 'Aucune signature trouvée',
            emptyMessage: 'Vos signatures effectuées en présentiel apparaîtront ici.',
            isEmpty: (historique) => _filtered(historique).isEmpty,
            data: (historique) {
              final filtered = _filtered(historique);
              final sections = groupTimelineByMonth<HistoriqueSignaturesEntity>(
                items: filtered,
                monthKeyOf: (sig) => sig.month,
                cardBuilder: _buildSignatureCard,
              );
              return buildSignmeTimelineSlivers(sections: sections);
            },
          ),
          SliverToBoxAdapter(child: SizedBox(height: floatingNavInset(context))),
        ],
      ),
    ),
    );
  }

  List<HistoriqueSignaturesEntity> _filtered(
      List<HistoriqueSignaturesEntity> historique,
      ) {
    if (_searchQuery.isEmpty) return historique;
    return historique
        .where((s) =>
        s.nomParoissien.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  Widget _buildYearFilter() {
    final years = List.generate(5, (i) => (DateTime.now().year + i).toString());
    return SignmeCompactDropdown<String>(
      label: 'Année',
      value: _selectedYear,
      items: years,
      itemLabel: (year) => 'Année $year',
      onChanged: (value) {
        if (value != null) setState(() => _selectedYear = value);
      },
    );
  }

  Widget _buildSignatureCard(HistoriqueSignaturesEntity sig) {
    final statusColor = sig.isCompleted
        ? SignmeColors.success
        : sig.isFailed
            ? SignmeColors.error
            : SignmeColors.warning;

    return SignmeTimelineCard(
      heading: sig.nomParoissien,
      subtitle: sig.churchName,
      timestamp: sig.formattedDate,
      statusLabel: sig.statusFr,
      statusColor: statusColor,
      amountLabel: '${sig.amount ?? 0} F',
    );
  }
}