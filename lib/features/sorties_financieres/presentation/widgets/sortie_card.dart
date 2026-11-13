import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/sortie_financiere_entity.dart';
import '../providers/sortie_form_provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/signme_dialogs.dart';

class SortieCard extends ConsumerWidget {
  const SortieCard({super.key, required this.sortie, required this.onChanged, this.onEdit});

  final SortieFinanciereEntity sortie;
  final VoidCallback onChanged;

  /// Callback ouvrant le formulaire en mode édition. `null` masque le
  /// bouton "Modifier" même si [sortie.canEdit] est vrai.
  final VoidCallback? onEdit;

  Color get _statusColor {
    if (sortie.isApproved) return SignmeColors.success;
    if (sortie.isPending) return SignmeColors.warning;
    return SignmeColors.error;
  }

  String get _statusLabel {
    if (sortie.isApproved) return '✓ Approuvée';
    if (sortie.isPending) return '⏳ En attente';
    return '✗ Rejetée';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _statusColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(SignmeSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            sortie.description,
                            style: SignmeTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: SignmeSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _statusLabel,
                            style: TextStyle(color: _statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: SignmeSpacing.sm),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: SignmeColors.lightGray,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            sortie.isSimple ? 'Simple' : 'Frais',
                            style: const TextStyle(fontSize: 12, color: SignmeColors.darkGray),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          FinanceFormatters.fcfa(sortie.montant),
                          style: SignmeTypography.headlineSmall.copyWith(color: SignmeColors.black, fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                    const SizedBox(height: SignmeSpacing.sm),
                    Text(
                      "${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(sortie.createdAt))} · ${sortie.auteurNom}",
                      style: const TextStyle(fontSize: 12, color: SignmeColors.mediumGray),
                    ),
                    if (sortie.soldeApres != null) ...[
                      const SizedBox(height: 4),
                      Text('Solde après: ${FinanceFormatters.fcfa(sortie.soldeApres!)}', style: const TextStyle(fontSize: 12, color: SignmeColors.darkGray)),
                    ],
                    if (sortie.motifRejet != null && sortie.isRejected) ...[
                      const SizedBox(height: 4),
                      Text('Motif: ${sortie.motifRejet}', style: const TextStyle(fontSize: 12, color: SignmeColors.error)),
                    ],
                    if (sortie.canEdit || sortie.canDelete) ...[
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (sortie.canEdit && onEdit != null)
                            TextButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_rounded, color: SignmeColors.primaryLight, size: 16),
                              label: const Text('Modifier', style: TextStyle(color: SignmeColors.primaryLight)),
                            ),
                          if (sortie.canDelete)
                            TextButton.icon(
                              onPressed: () async {
                                final confirm = await signmeConfirm(
                                  context,
                                  title: 'Confirmer',
                                  message: 'Voulez-vous supprimer cette sortie ?',
                                  confirmLabel: 'Supprimer',
                                  isDangerous: true,
                                );
                                if (confirm == true) {
                                  await ref.read(sortieFormProvider.notifier).delete(sortie.uuid);
                                  onChanged();
                                }
                              },
                              icon: const Icon(Icons.delete, color: SignmeColors.error, size: 16),
                              label: const Text('Supprimer', style: TextStyle(color: SignmeColors.error)),
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
