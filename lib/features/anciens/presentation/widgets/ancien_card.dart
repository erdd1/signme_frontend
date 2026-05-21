import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/entities/ancien_entity.dart';

class AncienCard extends StatelessWidget {
  const AncienCard({
    super.key,
    required this.ancien,
    this.onDesignate,
    this.onRevoke,
  });

  final AncienEntity ancien;
  final VoidCallback? onDesignate;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ancien.isDesigned
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.border,
          width: ancien.isDesigned ? 1.5 : 0.8,
        ),
        boxShadow: [
          if (ancien.isDesigned)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // ── Header: Avatar + Nom + Status
            Row(
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: ancien.photoUrl.isNotEmpty
                      ? ClipOval(
                          child: CachedNetworkImage(
                            imageUrl: ancien.photoUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => const Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.person_rounded,
                              size: 24,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        )
                      : const Icon(
                          Icons.person_rounded,
                          size: 24,
                          color: AppColors.textSecondary,
                        ),
                ),
                const SizedBox(width: 12),

                // Nom + Email
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ancien.nom,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ancien.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Badge status
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: ancien.isDesigned
                        ? AppColors.success.withValues(alpha: 0.15)
                        : AppColors.warning.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: ancien.isDesigned
                          ? AppColors.success.withValues(alpha: 0.3)
                          : AppColors.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    ancien.isDesigned ? '✓ Désigné' : '○ Libre',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ancien.isDesigned
                          ? AppColors.success
                          : AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),

            // ── Infos de désignation (si désigné)
            if (ancien.isDesigned) ...[
              const SizedBox(height: 12),
              Divider(
                height: 1,
                color: AppColors.border.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),

              // Mois/Année
              Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    ancien.monthYearLabel,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Disponibilité
              Row(
                children: [
                  Icon(
                    ancien.joursTravail == null || ancien.joursTravail!.isEmpty
                        ? Icons.schedule_rounded
                        : Icons.access_time_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      ancien.availabilityLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Date fin de service
              if (ancien.dateFinService != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: AppColors.textHint,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Expire: ${ancien.dateFinService}',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ],
            ],

            // ── Actions
            const SizedBox(height: 12),
            Row(
              children: [
                if (!ancien.isDesigned)
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.person_add_rounded,
                      label: 'Désigner',
                      color: AppColors.primary,
                      onPressed: onDesignate,
                    ),
                  )
                else
                  Expanded(
                    child: _ActionButton(
                      icon: Icons.person_remove_rounded,
                      label: 'Révoquer',
                      color: AppColors.warning,
                      onPressed: onRevoke,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action Button Widget
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
