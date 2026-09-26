import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/index.dart';
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
              ],
            ),
          ),
          ...SignmeAsyncValue.buildSlivers<List<HistoriquePersonnelEntity>>(
            value: historiqueAsync,
            onRetry: () => ref.read(
              historiquePersonnelCombinedProvider(_selectedYear).notifier,
            ).refresh(),
            emptyIcon: Icons.history_rounded,
            emptyTitle: 'Aucune signature',
            emptyMessage: 'Vous n\'avez pas encore de signature pour cette année.',
            isEmpty: (historique) => historique.isEmpty,
            data: (historique) {
              final sections = groupTimelineByMonth<HistoriquePersonnelEntity>(
                items: historique,
                monthKeyOf: (sig) => sig.month,
                cardBuilder: (sig) => _buildSignatureCard(context, sig),
              );
              return buildSignmeTimelineSlivers(sections: sections);
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildSignatureCard(
    BuildContext context,
    HistoriquePersonnelEntity sig,
  ) {
    final statusColor = sig.isCompleted
        ? SignmeColors.success
        : sig.isFailed
            ? SignmeColors.error
            : SignmeColors.warning;
    final statusIcon = sig.isCompleted
        ? Icons.check_circle_rounded
        : sig.isFailed
            ? Icons.cancel_rounded
            : Icons.schedule_rounded;

    return SignmeTimelineCard(
      heading: sig.shortDateLabel,
      subtitle: sig.signatureTypeFr,
      timestamp: sig.formattedDate,
      statusLabel: sig.statusFr,
      statusColor: statusColor,
      statusIcon: statusIcon,
      amountLabel: '${sig.amount} F',
      // Le moyen de paiement mobile money n'a de sens que pour une signature
      // à distance — jamais affiché pour une signature présentiel, même si
      // les données contenaient (par erreur) un paymentMethod renseigné.
      paymentMethodColor: sig.isDistance ? paymentOperatorColor(sig.paymentMethod) : null,
      paymentMethodLabel: sig.isDistance ? paymentOperatorLabel(sig.paymentMethod) : null,
      paymentPhoneNumber: sig.isDistance ? sig.paymentPhoneNumber : null,
      onTap: () => _showDetail(context, sig),
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
