import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../domain/entities/transaction_entity.dart';

/// Pastille de statut : Succès, Échec ou En cours.
class TransactionStatusChip extends StatelessWidget {
  const TransactionStatusChip({super.key, required this.status});

  final TransactionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      TransactionStatus.completed => ('Succès', SignmeColors.success),
      TransactionStatus.failed => ('Échec', SignmeColors.error),
      TransactionStatus.pending => ('En cours', SignmeColors.primaryLight),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: SignmeTypography.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
      ),
    );
  }
}
