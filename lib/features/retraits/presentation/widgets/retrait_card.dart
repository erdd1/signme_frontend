import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/retrait_entity.dart';
import 'retrait_status_badge.dart';

class RetraitCard extends StatelessWidget {
  const RetraitCard({super.key, required this.retrait, this.onRecheck, this.isRechecking = false});

  final RetraitEntity retrait;

  /// `null` masque le bouton "Revérifier" (ex. déjà en cours de revérification globale).
  final VoidCallback? onRecheck;
  final bool isRechecking;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      padding: const EdgeInsets.all(SignmeSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FinanceFormatters.fcfa(retrait.montantDemande),
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w900),
              ),
              RetraitStatusBadge(retrait: retrait),
            ],
          ),
          const SizedBox(height: 6),
          if (retrait.beneficiaireOperator != null)
            Text(
              '${retrait.beneficiaireOperator} · ${retrait.beneficiaireNumeroMasque ?? ''}',
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray, fontSize: 12),
            ),
          if (retrait.frais > 0) ...[
            const SizedBox(height: 4),
            Text(
              'Frais : ${FinanceFormatters.fcfa(retrait.frais)} · Reçu : ${FinanceFormatters.fcfa(retrait.montantNet)}',
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.darkGray, fontSize: 12),
            ),
          ],
          if (retrait.isFailed && retrait.motifEchec != null) ...[
            const SizedBox(height: 4),
            Text(
              retrait.motifEchec!,
              style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error, fontSize: 12),
            ),
          ],
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(retrait.createdAt)),
                style: const TextStyle(fontSize: 12, color: SignmeColors.mediumGray),
              ),
              if (!retrait.isFinal && onRecheck != null)
                TextButton.icon(
                  onPressed: isRechecking ? null : onRecheck,
                  icon: isRechecking
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: SignmeColors.primaryLight),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16, color: SignmeColors.primaryLight),
                  label: const Text('Revérifier', style: TextStyle(color: SignmeColors.primaryLight, fontSize: 12)),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
