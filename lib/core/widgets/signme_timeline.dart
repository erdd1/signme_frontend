import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../design_system/index.dart';
import 'signme_payment_method_info.dart';

/// Construit les slivers d'une timeline d'historique groupée par mois
/// (ligne continue + repères), façon "relevé de compte moderne" — à insérer
/// directement dans les `slivers:` d'un [CustomScrollView] parent, plutôt que
/// d'imbriquer une deuxième liste défilante indépendante (l'écran n'a alors
/// plus qu'un seul scroll, comme le module Mes dépenses). Réutilisé par
/// l'historique personnel et l'historique des signatures effectuées (même
/// mise en forme, contenu de carte différent via [SignmeTimelineCard]).
List<Widget> buildSignmeTimelineSlivers({
  required List<SignmeTimelineSection> sections,
  EdgeInsets padding = const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
}) {
  // Aplati en une seule liste de "lignes" (en-têtes de mois + cartes) pour
  // que la ligne verticale du rail coure sans interruption d'une section à
  // l'autre, comme sur la maquette.
  final rows = <_TimelineRow>[
    for (final section in sections) ...[
      _TimelineRow.header(section.label),
      for (final item in section.items) _TimelineRow.item(item),
    ],
  ];

  return [
    SliverPadding(
      padding: padding,
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final row = rows[index];
            return IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TimelineRail(
                    isFirst: index == 0,
                    isLast: index == rows.length - 1,
                    isHeader: row.isHeader,
                  ),
                  const SizedBox(width: SignmeSpacing.md),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
                      child: row.isHeader
                          ? _TimelineMonthPill(label: row.label!)
                          : row.child!,
                    ),
                  ),
                ],
              ),
            );
          },
          childCount: rows.length,
        ),
      ),
    ),
  ];
}

class SignmeTimelineSection {
  const SignmeTimelineSection({required this.label, required this.items});
  final String label;
  final List<Widget> items;
}

class _TimelineRow {
  const _TimelineRow._({this.label, this.child}) : isHeader = label != null;
  factory _TimelineRow.header(String label) => _TimelineRow._(label: label);
  factory _TimelineRow.item(Widget child) => _TimelineRow._(child: child);

  final bool isHeader;
  final String? label;
  final Widget? child;
}

const double _kRailWidth = 20;

/// Rail gauche de la timeline : segment de ligne au-dessus + repère + segment
/// en dessous, dimensionné par [IntrinsicHeight] pour toujours épouser la
/// hauteur de la ligne (en-tête ou carte) qu'il accompagne.
class _TimelineRail extends StatelessWidget {
  const _TimelineRail({
    required this.isFirst,
    required this.isLast,
    required this.isHeader,
  });

  final bool isFirst;
  final bool isLast;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _kRailWidth,
      child: Column(
        children: [
          Expanded(child: isFirst ? const SizedBox() : _lineSegment()),
          _marker(),
          Expanded(child: isLast ? const SizedBox() : _lineSegment()),
        ],
      ),
    );
  }

  Widget _lineSegment() {
    return Center(
      child: Container(
        width: 2,
        color: SignmeColors.black.withOpacity(0.65),
      ),
    );
  }

  Widget _marker() {
    if (isHeader) {
      return Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: SignmeColors.white,
          shape: BoxShape.circle,
          border: Border.all(color: SignmeColors.black, width: 2.5),
        ),
      );
    }
    return Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        color: SignmeColors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TimelineMonthPill extends StatelessWidget {
  const _TimelineMonthPill({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: SignmeColors.accentSky,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
        ),
        child: Text(
          label,
          style: SignmeTypography.labelMedium.copyWith(
            color: SignmeColors.primaryLight,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

/// Carte de contenu d'une entrée de timeline — sans icône de tête de ligne
/// ni chevron de fin (le repère du rail suffit à situer l'entrée), texte
/// noir sous le titre (pas de bleu, pour rester doux visuellement).
class SignmeTimelineCard extends StatelessWidget {
  const SignmeTimelineCard({
    super.key,
    required this.heading,
    required this.subtitle,
    required this.timestamp,
    required this.statusLabel,
    required this.statusColor,
    this.statusIcon = Icons.check_circle_rounded,
    required this.amountLabel,
    this.paymentMethodColor,
    this.paymentMethodLabel,
    this.paymentPhoneNumber,
    this.onTap,
  });

  /// Première ligne, en gras (ex. date courte ou nom).
  final String heading;

  /// Deuxième ligne, en noir (ex. type de signature ou église).
  final String subtitle;

  /// Troisième ligne, grise et petite (horodatage complet).
  final String timestamp;

  final String statusLabel;
  final Color statusColor;

  /// Icône du badge de statut — le check par défaut ne convient qu'à un
  /// statut "payé" ; un appelant affichant aussi pending/failed doit fournir
  /// l'icône correspondante (ex. `Icons.schedule_rounded` / `Icons.cancel_rounded`).
  final IconData statusIcon;
  final String amountLabel;

  /// Pastille de couleur de l'opérateur mobile money (orange/jaune, même
  /// palette que le sélecteur du formulaire de signature) — `null` si le
  /// paiement n'est pas passé par mobile money (présentiel, espèces...).
  final Color? paymentMethodColor;

  /// Libellé de l'opérateur ("Orange Money" / "MTN Money") — affiché avec la
  /// pastille de couleur, uniquement si [paymentMethodColor] est non-null.
  final String? paymentMethodLabel;

  /// Numéro ayant servi au paiement mobile money.
  final String? paymentPhoneNumber;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Container(
        padding: const EdgeInsets.all(SignmeSpacing.md),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.black.withOpacity(0.4)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    heading,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.labelLarge.copyWith(
                      color: SignmeColors.black,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (paymentMethodColor != null) ...[
                    const SizedBox(height: 3),
                    SignmePaymentMethodInfo(
                      color: paymentMethodColor!,
                      label: paymentMethodLabel,
                      phoneNumber: paymentPhoneNumber,
                    ),
                  ],
                  const SizedBox(height: 2),
                  Text(
                    timestamp,
                    style: SignmeTypography.labelSmall.copyWith(
                      color: SignmeColors.mediumGray,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 3),
                      Text(
                        statusLabel,
                        style: SignmeTypography.labelSmall.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  amountLabel,
                  style: SignmeTypography.labelLarge.copyWith(
                    color: SignmeColors.black,
                    fontWeight: FontWeight.w800,
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

/// "2026-09" -> "Septembre 2026"
String formatTimelineMonthLabel(String monthKey) {
  final parsed = DateTime.tryParse('$monthKey-01');
  if (parsed == null) return monthKey;
  final label = DateFormat.yMMMM('fr_FR').format(parsed);
  return label[0].toUpperCase() + label.substring(1);
}

/// Regroupe une liste déjà triée par date décroissante en sections par mois,
/// sans re-trier (préserve l'ordre fourni par le provider).
List<SignmeTimelineSection> groupTimelineByMonth<T>({
  required List<T> items,
  required String Function(T item) monthKeyOf,
  required Widget Function(T item) cardBuilder,
}) {
  final sections = <SignmeTimelineSection>[];
  String? currentKey;
  List<Widget>? currentItems;

  for (final item in items) {
    final key = monthKeyOf(item);
    if (key != currentKey) {
      currentKey = key;
      currentItems = <Widget>[];
      sections.add(SignmeTimelineSection(
        label: formatTimelineMonthLabel(key),
        items: currentItems,
      ));
    }
    currentItems!.add(cardBuilder(item));
  }

  return sections;
}
