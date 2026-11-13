import 'package:flutter/material.dart';
import '../design_system/index.dart';
import 'app_button.dart';
import 'app_snackbar.dart';
import '../network/dio_exception_mapper.dart';
import 'signme_dialogs.dart';

/// SIGNME DROPDOWN - Standard Production Component
/// Champ de sélection ouvrant un bottom sheet compact (liste redimensionnable,
/// jamais plein écran) au lieu du menu natif Flutter — plus lisible sur
/// mobile pour les listes gérées (Quartier, Ville, Groupe, Région...).
/// Supporte optionnellement l'ajout [onAddNew] et la suppression [onDelete]
/// d'entrées (pasteur/secrétaire), réutilisé pour Sexe, Région, Quartier,
/// Ville, et les filtres du tableau de bord "Gérer utilisateurs".
class SignmeDropdown<T> extends StatelessWidget {
  const SignmeDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.hint = 'Sélectionner',
    this.validator,
    this.enabled = true,
    this.onAddNew,
    this.addNewLabel = 'Ajouter',
    this.onDelete,
    this.deleteConfirmMessage,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String hint;
  final FormFieldValidator<T>? validator;
  final bool enabled;

  /// Ouvre le flux d'ajout rapide ; retourne le nouvel élément créé
  /// (auto-sélectionné) ou `null` si annulé. `null` = capacité désactivée.
  final Future<T?> Function()? onAddNew;
  final String addNewLabel;

  /// Permet de supprimer une entrée depuis la liste. `null` = désactivé.
  final Future<void> Function(T item)? onDelete;
  final String Function(T item)? deleteConfirmMessage;

  @override
  Widget build(BuildContext context) {
    final errorText = validator?.call(value);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: Text(
            label,
            style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          onTap: enabled ? () => _openPicker(context) : null,
          child: InputDecorator(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: SignmeTypography.placeholder,
              errorText: errorText,
              suffixIcon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: SignmeColors.primaryLight,
              ),
              filled: true,
              fillColor: SignmeColors.accentSky.withOpacity(0.25),
              contentPadding: SignmeSpacing.inputPadding,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                borderSide: BorderSide.none,
              ),
            ),
            child: Text(
              value != null ? itemLabel(value as T) : hint,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: value != null ? SignmeTypography.bodyMedium : SignmeTypography.placeholder,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final selected = await showSignmePickerSheet<T>(
      context: context,
      title: label,
      items: items,
      itemLabel: itemLabel,
      selected: value,
      onAddNew: onAddNew,
      addNewLabel: addNewLabel,
      onDelete: onDelete,
      deleteConfirmMessage: deleteConfirmMessage,
    );
    if (selected != null) {
      onChanged?.call(selected);
    }
  }
}

/// Ouvre le bottom sheet de sélection utilisé par [SignmeDropdown] — exposé
/// séparément pour les écrans qui déclenchent la sélection directement
/// (ex. Profil) sans passer par le champ affiché du dropdown.
Future<T?> showSignmePickerSheet<T>({
  required BuildContext context,
  required String title,
  required List<T> items,
  required String Function(T item) itemLabel,
  T? selected,
  Future<T?> Function()? onAddNew,
  String addNewLabel = 'Ajouter',
  Future<void> Function(T item)? onDelete,
  String Function(T item)? deleteConfirmMessage,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _PickerSheet<T>(
      title: title,
      items: items,
      itemLabel: itemLabel,
      selected: selected,
      onAddNew: onAddNew,
      addNewLabel: addNewLabel,
      onDelete: onDelete,
      deleteConfirmMessage: deleteConfirmMessage,
    ),
  );
}

class _PickerSheet<T> extends StatefulWidget {
  const _PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    required this.selected,
    this.onAddNew,
    required this.addNewLabel,
    this.onDelete,
    this.deleteConfirmMessage,
  });

  final String title;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final Future<T?> Function()? onAddNew;
  final String addNewLabel;
  final Future<void> Function(T item)? onDelete;
  final String Function(T item)? deleteConfirmMessage;

  @override
  State<_PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<_PickerSheet<T>> {
  late List<T> _items;
  bool _isAdding = false;
  T? _deletingItem;

  @override
  void initState() {
    super.initState();
    _items = [...widget.items];
  }

  Future<void> _handleAddNew() async {
    if (widget.onAddNew == null || _isAdding) return;
    setState(() => _isAdding = true);
    try {
      final created = await widget.onAddNew!();
      if (!mounted) return;
      if (created != null) {
        Navigator.pop(context, created);
      } else {
        setState(() => _isAdding = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _handleDelete(T item) async {
    final confirm = await signmeConfirm(
      context,
      title: 'Supprimer ?',
      message: widget.deleteConfirmMessage?.call(item) ??
              'Voulez-vous vraiment supprimer "${widget.itemLabel(item)}" ?',
      confirmLabel: 'Supprimer',
      isDangerous: true,
    );
    if (confirm != true || !mounted) return;

    setState(() => _deletingItem = item);
    try {
      await widget.onDelete!(item);
      if (!mounted) return;
      setState(() {
        _items.remove(item);
        _deletingItem = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _deletingItem = null);
      AppSnackbar.error(context, 'Suppression impossible : ${messageFromError(e)}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXl)),
          ),
          child: Column(
            children: [
              const SizedBox(height: SignmeSpacing.sm),
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: SignmeSpacing.md),
                decoration: BoxDecoration(
                  color: SignmeColors.lightGrayBorder,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg),
                child: Text(
                  widget.title,
                  style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: SignmeSpacing.sm),
              const Divider(height: 1, color: SignmeColors.lightGrayBorder),
              Expanded(
                child: _items.isEmpty
                    ? Center(
                        child: Text(
                          'Aucun élément disponible.',
                          style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.sm),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          indent: SignmeSpacing.lg,
                          endIndent: SignmeSpacing.lg,
                          color: SignmeColors.lightGrayBorder,
                        ),
                        itemBuilder: (context, i) {
                          final item = _items[i];
                          final isSelected = item == widget.selected;
                          return ListTile(
                            onTap: () => Navigator.pop(context, item),
                            title: Text(
                              widget.itemLabel(item),
                              style: SignmeTypography.bodyMedium.copyWith(
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? SignmeColors.primaryLight : SignmeColors.black,
                              ),
                            ),
                            leading: isSelected
                                ? const Icon(Icons.check_circle_rounded, color: SignmeColors.primaryLight)
                                : const Icon(Icons.circle_outlined, color: SignmeColors.lightGrayBorder),
                            trailing: widget.onDelete == null
                                ? null
                                : (_deletingItem == item
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: SignmeColors.error),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.delete_outline_rounded, color: SignmeColors.error),
                                        onPressed: () => _handleDelete(item),
                                      )),
                          );
                        },
                      ),
              ),
              if (widget.onAddNew != null) ...[
                const Divider(height: 1, color: SignmeColors.lightGrayBorder),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    SignmeSpacing.lg,
                    SignmeSpacing.md,
                    SignmeSpacing.lg,
                    // Clearance navbar flottante (voir SignmeSpacing.navbarClearance).
                    SignmeSpacing.navbarClearance,
                  ),
                  child: SignmeSecondaryButton(
                    label: widget.addNewLabel,
                    icon: Icons.add_circle_outline_rounded,
                    isLoading: _isAdding,
                    onPressed: _handleAddNew,
                  ),
                ),
              ] else
                const SizedBox(height: SignmeSpacing.navbarClearance),
            ],
          ),
        );
      },
    );
  }
}
