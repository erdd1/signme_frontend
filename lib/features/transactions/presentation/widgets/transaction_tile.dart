import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/signme_payment_method_info.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/transaction_entity.dart';
import 'transaction_status_chip.dart';

/// Ligne de transaction : moyen de paiement, compte, motif et statut à
/// gauche ; montant et date (jour, heure et minute) à droite ; flèche.
class TransactionTile extends StatelessWidget {
  const TransactionTile({super.key, required this.transaction, required this.onTap});

  final TransactionEntity transaction;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = transaction;
    final failed = t.status == TransactionStatus.failed;
    final local = t.createdAt.toLocal();

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.md,
          vertical: SignmeSpacing.md,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _MethodIcon(transaction: t),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.account,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    t.motif,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
                  ),
                  const SizedBox(height: SignmeSpacing.xs),
                  TransactionStatusChip(status: t.status),
                ],
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '- ${FinanceFormatters.fcfa(t.montantTotal)}',
                  style: SignmeTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: failed ? SignmeColors.mediumGray : SignmeColors.black,
                    decoration: failed ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('dd/MM/yyyy', 'fr_FR').format(local),
                  style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.textSecondary),
                ),
                Text(
                  DateFormat('HH:mm', 'fr_FR').format(local),
                  style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(width: SignmeSpacing.xs),
            const Icon(Icons.chevron_right_rounded, color: SignmeColors.black),
          ],
        ),
      ),
    );
  }
}

/// Pastille du moyen de paiement : couleur de l'opérateur Mobile Money,
/// carte bancaire ou espèces.
class _MethodIcon extends StatelessWidget {
  const _MethodIcon({required this.transaction});

  final TransactionEntity transaction;

  @override
  Widget build(BuildContext context) {
    final operatorColor = paymentOperatorColor(
      transaction.paymentLabel == 'Orange Money'
          ? 'ORANGE MONEY'
          : transaction.paymentLabel == 'MTN Mobile Money'
              ? 'MTN MOBILE MONEY'
              : null,
    );
    final (icon, color) = switch (transaction.paymentMethod) {
      'card' => (Icons.credit_card_rounded, SignmeColors.primaryLight),
      'cash' => (Icons.payments_rounded, SignmeColors.success),
      _ => (Icons.smartphone_rounded, operatorColor ?? SignmeColors.primaryLight),
    };

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }
}
