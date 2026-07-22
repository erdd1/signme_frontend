import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../domain/entities/historique_signatures_entity.dart';
import '../providers/historique_signatures_provider.dart';
import '../../../badge/presentation/providers/badge_provider.dart';

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

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async {
        await ref.read(historiqueSignaturesProvider(_selectedYear).notifier).refresh();
        // Marquer le badge historique signatures comme lu
        await ref
            .read(badgeNotifierProvider.notifier)
            .markRead('historique_signatures');
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
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
            SizedBox(
              // Bornée pour rester utilisable sur les écrans courts/paysage
              // (jamais en dessous de 320) sans devenir démesurée sur tablette.
              height: (MediaQuery.of(context).size.height * 0.65).clamp(320.0, 900.0),
              child: SignmeAsyncValue<List<HistoriqueSignaturesEntity>>(
                value: historiqueAsync,
                onRetry: () => ref.read(historiqueSignaturesProvider(_selectedYear).notifier).refresh(),
                emptyIcon: Icons.history_rounded,
                emptyTitle: 'Aucune signature trouvée',
                emptyMessage: 'Vos signatures effectuées en présentiel apparaîtront ici.',
                isEmpty: (historique) => _filtered(historique).isEmpty,
                data: (historique) {
                  final filtered = _filtered(historique);

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                        SignmeSpacing.lg, 0, SignmeSpacing.lg, 120),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) =>
                        _buildSignatureCard(filtered[index]),
                  );
                },
              ),
            ),
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
    return Card(
      margin: const EdgeInsets.only(bottom: SignmeSpacing.md),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        side: BorderSide(color: SignmeColors.lightGrayBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(SignmeSpacing.md),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: SignmeColors.success.withOpacity(0.1), shape: BoxShape.circle),
          child: const Icon(Icons.check_circle_rounded, color: SignmeColors.success, size: 28),
        ),
        title: Text(
          sig.nomParoissien,
          style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(sig.formattedDate, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
            Text(sig.churchName, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.primaryLight, fontSize: 10)),
          ],
        ),
        trailing: Text('${sig.amount ?? 0} F', style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, color: SignmeColors.primaryDark)),
      ),
    );
  }
}