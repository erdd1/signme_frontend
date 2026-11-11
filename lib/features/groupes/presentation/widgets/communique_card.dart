import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/groupe_entities.dart';

/// Carte d'un communiqué : titre, extrait, avancement de la collecte.
class CommuniqueCard extends StatelessWidget {
  const CommuniqueCard({super.key, required this.communique, required this.onTap, required this.onContribuer});

  final CommuniqueEntity communique;
  final VoidCallback onTap;
  final VoidCallback onContribuer;

  @override
  Widget build(BuildContext context) {
    final progression = communique.progression;

    return Semantics(
      button: true,
      label: 'Communiqué ${communique.titre}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: SignmeColors.accentSky,
                      borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                    ),
                    child: const Icon(Icons.campaign_rounded, color: SignmeColors.primaryLight, size: 20),
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: Text(
                      communique.titre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Text(
                communique.message,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.darkGray, height: 1.4),
              ),
              if (progression != null) ...[
                const SizedBox(height: SignmeSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                  child: LinearProgressIndicator(
                    value: progression,
                    minHeight: 8,
                    backgroundColor: SignmeColors.lightGrayBorder.withValues(alpha: 0.5),
                    color: SignmeColors.primaryLight,
                  ),
                ),
              ],
              const SizedBox(height: SignmeSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      progression != null
                          ? '${FinanceFormatters.fcfaShort(communique.montantCollecte)} / ${FinanceFormatters.fcfaShort(communique.objectifMontant!)}'
                          : '${FinanceFormatters.fcfaShort(communique.montantCollecte)} collectés',
                      style: SignmeTypography.labelSmall.copyWith(fontWeight: FontWeight.w700, color: SignmeColors.primaryLight),
                    ),
                  ),
                  Text(
                    '${communique.nombreContributions} contribution${communique.nombreContributions > 1 ? 's' : ''}',
                    style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.md),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onContribuer,
                  icon: const Icon(Icons.volunteer_activism_rounded, size: 18),
                  label: const Text('Contribuer'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: SignmeColors.primaryLight,
                    side: const BorderSide(color: SignmeColors.primaryLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
                    padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
