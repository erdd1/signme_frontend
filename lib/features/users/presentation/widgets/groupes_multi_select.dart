import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';

/// Sélection multiple de groupes (ministères) avec désignation d'un groupe
/// "principal" parmi ceux cochés. Appuyer sur un groupe le sélectionne/le
/// désélectionne ; appuyer sur l'étoile d'un groupe déjà sélectionné en fait
/// le groupe principal. Si [onDelete] est fourni (pasteur/secrétaire), une
/// icône de suppression (avec confirmation) apparaît sur chaque groupe.
class GroupesMultiSelect extends StatelessWidget {
  const GroupesMultiSelect({
    super.key,
    required this.groupes,
    required this.selectedIds,
    required this.principalId,
    required this.onChanged,
    this.enabled = true,
    this.onAddPressed,
    this.onDelete,
  });

  final List<GroupeRef> groupes;
  final Set<int> selectedIds;
  final int? principalId;
  final bool enabled;
  final VoidCallback? onAddPressed;
  final Future<void> Function(GroupeRef groupe)? onDelete;

  /// (ids sélectionnés, id du groupe principal)
  final void Function(Set<int> ids, int? principalId) onChanged;

  void _toggle(GroupeRef groupe) {
    final ids = {...selectedIds};
    int? newPrincipal = principalId;

    if (ids.contains(groupe.id)) {
      ids.remove(groupe.id);
      if (newPrincipal == groupe.id) {
        newPrincipal = ids.isNotEmpty ? ids.first : null;
      }
    } else {
      ids.add(groupe.id);
      newPrincipal ??= groupe.id;
    }

    onChanged(ids, newPrincipal);
  }

  void _setPrincipal(GroupeRef groupe) {
    if (!selectedIds.contains(groupe.id)) return;
    onChanged(selectedIds, groupe.id);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Groupes',
              style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
            ),
            if (onAddPressed != null)
              InkWell(
                onTap: enabled ? onAddPressed : null,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusSm),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline_rounded, size: 16, color: SignmeColors.primaryLight),
                      const SizedBox(width: 4),
                      Text(
                        'Ajouter',
                        style: SignmeTypography.labelSmall.copyWith(
                          color: SignmeColors.primaryLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: SignmeSpacing.sm),
        if (groupes.isEmpty)
          Text(
            'Aucun groupe disponible pour le moment.',
            style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
          )
        else
          Wrap(
            spacing: SignmeSpacing.sm,
            runSpacing: SignmeSpacing.sm,
            children: groupes.map((groupe) {
              final isSelected = selectedIds.contains(groupe.id);
              final isPrincipal = principalId == groupe.id;
              return _GroupeChip(
                groupe: groupe,
                isSelected: isSelected,
                isPrincipal: isPrincipal,
                enabled: enabled,
                onTap: () => _toggle(groupe),
                onTapStar: isSelected ? () => _setPrincipal(groupe) : null,
                onDelete: onDelete,
              );
            }).toList(),
          ),
        if (selectedIds.length > 1) ...[
          const SizedBox(height: SignmeSpacing.xs),
          Text(
            'Touchez l\'étoile pour définir le groupe principal.',
            style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.mediumGray),
          ),
        ],
      ],
    );
  }
}

class _GroupeChip extends StatefulWidget {
  const _GroupeChip({
    required this.groupe,
    required this.isSelected,
    required this.isPrincipal,
    required this.enabled,
    required this.onTap,
    required this.onTapStar,
    this.onDelete,
  });

  final GroupeRef groupe;
  final bool isSelected;
  final bool isPrincipal;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onTapStar;
  final Future<void> Function(GroupeRef groupe)? onDelete;

  @override
  State<_GroupeChip> createState() => _GroupeChipState();
}

class _GroupeChipState extends State<_GroupeChip> {
  bool _isDeleting = false;

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Text('Supprimer ?', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          'Supprimer le groupe "${widget.groupe.nom}" ? Les membres qui l\'utilisent seront simplement dissociés.',
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
        ),
        actionsPadding: const EdgeInsets.all(SignmeSpacing.lg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text('Annuler', style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.primaryLight)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text('Supprimer', style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;

    setState(() => _isDeleting = true);
    try {
      await widget.onDelete!(widget.groupe);
    } catch (e) {
      if (mounted) {
        setState(() => _isDeleting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Suppression impossible : $e'), backgroundColor: SignmeColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.enabled ? widget.onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.only(left: 14, right: 6, top: 6, bottom: 6),
        decoration: BoxDecoration(
          color: widget.isSelected ? SignmeColors.primaryLight : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(
            color: widget.isSelected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.groupe.nom,
              style: SignmeTypography.labelSmall.copyWith(
                fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
                color: widget.isSelected ? Colors.white : SignmeColors.black,
              ),
            ),
            if (widget.isSelected) ...[
              const SizedBox(width: 2),
              GestureDetector(
                onTap: widget.onTapStar,
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    widget.isPrincipal ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
            if (widget.onDelete != null) ...[
              const SizedBox(width: 2),
              if (_isDeleting)
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: widget.isSelected ? Colors.white : SignmeColors.error,
                    ),
                  ),
                )
              else
                GestureDetector(
                  onTap: _handleDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: widget.isSelected ? Colors.white70 : SignmeColors.mediumGray,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
