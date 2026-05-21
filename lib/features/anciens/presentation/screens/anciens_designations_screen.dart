import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../domain/entities/ancien_entity.dart';
import '../providers/anciens_provider.dart';
import '../widgets/ancien_card.dart';
import '../widgets/designation_form_dialog.dart';

class AncienDesignationsScreen extends ConsumerWidget {
  const AncienDesignationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ancienProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context, ref, state),
      body: _buildBody(context, ref, state),
    );
  }

  // ── AppBar avec sélecteur de mois
  PreferredSizeWidget _buildAppBar(BuildContext ctx, WidgetRef ref, AncienState state) {
    return AppBar(
      backgroundColor: AppColors.surface,
      elevation: 2,
      shadowColor: Colors.black12,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Anciens de services',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            _monthYearLabel(state.mois, state.annee),
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
      actions: [
        // Mois précédent
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded, color: AppColors.textPrimary),
          onPressed: () => ref.read(ancienProvider.notifier).previousMonth(),
        ),

        // Sélecteur de mois/année
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Material(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () => _showMonthPicker(ctx, ref, state),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${state.mois}/${state.annee}',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.calendar_month_rounded,
                        size: 16, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Mois suivant
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded, color: AppColors.textPrimary),
          onPressed: () => ref.read(ancienProvider.notifier).nextMonth(),
        ),
      ],
    );
  }

  // ── Body
  Widget _buildBody(BuildContext ctx, WidgetRef ref, AncienState state) {
    // Loading
    if (state.isLoading && state.anciens.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 4,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 12),
          child: AppShimmerBox(height: 120, width: double.infinity, radius: 12),
        ),
      );
    }

    // Error
    if (state.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 48, color: AppColors.warning),
            const SizedBox(height: 12),
            Text(
              'Erreur',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(ancienProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (state.anciens.isEmpty) {
      return RefreshIndicator(
        onRefresh: () => ref.read(ancienProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            const SizedBox(height: 80),
            Center(
              child: Column(
                children: [
                  const Icon(Icons.people_outline_rounded,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun ancien à désigner',
                    style: GoogleFonts.poppins(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'ou tous les anciens sont déjà désignés pour ce mois',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.textHint,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // List of anciens
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(ancienProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: state.anciens.length + (state.isLoading ? 1 : 0),
        itemBuilder: (_, index) {
          // Loading indicator at end
          if (index >= state.anciens.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: AppShimmerBox(height: 120, width: double.infinity, radius: 12),
            );
          }

          final ancien = state.anciens[index];
          return AncienCard(
            ancien: ancien,
            onDesignate: () => _showDesignationDialog(
              ctx,
              ref,
              ancien,
            ),
            onRevoke: ancien.designationId != null
                ? () => _showRevokeConfirm(ctx, ref, ancien)
                : null,
          );
        },
      ),
    );
  }

  // ── Month picker dialog
  void _showMonthPicker(BuildContext ctx, WidgetRef ref, AncienState state) {
    showDialog(
      context: ctx,
      builder: (_) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sélectionnez un mois',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                children: List.generate(12, (i) {
                  final month = i + 1;
                  final isSelected = month == state.mois;
                  return GestureDetector(
                    onTap: () {
                      ref.read(ancienProvider.notifier).changeMonth(month, state.annee);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.background,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          _monthName(month),
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Designation dialog
  void _showDesignationDialog(
    BuildContext ctx,
    WidgetRef ref,
    AncienEntity ancien,
  ) {
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

          if (!ctx.mounted) return;

          if (ok) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text('${ancien.nom} a été désigné avec succès'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(content: Text('Erreur lors de la désignation')),
            );
          }
        },
      ),
    );
  }

  // ── Revoke confirmation
  void _showRevokeConfirm(
    BuildContext ctx,
    WidgetRef ref,
    AncienEntity ancien,
  ) {
    showDialog(
      context: ctx,
      builder: (dialogContext) => AlertDialog(  // ← Capture le bon contexte!
        backgroundColor: AppColors.surface,
        title: Text(
          'Révoquer la désignation',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir révoquer ${ancien.nom} ?',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),  // ← Utilise dialogContext
            child: Text(
              'Annuler',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              try {
                print('🗑️  [Screen] Début de révocation pour ancien: ${ancien.nom}');
                
                if (ancien.designationId != null) {
                  // ✅ Fermer le dialog IMMÉDIATEMENT avec le bon contexte
                  Navigator.pop(dialogContext);  // ← Utilise dialogContext
                  
                  // 🚀 Lancer la révocation en arrière-plan
                  ref.read(ancienProvider.notifier).revoke(ancien.designationId!).then((ok) {
                    print('🗑️  [Screen] Révocation complète: ok=$ok');
                    
                    if (!ctx.mounted) return;

                    if (ok) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(
                          content: Text('${ancien.nom} a été révoqué'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        const SnackBar(content: Text('Erreur lors de la révocation')),
                      );
                    }
                  }).catchError((e) {
                    print('❌ [Screen] Exception lors de la révocation: $e');
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Erreur: $e')),
                      );
                    }
                  });
                }
              } catch (e) {
                print('❌ [Screen] Exception synchrone: $e');
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Erreur: $e')),
                  );
                }
              }
            },
            child: Text(
              'Révoquer',
              style: GoogleFonts.poppins(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helper methods
  String _monthYearLabel(int mois, int annee) {
    final months = [
      'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin',
      'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'
    ];
    return '${months[mois - 1]} $annee';
  }

  String _monthName(int month) {
    const names = ['Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
                   'Juil', 'Aoû', 'Sep', 'Oct', 'Nov', 'Déc'];
    return names[month - 1];
  }
}
