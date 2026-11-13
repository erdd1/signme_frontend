import 'package:flutter/material.dart';
import '../../../../core/constants/app_assets.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/signme_card.dart';
import '../../domain/entities/church_about_info_entity.dart';
import '../../domain/entities/church_summary_entity.dart';

/// Card bleu principal — informations permanentes de l'église (logo commun
/// EEC, nom, localisation, horaires, district, activités majeures
/// récurrentes). N'est JAMAIS considéré comme un article.
class AboutHeaderCard extends StatelessWidget {
  const AboutHeaderCard({super.key, required this.church, required this.info, this.onEdit});

  final ChurchSummaryEntity church;
  final ChurchAboutInfoEntity info;

  /// Callback affichant l'icône crayon (pasteur/secrétaire uniquement) pour
  /// éditer district/horaires/activités majeures. `null` = icône masquée.
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return SignmeHeroCard(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset(SignmeAssets.eeclogo, fit: BoxFit.cover),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      church.nom,
                      style: SignmeTypography.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (info.district != null && info.district!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        info.district!,
                        style: SignmeTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                  tooltip: 'Modifier les infos',
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.lg),
          Wrap(
            spacing: SignmeSpacing.lg,
            runSpacing: SignmeSpacing.sm,
            children: [
              _InfoChip(icon: Icons.location_on_rounded, label: church.ville),
              if (church.adresse != null && church.adresse!.isNotEmpty)
                _InfoChip(icon: Icons.map_rounded, label: church.adresse!),
              if (info.horairesCulte != null && info.horairesCulte!.isNotEmpty)
                _InfoChip(
                  icon: Icons.access_time_rounded,
                  label: 'Culte du dimanche : ${info.horairesCulte}',
                ),
            ],
          ),
          if (info.activitesMajeures.isNotEmpty) ...[
            const SizedBox(height: SignmeSpacing.lg),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SignmeSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activités majeures',
                    style: SignmeTypography.labelSmall.copyWith(
                      color: Colors.white.withOpacity(0.85),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: SignmeSpacing.xs),
                  for (final activite in info.activitesMajeures)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•  ',
                            style: SignmeTypography.bodySmall.copyWith(color: Colors.white),
                          ),
                          Expanded(
                            child: Text(
                              activite,
                              // Pas de maxLines/ellipsis : chaque activité doit
                              // rester entièrement visible, quitte à agrandir
                              // le card (sa longueur est déjà bornée côté
                              // saisie — voir EditChurchInfoScreen).
                              style: SignmeTypography.bodySmall.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: Colors.white.withOpacity(0.85)),
        const SizedBox(width: 4),
        Text(
          label,
          style: SignmeTypography.bodySmall.copyWith(color: Colors.white),
        ),
      ],
    );
  }
}
