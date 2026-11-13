import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/onboarding_section.dart';
import '../../../main/presentation/screens/main_shell.dart' show kFloatingNavClearance, floatingNavInset;
import '../../domain/entities/ancien_entity.dart';
import '../providers/anciens_provider.dart';
import '../widgets/ancien_card.dart';
import '../widgets/designation_form_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';

class AncienDesignationsScreen extends ConsumerStatefulWidget {
  const AncienDesignationsScreen({super.key});

  @override
  ConsumerState<AncienDesignationsScreen> createState() =>
      _AncienDesignationsScreenState();
}

class _AncienDesignationsScreenState
    extends ConsumerState<AncienDesignationsScreen> {
  @override
  void initState() {
    super.initState();
    // Rafraîchit silencieusement à chaque ouverture de l'écran (les données
    // déjà affichées restent visibles pendant la mise à jour en arrière-plan).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ancienProvider.notifier).refreshSilently();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ancienProvider);

    final isMinDate =
        state.annee == 2026 &&
            state.mois == 1;

    final isMaxDate =
        state.annee == 2030 &&
            state.mois == 12;

    return SingleChildScrollView(
      // Padding bas dynamique : la liste imbriquée plus bas a sa propre
      // hauteur bornée (SizedBox) et ne touche jamais le bas de l'écran —
      // c'est CETTE marge, sur le scroll englobant, qui dégage réellement la
      // navbar flottante sur tous les appareils (voir kFloatingNavClearance).
      padding: EdgeInsets.only(
        bottom: kFloatingNavClearance + MediaQuery.of(context).padding.bottom + SignmeSpacing.xl,
      ),
      child: Column(
        children: [

          // ── Section Onboarding (Typée & Centralisée) ──────────────────────
          const OnboardingSection(
            svgPath: SignmeAssets.onboardingAnciens,
            title: 'Gestion des services',
            description:
            'Désignez les anciens de service et configurez leurs horaires pour le mois.',
          ),

          const SizedBox(height: SignmeSpacing.lg),

          // ── Barre de contrôle (Design System) ─────────────────────────────
          Container(

            padding: const EdgeInsets.symmetric(
              horizontal: SignmeSpacing.lg,
              vertical: SignmeSpacing.md,
            ),

            decoration: BoxDecoration(

              color: SignmeColors.white,

              boxShadow: [

                BoxShadow(

                  color:
                  SignmeColors.black.withOpacity(0.05),

                  blurRadius: 4,

                  offset: const Offset(0, 2),
                ),
              ],
            ),

            child: Row(

              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,

              children: [

                Expanded(
                  child: Row(
                    children: [

                      IconButton(
                        icon: Icon(
                          Icons.chevron_left_rounded,
                          color: isMinDate
                              ? SignmeColors.mediumGray
                              : SignmeColors.primaryLight,
                        ),
                        onPressed: isMinDate
                            ? null
                            : () => ref
                            .read(ancienProvider.notifier)
                            .previousMonth(),
                      ),

                      Expanded(
                        child: Text(

                          _monthYearLabel(
                            state.mois,
                            state.annee,
                          ),

                          style: SignmeTypography.labelLarge
                              .copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ),

                      IconButton(
                        icon: Icon(
                          Icons.chevron_right_rounded,
                          color: isMaxDate
                              ? SignmeColors.mediumGray
                              : SignmeColors.primaryLight,
                        ),
                        onPressed: isMaxDate
                            ? null
                            : () => ref
                            .read(ancienProvider.notifier)
                            .nextMonth(),
                      ),
                    ],
                  ),
                ),

                InkWell(

                  onTap: () {

                    _showMonthPicker(
                      context,
                      ref,
                      state,
                    );
                  },

                  borderRadius: BorderRadius.circular(
                    SignmeSpacing.radiusLg,
                  ),

                  child: Container(

                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),

                    decoration: BoxDecoration(

                      color: SignmeColors.accentSky
                          .withOpacity(0.5),

                      borderRadius:
                      BorderRadius.circular(20),
                    ),

                    child: Row(
                      children: [

                        Text(

                          '${state.mois}/${state.annee}',

                          style: SignmeTypography
                              .labelSmall
                              .copyWith(
                            fontWeight:
                            FontWeight.bold,

                            color:
                            SignmeColors.primaryLight,
                          ),
                        ),

                        const SizedBox(width: 4),

                        const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color:
                          SignmeColors.primaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: SignmeSpacing.md),

          // ── Contenu scrollable indépendant ────────────────────────────────
          SizedBox(

            // Bornée pour rester utilisable sur les écrans courts/paysage
            // (jamais en dessous de 320) sans devenir démesurée sur tablette.
            height:
            (MediaQuery.of(context).size.height * 0.65).clamp(320.0, 900.0),

            child: _buildBody(
              context,
              ref,
              state,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext ctx, WidgetRef ref, AncienState state) {
    if (state.isLoading && state.anciens.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.all(SignmeSpacing.lg),
        itemCount: 3,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppShimmerBox(height: 120, width: double.infinity, radius: SignmeSpacing.radiusLg),
        ),
      );
    }

    if (state.anciens.isEmpty) {
      return Center(
        child: Text(
          'Aucun ancien pour ce mois', 
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray)
        )
      );
    }

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(ancienProvider.notifier).refresh(),
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.md, SignmeSpacing.lg, floatingNavInset(context)),
        itemCount: state.anciens.length,
        itemBuilder: (_, index) {
          final ancien = state.anciens[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: SignmeSpacing.md),
            child: AncienCard(
              ancien: ancien,
              onDesignate: () => _showDesignationDialog(ctx, ref, ancien),
              onRevoke: ancien.designationId != null ? () => _showRevokeConfirm(ctx, ref, ancien) : null,
            ),
          );
        },
      ),
    );
  }

  // --- Dialogs & Helpers (Design System Compliance) ---

  void _showMonthPicker(BuildContext ctx, WidgetRef ref, AncienState state) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        title: Text('Sélectionner le mois', style: SignmeTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            // Largeur max par colonne (plutôt qu'un nombre de colonnes
            // fixe) : s'adapte si le dialogue s'élargit sur une tablette.
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 90,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            shrinkWrap: true,
            itemCount: 12,
            itemBuilder: (context, i) {
              final month = i + 1;
              final bool isSelected = month == state.mois;
              return InkWell(
                onTap: () {
                  ref.read(ancienProvider.notifier).changeMonth(month, state.annee);
                  Navigator.pop(ctx);
                },
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected ? SignmeColors.primaryLight : SignmeColors.accentSky.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  ),
                  child: Center(
                    child: Text(
                      month.toString(),
                      style: SignmeTypography.bodyLarge.copyWith(
                        color: isSelected ? SignmeColors.white : SignmeColors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showDesignationDialog(BuildContext ctx, WidgetRef ref, AncienEntity ancien) {
     showDialog(
      context: ctx,
      builder: (_) => DesignationFormDialog(
        ancienNom: ancien.nom,
        onDesignate: (jours, debut, fin) async {
          final ok = await ref.read(ancienProvider.notifier).designate(
            ancienId: ancien.userId,
            joursTravail: jours,
            horairesDebut: debut,
            horairesFin: fin,
          );
          if (ok && ctx.mounted) {
            AppSnackbar.success(ctx, 'Désignation réussie');
          }
        },
      ),
    );
  }

  void _showRevokeConfirm(BuildContext ctx, WidgetRef ref, AncienEntity ancien) {
    showDialog(
      context: ctx,
      builder: (diagCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        title: Text('Confirmer la révocation', style: SignmeTypography.headlineSmall.copyWith(fontSize: 18, fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment retirer ${ancien.nom} de son service ?', style: SignmeTypography.bodyMedium),
        actions: [
          TextButton(onPressed: () => Navigator.pop(diagCtx), child: Text('Annuler', style: TextStyle(color: SignmeColors.mediumGray))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: SignmeColors.error),
            onPressed: () {
              Navigator.pop(diagCtx);
              ref.read(ancienProvider.notifier).revoke(ancien.designationId!);
            }, 
            child: const Text('Révoquer', style: TextStyle(color: Colors.white))
          ),
        ],
      ),
    );
  }

  String _monthYearLabel(int mois, int annee) {
    final months = ['Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${months[mois - 1]} $annee';
  }
}
