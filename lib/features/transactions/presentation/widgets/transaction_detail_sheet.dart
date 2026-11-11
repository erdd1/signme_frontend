import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_status_chip.dart';

/// Récapitulatif d'une transaction (feuille du bas).
///
/// Ouverte sur le navigateur racine pour recouvrir proprement la navbar
/// flottante ; sa hauteur épouse son contenu (jamais plein écran).
Future<void> showTransactionDetailSheet(BuildContext context, TransactionEntity transaction) {
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: SignmeColors.white,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXxl)),
    ),
    builder: (_) => _TransactionDetailSheet(transaction: transaction),
  );
}

class _TransactionDetailSheet extends StatelessWidget {
  const _TransactionDetailSheet({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final local = t.createdAt.toLocal();
    final dateText =
        '${DateFormat('d MMM yyyy', 'fr_FR').format(local)} à ${DateFormat('HH:mm', 'fr_FR').format(local)}';

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(SignmeSpacing.xl, 0, SignmeSpacing.xl, SignmeSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: SignmeColors.primaryLight, size: 28),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: Text(
                      'Récapitulatif de la transaction',
                      style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: SignmeColors.black),
                    tooltip: 'Fermer',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.md),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(SignmeSpacing.lg),
                decoration: BoxDecoration(
                  color: SignmeColors.lightGray,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FinanceFormatters.fcfa(t.montantTotal),
                            style: SignmeTypography.headlineLarge.copyWith(fontWeight: FontWeight.w900),
                          ),
                          const SizedBox(height: SignmeSpacing.xs),
                          Text(t.typeLabel, style: SignmeTypography.bodyMedium),
                        ],
                      ),
                    ),
                    TransactionStatusChip(status: t.status),
                  ],
                ),
              ),
              const SizedBox(height: SignmeSpacing.xs),
              _Row(label: 'Détails', value: t.motif, extra: t.details),
              if (t.eglise != null) _Row(label: 'Destinataire', value: t.eglise!),
              _Row(label: 'Expéditeur', value: t.account),
              if (t.receivedBy != null) _Row(label: 'Reçu par', value: t.receivedBy!),
              _Row(label: 'Date et heure', value: dateText),
              _Row(label: 'Méthode de paiement', value: t.paymentLabel),
              _Row(
                label: 'Montant',
                value: FinanceFormatters.fcfa(t.montant),
                extra: t.frais > 0 ? ['+ ${FinanceFormatters.fcfa(t.frais)} de frais'] : const [],
              ),
              if (t.reference != null) _Row(label: 'Référence', value: t.reference!, small: true, last: true),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.label,
    required this.value,
    this.extra = const [],
    this.small = false,
    this.last = false,
  });

  final String label;
  final String value;
  final List<String> extra;
  final bool small;

  /// Dernière ligne : pas de filet dessous.
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
      decoration: BoxDecoration(
        border: last ? null : const Border(bottom: BorderSide(color: SignmeColors.lightGrayBorder)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary)),
          const SizedBox(height: 2),
          Text(
            value,
            style: (small ? SignmeTypography.bodySmall : SignmeTypography.bodyMedium).copyWith(
              fontWeight: FontWeight.w600,
              color: SignmeColors.black,
            ),
          ),
          for (final line in extra)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(line, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.darkGray)),
            ),
        ],
      ),
    );
  }
}
