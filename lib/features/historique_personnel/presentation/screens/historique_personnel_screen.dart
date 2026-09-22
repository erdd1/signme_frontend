import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/historique_personnel_entity.dart';
import '../providers/historique_personnel_combined_provider.dart';
import '../../../badge/presentation/providers/badge_provider.dart';

class HistoriquePersonnelScreen extends ConsumerStatefulWidget {
  const HistoriquePersonnelScreen({super.key});

  @override
  ConsumerState<HistoriquePersonnelScreen> createState() =>
      _HistoriquePersonnelScreenState();
}

class _HistoriquePersonnelScreenState
    extends ConsumerState<HistoriquePersonnelScreen> {
  late String _selectedYear = DateTime.now().year.toString();

  @override
  void initState() {
    super.initState();
    // Rafraîchit silencieusement à chaque ouverture de l'écran (les données
    // déjà en cache restent affichées pendant la mise à jour en arrière-plan).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(historiquePersonnelCombinedProvider(_selectedYear).notifier).refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    if (user != null && !AppPermissions.canViewHistoriquePersonnel(user)) {
      return const SignmeNoPermissionState(
        title: 'Fonctionnalité bloquée',
        message: AppPermissions.notCommuniantMessage,
        icon: Icons.history_toggle_off_rounded,
      );
    }

    final historiqueAsync =
        ref.watch(historiquePersonnelCombinedProvider(_selectedYear));

    final yearInt = int.tryParse(_selectedYear) ?? DateTime.now().year;

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () async {
        await ref
            .read(historiquePersonnelCombinedProvider(_selectedYear).notifier)
            .refresh();
        // Marquer le badge historique comme lu
        await ref
            .read(badgeNotifierProvider.notifier)
            .markRead('historique');
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            const OnboardingSection(
              svgPath: SignmeAssets.onboardingHistorique,
              title: 'Historique des signatures',
              description: 'Retrouvez toutes vos signatures enregistrées.',
            ),
            const SizedBox(height: SignmeSpacing.lg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
              child: SignmeYearSelector(
                year: yearInt,
                label: 'Filtrer par année',
                minYear: DateTime.now().year,
                maxYear: DateTime.now().year + 4,
                onPrevious: () => setState(() {
                  _selectedYear = (yearInt - 1).toString();
                }),
                onNext: () => setState(() {
                  _selectedYear = (yearInt + 1).toString();
                }),
              ),
            ),
            const SizedBox(height: SignmeSpacing.md),
            SizedBox(
              // Bornée pour rester utilisable sur les écrans courts/paysage
              // (jamais en dessous de 320) sans devenir démesurée sur tablette.
              height: (MediaQuery.of(context).size.height * 0.65).clamp(320.0, 900.0),
              child: SignmeAsyncValue<List<HistoriquePersonnelEntity>>(
                value: historiqueAsync,
                fitViewport: false,

                onRetry: () => ref.read(
                  historiquePersonnelCombinedProvider(_selectedYear).notifier,
                ).refresh(),

                emptyIcon: Icons.history_rounded,
                emptyTitle: 'Aucune signature',
                emptyMessage:
                'Vous n\'avez pas encore de signature pour cette année.',

                isEmpty: (historique) => historique.isEmpty,

                loading: ListView.builder(
                  padding: const EdgeInsets.all(SignmeSpacing.lg),
                  itemCount: 3,
                  itemBuilder: (_, __) => const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: AppShimmerBox(
                      height: 120,
                      width: double.infinity,
                      radius: SignmeSpacing.radiusLg,
                    ),
                  ),
                ),

                data: (historique) {
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      SignmeSpacing.lg,
                      0,
                      SignmeSpacing.lg,
                      120,
                    ),
                    itemCount: historique.length,
                    itemBuilder: (context, index) =>
                        _buildSignatureCard(context, historique[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignatureCard(
    BuildContext context,
    HistoriquePersonnelEntity sig,
  ) {
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
          decoration: BoxDecoration(
            color: (sig.isCompleted ? SignmeColors.success : SignmeColors.warning)
                .withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            sig.isCompleted
                ? Icons.check_circle_rounded
                : Icons.pending_rounded,
            color:
                sig.isCompleted ? SignmeColors.success : SignmeColors.warning,
            size: 28,
          ),
        ),
        title: Text(
          sig.month,
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              sig.signatureTypeFr,
              style: SignmeTypography.bodySmall.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              sig.formattedDate,
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.mediumGray,
                fontSize: 10,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${sig.amount} F',
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: SignmeColors.primaryDark,
          ),
        ),
        onTap: () => _showDetail(context, sig),
      ),
    );
  }

  void _showDetail(BuildContext context, HistoriquePersonnelEntity sig) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        ),
        title: Text(
          'Détails Signature',
          style: SignmeTypography.headlineSmall.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _detailRow('Mois:', sig.month),
            _detailRow('Type:', sig.signatureTypeFr),
            _detailRow('Montant:', '${sig.amount} FCFA'),
            _detailRow('Date:', sig.formattedDate),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Fermer',
              style: SignmeTypography.labelMedium.copyWith(
                color: SignmeColors.primaryLight,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: SignmeTypography.bodySmall.copyWith(
              color: SignmeColors.mediumGray,
            ),
          ),
          Text(
            value,
            style: SignmeTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: SignmeColors.black,
            ),
          ),
        ],
      ),
    );
  }
}
