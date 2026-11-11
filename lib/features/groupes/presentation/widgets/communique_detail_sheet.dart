import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/groupe_entities.dart';
import '../providers/groupes_provider.dart';
import 'groupe_sheet.dart';

/// Action choisie dans le détail d'un communiqué.
enum CommuniqueAction { contribuer, modifier, retirer }

/// Détail d'un communiqué : message complet, avancement et — visible de tous
/// les membres — la liste de ceux qui ont contribué. Le président y trouve
/// aussi modifier / retirer.
Future<CommuniqueAction?> showCommuniqueDetailSheet(
  BuildContext context, {
  required String groupeUuid,
  required CommuniqueEntity communique,
  required bool peutGerer,
}) {
  return showGroupeSheet<CommuniqueAction>(
    context,
    title: communique.titre,
    builder: (_) => _Detail(groupeUuid: groupeUuid, communique: communique, peutGerer: peutGerer),
  );
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.groupeUuid, required this.communique, required this.peutGerer});

  final String groupeUuid;
  final CommuniqueEntity communique;
  final bool peutGerer;

  static final _date = DateFormat('dd/MM/yyyy');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributeurs = ref.watch(contributeursProvider((groupeUuid, communique.uuid)));
    final progression = communique.progression;
    final fin = DateTime.tryParse(communique.dateFin ?? '');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(communique.message, style: SignmeTypography.bodyMedium.copyWith(height: 1.5)),
        if (fin != null) ...[
          const SizedBox(height: SignmeSpacing.sm),
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 16, color: SignmeColors.mediumGray),
              const SizedBox(width: 6),
              Text('Jusqu\'au ${_date.format(fin)}', style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray)),
            ],
          ),
        ],
        const SizedBox(height: SignmeSpacing.lg),
        Container(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          decoration: BoxDecoration(
            color: SignmeColors.accentSky,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.primaryLight.withValues(alpha: 0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FinanceFormatters.fcfa(communique.montantCollecte),
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w900, color: SignmeColors.primaryLight),
              ),
              Text(
                communique.objectifMontant != null
                    ? 'collectés sur ${FinanceFormatters.fcfa(communique.objectifMontant!)}'
                    : 'collectés',
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.darkGray),
              ),
              if (progression != null) ...[
                const SizedBox(height: SignmeSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                  child: LinearProgressIndicator(
                    value: progression,
                    minHeight: 8,
                    backgroundColor: Colors.white,
                    color: SignmeColors.primaryLight,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        Text('Ils ont contribué', style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 15)),
        const SizedBox(height: SignmeSpacing.sm),
        contributeurs.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(SignmeSpacing.lg),
            child: Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
          ),
          error: (_, __) => Text('Liste indisponible pour le moment.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
          data: (liste) => liste.isEmpty
              ? Text('Aucune contribution pour le moment.', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray))
              : Column(
                  children: [
                    for (final c in liste)
                      Padding(
                        padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                        child: Row(
                          children: [
                            ProfilePhotoAvatar(photoUrl: c.photoUrl, displayName: c.nom, radius: 18, showViewerOnTap: false),
                            const SizedBox(width: SignmeSpacing.md),
                            Expanded(
                              child: Text(c.nom, maxLines: 1, overflow: TextOverflow.ellipsis, style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w700)),
                            ),
                            Text(FinanceFormatters.fcfaShort(c.montant), style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w800, color: SignmeColors.primaryLight)),
                          ],
                        ),
                      ),
                  ],
                ),
        ),
        const SizedBox(height: SignmeSpacing.lg),
        SignmePrimaryButton(
          label: 'Contribuer',
          icon: Icons.volunteer_activism_rounded,
          onPressed: () => Navigator.pop(context, CommuniqueAction.contribuer),
        ),
        if (peutGerer) ...[
          const SizedBox(height: SignmeSpacing.sm),
          Row(
            children: [
              Expanded(
                child: SignmeSecondaryButton(label: 'Modifier', icon: Icons.edit_rounded, onPressed: () => Navigator.pop(context, CommuniqueAction.modifier)),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: SignmeSecondaryButton(label: 'Retirer', icon: Icons.archive_outlined, onPressed: () => Navigator.pop(context, CommuniqueAction.retirer)),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
