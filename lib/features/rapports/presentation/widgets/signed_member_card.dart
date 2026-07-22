import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/rapport_membre_entity.dart';

/// Widget pour afficher une carte de membre signé avec ses détails de signature
class SignedMemberCard extends StatelessWidget {
  final RapportMembreEntity member;

  const SignedMemberCard({required this.member, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          CircleAvatar(
            radius: 24,
            backgroundColor: SignmeColors.primaryLight.withOpacity(0.1),
            backgroundImage: member.photoUrl != null
                ? NetworkImage(member.photoUrl!)
                : null,
            child: member.photoUrl == null
                ? Text(
                    member.nom.isNotEmpty ? member.nom[0].toUpperCase() : '?',
                    style: SignmeTypography.titleMedium,
                  )
                : null,
          ),

          const SizedBox(width: SignmeSpacing.md),

          // ── Infos ──────────────────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.nom,
                  style: SignmeTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  member.email,
                  style: SignmeTypography.bodySmall.copyWith(
                    color: SignmeColors.textSecondary,
                  ),
                   maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (member.signature != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 14,
                        color: SignmeColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${member.signature!.amount.toStringAsFixed(0)} Fr',
                        style: SignmeTypography.bodySmall.copyWith(
                          color: SignmeColors.success,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: SignmeSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: member.signature!.signatureType == 'presentiel'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          member.signature!.signatureType == 'presentiel'
                              ? 'Présent'
                              : 'Distance',
                          style: SignmeTypography.bodySmall.copyWith(
                            color: member.signature!.signatureType ==
                                    'presentiel'
                                ? Colors.blue
                                : Colors.purple,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // ── Icône ──────────────────────────────────────────────────
          Icon(
            Icons.check_circle_rounded,
            color: SignmeColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}
