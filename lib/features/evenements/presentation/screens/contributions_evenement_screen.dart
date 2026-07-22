import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';
import '../../../finances/presentation/widgets/finance_formatters.dart';
import '../../domain/entities/contribution_entity.dart';
import '../providers/contributions_tresorerie_provider.dart';

/// Onglet drawer "Contributions événement" — Pasteur/Secrétaire/Trésorier.
///
/// Affiche l'ensemble des contributions de l'église : date, montant, frais,
/// montant payé, contributeur, événement lié, statut, référence CamPay, note,
/// numéro de paiement.
class ContributionsEvenementScreen extends ConsumerWidget {
  const ContributionsEvenementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contributionsAsync = ref.watch(contributionsTreasuryProvider);

    return Scaffold(
      backgroundColor: SignmeColors.background,
      body: RefreshIndicator(
        color: SignmeColors.primaryLight,
        onRefresh: () => ref.read(contributionsTreasuryProvider.notifier).refresh(),
        child: SignmeAsyncValue<List<ContributionEntity>>(
          value: contributionsAsync,
          onRetry: () => ref.read(contributionsTreasuryProvider.notifier).refresh(),
          emptyTitle: 'Aucune contribution',
          emptyMessage: 'Les contributions aux événements apparaîtront ici.',
          isEmpty: (list) => list.isEmpty,
          data: (contributions) => ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              SignmeSpacing.lg,
              SignmeSpacing.lg,
              SignmeSpacing.lg,
              120,
            ),
            itemCount: contributions.length,
            separatorBuilder: (_, __) => const SizedBox(height: SignmeSpacing.md),
            itemBuilder: (context, i) => _ContributionCard(contribution: contributions[i]),
          ),
        ),
      ),
    );
  }
}

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.contribution});
  final ContributionEntity contribution;

  Color get _statutColor => switch (contribution.statut) {
        'completed' => SignmeColors.success,
        'failed' => SignmeColors.error,
        _ => SignmeColors.warning,
      };

  String get _statutLabel => switch (contribution.statut) {
        'completed' => 'Payé',
        'failed' => 'Échoué',
        _ => 'En attente',
      };

  @override
  Widget build(BuildContext context) {
    // Un `Border` ne peut pas avoir un `borderRadius` si ses côtés n'ont pas
    // tous la même couleur (limitation Flutter) — le liseré gauche coloré
    // est donc peint comme un rectangle séparé plutôt que via BoxDecoration.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        boxShadow: [
          BoxShadow(color: SignmeColors.primaryDark.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Container(
          decoration: BoxDecoration(
            color: SignmeColors.white,
            border: Border.all(color: SignmeColors.lightGrayBorder),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(width: 4, color: _statutColor),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(SignmeSpacing.md),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SignmeLeadingIconAvatar(icon: Icons.event_rounded, color: _statutColor),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            contribution.evenementTitre ?? 'Événement',
                            style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: _statutColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                          ),
                          child: Text(
                            _statutLabel,
                            style: SignmeTypography.labelSmall.copyWith(
                              color: _statutColor,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            contribution.contributeurNom ?? 'Contributeur',
                            style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: SignmeSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: SignmeColors.accentSky,
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                          ),
                          child: Text(
                            contribution.contributeurGroupeNom ?? 'Sans groupe',
                            style: SignmeTypography.labelSmall.copyWith(
                              color: SignmeColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: SignmeSpacing.lg, color: SignmeColors.lightGrayBorder),
          Row(
            children: [
              Expanded(child: _infoColumn('Montant', FinanceFormatters.fcfaShort(contribution.montant))),
              Expanded(child: _infoColumn('Frais', FinanceFormatters.fcfaShort(contribution.frais))),
              Expanded(
                  child: _infoColumn('Payé', FinanceFormatters.fcfaShort(contribution.montantTotal),
                      highlight: true)),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(contribution.createdAt),
            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
          ),
          if (contribution.paymentReference != null) ...[
            const SizedBox(height: 2),
            Text(
              'Réf. paiement : ${contribution.paymentReference}',
              style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
            ),
          ],
          if (contribution.paymentNumber != null) ...[
            const SizedBox(height: 2),
            Text(
              '${contribution.paymentOperator ?? ''} · ${contribution.paymentNumber}',
              style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
            ),
          ],
          if (contribution.note != null && contribution.note!.isNotEmpty) ...[
            const SizedBox(height: SignmeSpacing.sm),
            Container(
              padding: const EdgeInsets.all(SignmeSpacing.sm),
              decoration: BoxDecoration(
                color: SignmeColors.accentSky.withOpacity(0.4),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
              ),
              child: Text(
                contribution.note!,
                style: SignmeTypography.bodySmall.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          ],
        ],
      );
  }

  Widget _infoColumn(String label, String value, {bool highlight = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.darkGray)),
        const SizedBox(height: 2),
        Text(
          value,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w800,
            color: highlight ? SignmeColors.primaryLight : SignmeColors.black,
          ),
        ),
      ],
    );
  }
}
