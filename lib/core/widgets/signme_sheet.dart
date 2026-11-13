import 'package:flutter/material.dart';

import '../design_system/index.dart';

/// Feuille modale unique de l'app : poignée, titre optionnel, contenu défilant
/// qui remonte au-dessus du clavier, zone de sécurité respectée.
///
/// [isDismissible] à faux pour un formulaire qu'on ne doit pas fermer par
/// mégarde (toucher à l'extérieur ou glisser vers le bas).
Future<T?> showSignmeSheet<T>(
  BuildContext context, {
  String? title,
  String? subtitle,
  bool isDismissible = true,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
      child: Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.9),
        decoration: const BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXl)),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            MediaQuery.of(sheetContext).padding.bottom + SignmeSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: SignmeSpacing.lg),
                  decoration: BoxDecoration(
                    color: SignmeColors.lightGrayBorder,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                  ),
                ),
              ),
              if (title != null) ...[
                Text(title, style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle, style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray)),
                ],
                const SizedBox(height: SignmeSpacing.lg),
              ],
              builder(sheetContext),
            ],
          ),
        ),
      ),
    ),
  );
}
