import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/signme_pill_chip.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transactions_provider.dart';

/// Filtres de l'historique : statut et type de transaction.
Future<void> showTransactionsFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: SignmeColors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXxl)),
    ),
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(transactionsHistoryProvider).filters;
    final notifier = ref.read(transactionsHistoryProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(SignmeSpacing.xl, 0, SignmeSpacing.xl, SignmeSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('Filtrer', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
                ),
                if (filters.hasFilter)
                  TextButton(onPressed: notifier.clearFilters, child: const Text('Réinitialiser')),
              ],
            ),
            const SizedBox(height: SignmeSpacing.lg),
            _title('Statut'),
            Wrap(
              spacing: SignmeSpacing.sm,
              runSpacing: SignmeSpacing.sm,
              children: [
                SignmePillChip(label: 'Tous', selected: filters.statut == null, onTap: () => notifier.setStatut(null)),
                SignmePillChip(
                  label: 'Succès',
                  selected: filters.statut == TransactionStatus.completed,
                  onTap: () => notifier.setStatut(TransactionStatus.completed),
                ),
                SignmePillChip(
                  label: 'Échec',
                  selected: filters.statut == TransactionStatus.failed,
                  onTap: () => notifier.setStatut(TransactionStatus.failed),
                ),
                SignmePillChip(
                  label: 'En cours',
                  selected: filters.statut == TransactionStatus.pending,
                  onTap: () => notifier.setStatut(TransactionStatus.pending),
                ),
              ],
            ),
            const SizedBox(height: SignmeSpacing.xl),
            _title('Type'),
            Wrap(
              spacing: SignmeSpacing.sm,
              runSpacing: SignmeSpacing.sm,
              children: [
                SignmePillChip(label: 'Tous', selected: filters.type == null, onTap: () => notifier.setType(null)),
                SignmePillChip(
                  label: 'Contributions',
                  selected: filters.type == TransactionType.contribution,
                  onTap: () => notifier.setType(TransactionType.contribution),
                ),
                SignmePillChip(
                  label: 'Dons',
                  selected: filters.type == TransactionType.don,
                  onTap: () => notifier.setType(TransactionType.don),
                ),
                SignmePillChip(
                  label: 'Signatures',
                  selected: filters.type == TransactionType.signature,
                  onTap: () => notifier.setType(TransactionType.signature),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _title(String text) => Padding(
        padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
        child: Text(
          text.toUpperCase(),
          style: SignmeTypography.labelSmall.copyWith(
            color: SignmeColors.textSecondary,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.8,
          ),
        ),
      );
}
