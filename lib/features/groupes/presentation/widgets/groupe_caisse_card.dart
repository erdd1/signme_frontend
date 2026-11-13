import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/signme_card.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/groupe_entities.dart';

/// Bande de solde du groupe, visible de tous ses membres : total en caisse en
/// grand, puis les trois sources séparées (en ligne, cash, retraits). Le
/// président et le trésorier y trouvent les actions de gestion de la caisse.
class GroupeCaisseCard extends StatelessWidget {
  const GroupeCaisseCard({
    super.key,
    required this.caisse,
    this.onEntreeCash,
    this.onRetrait,
  });

  final GroupeCaisse caisse;

  /// Non null = l'utilisateur est président ou trésorier du groupe.
  final VoidCallback? onEntreeCash;
  final VoidCallback? onRetrait;

  @override
  Widget build(BuildContext context) {
    final gerer = onEntreeCash != null || onRetrait != null;

    return SignmeHeroCard(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Caisse du groupe',
            style: SignmeTypography.bodySmall.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 2),
          SignmeHeroAmount(FinanceFormatters.fcfa(caisse.total)),
          const SizedBox(height: SignmeSpacing.md),
          Row(
            children: [
              Expanded(child: _Source(icon: Icons.phone_iphone_rounded, label: 'En ligne', value: caisse.soldeEnLigne)),
              Expanded(child: _Source(icon: Icons.payments_rounded, label: 'Cash', value: caisse.cash)),
              Expanded(child: _Source(icon: Icons.north_east_rounded, label: 'Retraits', value: caisse.retraits)),
            ],
          ),
          if (gerer) ...[
            const SizedBox(height: SignmeSpacing.lg),
            Row(
              children: [
                if (onEntreeCash != null)
                  Expanded(
                    child: _CaisseAction(icon: Icons.add_card_rounded, label: 'Entrée cash', onTap: onEntreeCash!),
                  ),
                if (onEntreeCash != null && onRetrait != null) const SizedBox(width: SignmeSpacing.md),
                if (onRetrait != null)
                  Expanded(
                    child: _CaisseAction(icon: Icons.call_made_rounded, label: 'Retirer', onTap: onRetrait!),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Source extends StatelessWidget {
  const _Source({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13, color: Colors.white.withValues(alpha: 0.75)),
            const SizedBox(width: 4),
            Text(label, style: SignmeTypography.labelSmall.copyWith(color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            FinanceFormatters.fcfaShort(value),
            style: SignmeTypography.labelLarge.copyWith(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _CaisseAction extends StatelessWidget {
  const _CaisseAction({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.16),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 6),
              Text(label, style: SignmeTypography.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
