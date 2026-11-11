import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/widgets/index.dart';
import '../providers/transactions_provider.dart';
import 'transaction_detail_sheet.dart';
import 'transaction_tile.dart';

/// « Mes transactions » : les dernières opérations financières de
/// l'utilisateur, avec accès à l'historique complet (« Voir tous »).
class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key, required this.onSeeAll});

  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recent = ref.watch(recentTransactionsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Mes transactions',
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            InkWell(
              onTap: onSeeAll,
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
              child: Padding(
                padding: const EdgeInsets.all(SignmeSpacing.xs),
                child: Row(
                  children: [
                    Text(
                      'Voir tous',
                      style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: SignmeColors.primaryLight, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: SignmeSpacing.md),
        recent.when(
          loading: () => const SignmeSkeletonList(itemCount: 3, itemHeight: 72),
          error: (e, _) => _Message(
            icon: Icons.wifi_off_rounded,
            text: messageFromError(e),
            action: SignmeTextButton(
              label: 'Réessayer',
              icon: Icons.refresh_rounded,
              onPressed: () => ref.invalidate(recentTransactionsProvider),
            ),
          ),
          data: (items) => items.isEmpty
              ? const _Message(
                  icon: Icons.receipt_long_rounded,
                  text: 'Vos dons, contributions et signatures apparaîtront ici.',
                )
              : Container(
                  decoration: BoxDecoration(
                    color: SignmeColors.white,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
                    border: Border.all(color: SignmeColors.lightGrayBorder),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Column(
                    children: [
                      for (var i = 0; i < items.length; i++) ...[
                        if (i > 0) const Divider(height: 1, indent: SignmeSpacing.md, endIndent: SignmeSpacing.md),
                        TransactionTile(
                          transaction: items[i],
                          onTap: () => showTransactionDetailSheet(context, items[i]),
                        ),
                      ],
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.icon, required this.text, this.action});

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        children: [
          Icon(icon, color: SignmeColors.mediumGray, size: 32),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            text,
            textAlign: TextAlign.center,
            style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary),
          ),
          if (action != null) ...[const SizedBox(height: SignmeSpacing.sm), action!],
        ],
      ),
    );
  }
}
