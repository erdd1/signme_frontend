import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/rapport_membre_entity.dart';

/// Widget pour afficher une carte de membre non-signé
class NotSignedMemberCard extends StatelessWidget {
  final RapportMembreEntity member;

  const NotSignedMemberCard({required this.member, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
      child: Row(
        children: [
          // ── Avatar ─────────────────────────────────────────────────
          CircleAvatar(
            radius: 24,
            backgroundColor: SignmeColors.error.withOpacity(0.1),
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
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: SignmeColors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    _roleLabel(member.role),
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.error,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Icône ──────────────────────────────────────────────────
          Icon(
            Icons.cancel_rounded,
            color: SignmeColors.error,
            size: 20,
          ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'paroissien':
        return 'Paroissien(ne)';
      case 'ancien':
        return 'Ancien(ne)';
      case 'secretaire':
        return 'Secrétaire';
      case 'tresorier':
        return 'Trésorier';
      case 'pasteur':
        return 'Pasteur';
      default:
        return role;
    }
  }
}
