import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/index.dart';

/// Bottom sheet d'ajout rapide pour une entrée de liste gérée (Groupe,
/// Quartier, Ville) — réutilisé par le formulaire membre et l'écran Profil.
/// Pour une Ville, [showDiasporaToggle] affiche le choix Au Cameroun / Diaspora.
/// Retourne l'élément créé (pour auto-sélection par l'appelant) ou `null`
/// si l'utilisateur a annulé.
Future<T?> showAddLookupBottomSheet<T>({
  required BuildContext context,
  required String title,
  required String hint,
  bool showDiasporaToggle = false,
  required Future<T> Function(String nom, bool estDiaspora) onSubmit,
}) {
  final controller = TextEditingController();
  bool estDiaspora = false;
  bool isSubmitting = false;
  String? error;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return StatefulBuilder(
        builder: (sheetContext, setState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                SignmeSpacing.lg,
                SignmeSpacing.lg,
                SignmeSpacing.lg,
                // La navbar flottante de MainShell se superpose aux bottom
                // sheets modaux (Stack au-dessus du contenu de route) — ce
                // padding évite que le bouton "Ajouter" soit masqué.
                SignmeSpacing.navbarClearance,
              ),
              decoration: const BoxDecoration(
                color: SignmeColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(SignmeSpacing.radiusXl),
                ),
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
                  Text(
                    title,
                    style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: SignmeSpacing.lg),
                  SignmeTextInput(
                    label: 'Nom',
                    hint: hint,
                    controller: controller,
                    enabled: !isSubmitting,
                    errorText: error,
                  ),
                  if (showDiasporaToggle) ...[
                    const SizedBox(height: SignmeSpacing.lg),
                    Text(
                      'Caractéristique',
                      style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: SignmeSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: _ChoiceChip(
                            label: 'Au Cameroun',
                            selected: !estDiaspora,
                            onTap: isSubmitting ? null : () => setState(() => estDiaspora = false),
                          ),
                        ),
                        const SizedBox(width: SignmeSpacing.sm),
                        Expanded(
                          child: _ChoiceChip(
                            label: 'Hors Cameroun (Diaspora)',
                            selected: estDiaspora,
                            onTap: isSubmitting ? null : () => setState(() => estDiaspora = true),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: SignmeSpacing.xl),
                  SignmePrimaryButton(
                    label: 'Ajouter',
                    isLoading: isSubmitting,
                    onPressed: isSubmitting
                        ? null
                        : () async {
                            final nom = controller.text.trim();
                            if (nom.isEmpty) {
                              setState(() => error = 'Ce champ est requis');
                              return;
                            }
                            setState(() {
                              isSubmitting = true;
                              error = null;
                            });
                            try {
                              final created = await onSubmit(nom, estDiaspora);
                              if (sheetContext.mounted) Navigator.pop(sheetContext, created);
                            } catch (e) {
                              setState(() {
                                isSubmitting = false;
                                error = 'Impossible d\'ajouter : $e';
                              });
                            }
                          },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? SignmeColors.primaryLight : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(
            color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: SignmeTypography.labelSmall.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : SignmeColors.black,
          ),
        ),
      ),
    );
  }
}
