import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/onboarding_section.dart';
import '../../domain/entities/rapport_secretaire_entity.dart';
import '../../domain/entities/rapport_membre_entity.dart';
import '../providers/rapports_provider.dart';
import 'rapport_signes_screen.dart';
import 'rapport_non_signes_screen.dart';

class RapportSecretaireScreen extends ConsumerStatefulWidget {
  const RapportSecretaireScreen({super.key});

  @override
  ConsumerState<RapportSecretaireScreen> createState() =>
      _RapportSecretaireScreenState();
}

class _RapportSecretaireScreenState extends ConsumerState<RapportSecretaireScreen> {
  late String _selectedMonth;

  @override
  void initState() {
    super.initState();
    // Initialiser avec le mois courant
    final now = DateTime.now();
    _selectedMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    // Rafraîchit silencieusement à chaque ouverture de l'écran (les données
    // déjà affichées restent visibles pendant la mise à jour en arrière-plan).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(rapportSecretaireProvider.notifier).refreshSilently();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rapportSecretaireProvider);

    return SingleChildScrollView(

      child: Column(

        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [

          const OnboardingSection(

            svgPath:
            'assets/images/unboarding_rapport_secretaire.svg',

            title: 'Rapports & Statistiques',

            description:
            'Consultez les statistiques et rapports mensuels de l’église.',
          ),

          const SizedBox(height: SignmeSpacing.lg),

          Padding(

            padding: const EdgeInsets.fromLTRB(
              SignmeSpacing.lg,
              SignmeSpacing.md,
              SignmeSpacing.lg,
              120,
            ),

            child: Column(

              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [

                Text(

                  'Sélectionner le mois',

                  style: SignmeTypography.labelLarge
                      .copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: SignmeSpacing.md,
                ),

                _buildMonthSelector(),

                const SizedBox(
                  height: SignmeSpacing.xl,
                ),

                // ── Affichage du message d'erreur (optionnel) ─────────────────
                if (state.error != null && state.error!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: SignmeSpacing.lg),
                    child: Container(
                      padding: const EdgeInsets.all(SignmeSpacing.md),
                      decoration: BoxDecoration(
                        color: SignmeColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                        border: Border.all(color: SignmeColors.error.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: SignmeColors.error, size: 20),
                          const SizedBox(width: SignmeSpacing.md),
                          Expanded(
                            child: Text(
                              state.error!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: SignmeTypography.bodySmall.copyWith(
                                color: SignmeColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // ── Les cartes restent toujours visibles ────────────────────
                _buildRapportContent(state, _selectedMonth),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (i) {
        final month = '${DateTime.now().year}-${(i + 1).toString().padLeft(2, '0')}';
        final isSel = _selectedMonth == month;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedMonth = month);
            ref.read(rapportSecretaireProvider.notifier).load(month: month);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSel ? SignmeColors.primaryLight : SignmeColors.white,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              border: Border.all(
                  color: isSel ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder),
            ),
            child: Text(
              AppStrings.moisShort[i],
              style: SignmeTypography.labelSmall.copyWith(
                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                color: isSel ? Colors.white : SignmeColors.black,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRapportContent(RapportState state, String month) {
    // Convertir les données JSON en objets RapportMembreEntity
    final signesMembers = state.data.signes
            ?.map<RapportMembreEntity>(
                (item) => RapportMembreEntity.fromJson(item))
            .toList() ??
        [];

    final nonSignesMembers = state.data.nonSignes
            ?.map<RapportMembreEntity>(
                (item) => RapportMembreEntity.fromJson(item))
            .toList() ??
        [];

    return Column(
      children: [
        _StatCard(
          icon: Icons.people_rounded,
          label: 'Total Membres',
          value: '${state.data.totalMembers}',
          color: SignmeColors.primaryLight,
          isLoading: state.isLoading,
        ),
        const SizedBox(height: SignmeSpacing.md),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RapportSignesScreen(
                  signes: signesMembers,
                  month: month,
                ),
              ),
            );
          },
          child: _StatCard(
            icon: Icons.check_circle_rounded,
            label: 'Signatures',
            value: '${state.data.membersSigned}',
            color: SignmeColors.success,
            isLoading: state.isLoading,
            isClickable: true,
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RapportNonSignesScreen(
                  nonSignes: nonSignesMembers,
                  month: month,
                ),
              ),
            );
          },
          child: _StatCard(
            icon: Icons.cancel_rounded,
            label: 'Non Signés',
            value: '${state.data.membersNotSigned}',
            color: SignmeColors.error,
            isLoading: state.isLoading,
            isClickable: true,
          ),
        ),
        const SizedBox(height: SignmeSpacing.md),
        _StatCard(
          icon: Icons.trending_up_rounded,
          label: 'Taux de Signature',
          value: '${state.data.signatureRate.toStringAsFixed(1)}%',
          color: Colors.purple,
          isLoading: state.isLoading,
        ),
        const SizedBox(height: SignmeSpacing.md),
        _StatCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Montant Collecté',
          value: '${state.data.totalAmount.toStringAsFixed(0)} F',
          color: SignmeColors.primaryCyan,
          isLoading: state.isLoading,
        ),
      ],
    );
  }

}

/// Widget réutilisable pour les cartes de statistiques
/// Affiche le shimmer pendant le chargement, reste visible même en cas d'erreur
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isLoading;
  final bool isClickable;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isLoading = false,
    this.isClickable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: SignmeSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: SignmeTypography.bodySmall.copyWith(
                    color: SignmeColors.mediumGray,
                  ),
                ),
                const SizedBox(height: 6),
                if (isLoading)
                  // ── Shimmer pour la valeur pendant le chargement ───────────
                  const AppShimmerBox(
                    width: 80,
                    height: 24,
                    radius: SignmeSpacing.radiusMd,
                  )
                else
                  // ── Affichage de la valeur ────────────────────────────────
                  Text(
                    value,
                    style: SignmeTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.bold,
                      color: SignmeColors.black,
                    ),
                  ),
              ],
            ),
          ),
          // ── Icône flèche pour les cartes clickables ─────────────────────
          if (isClickable)
            Icon(
              Icons.arrow_forward_rounded,
              color: color.withValues(alpha: 0.5),
              size: 20,
            ),
        ],
      ),
    );
  }
}
