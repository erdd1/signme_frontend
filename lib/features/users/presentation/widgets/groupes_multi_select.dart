import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/network/dio_exception_mapper.dart';

/// Sélection multiple de groupes avec, pour chaque groupe choisi, le poste du
/// chrétien : simple membre (par défaut), président et/ou trésorier. Un
/// chrétien peut cumuler président et trésorier, mais pas être « simple
/// membre » en plus : « Membre » n'est actif que si aucun poste n'est coché.
///
/// Ces postes sont ceux du GROUPE — sans rapport avec le rôle du chrétien
/// (le rôle « trésorier » de l'église reste inchangé).
///
/// [selected] : groupeId → postes cochés (vide = simple membre). Si
/// [onDelete] est fourni (pasteur/secrétaire), une icône de suppression (avec
/// confirmation) apparaît sur chaque groupe.
class GroupesMultiSelect extends StatelessWidget {
  const GroupesMultiSelect({
    super.key,
    required this.groupes,
    required this.selected,
    required this.onChanged,
    this.enabled = true,
    this.onAddPressed,
    this.onDelete,
  });

  final List<GroupeRef> groupes;
  final Map<int, Set<String>> selected;
  final bool enabled;
  final VoidCallback? onAddPressed;
  final Future<void> Function(GroupeRef groupe)? onDelete;
  final void Function(Map<int, Set<String>> selected) onChanged;

  void _toggleGroupe(GroupeRef groupe) {
    final next = {...selected};
    if (next.containsKey(groupe.id)) {
      next.remove(groupe.id);
    } else {
      next[groupe.id] = <String>{};
    }
    onChanged(next);
  }

  void _togglePoste(GroupeRef groupe, String poste) {
    final postes = {...?selected[groupe.id]};
    postes.contains(poste) ? postes.remove(poste) : postes.add(poste);
    onChanged({...selected, groupe.id: postes});
  }

  void _setSimpleMembre(GroupeRef groupe) => onChanged({...selected, groupe.id: <String>{}});

  @override
  Widget build(BuildContext context) {
    final choisis = groupes.where((g) => selected.containsKey(g.id)).toList();

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
              return _GroupeChip(
                groupe: groupe,
                isSelected: selected.containsKey(groupe.id),
                enabled: enabled,
                onTap: () => _toggleGroupe(groupe),
                onDelete: onDelete,
              );
            }).toList(),
          ),
        if (choisis.isNotEmpty) ...[
          const SizedBox(height: SignmeSpacing.lg),
          Text(
            'Poste dans le groupe',
            style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: SignmeSpacing.sm),
          for (final groupe in choisis) ...[
            _PosteCard(
              groupe: groupe,
              postes: selected[groupe.id] ?? const {},
              enabled: enabled,
              onSimpleMembre: () => _setSimpleMembre(groupe),
              onTogglePoste: (poste) => _togglePoste(groupe, poste),
            ),
            const SizedBox(height: SignmeSpacing.sm),
          ],
        ],
      ],
    );
  }
}

/// Choix du poste d'un chrétien dans un groupe : trois puces, « Membre »
/// exclusive des deux autres qui sont cumulables.
class _PosteCard extends StatelessWidget {
  const _PosteCard({
    required this.groupe,
    required this.postes,
    required this.enabled,
    required this.onSimpleMembre,
    required this.onTogglePoste,
  });

  final GroupeRef groupe;
  final Set<String> postes;
  final bool enabled;
  final VoidCallback onSimpleMembre;
  final void Function(String poste) onTogglePoste;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.md),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.groups_rounded, size: 18, color: SignmeColors.primaryLight),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: Text(
                  groupe.nom,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelMedium.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Wrap(
            spacing: SignmeSpacing.sm,
            runSpacing: SignmeSpacing.sm,
            children: [
              _PosteChip(
                label: 'Membre',
                icon: Icons.person_rounded,
                selected: postes.isEmpty,
                enabled: enabled,
                onTap: onSimpleMembre,
              ),
              _PosteChip(
                label: 'Président',
                icon: Icons.workspace_premium_rounded,
                selected: postes.contains(GroupePoste.president),
                enabled: enabled,
                onTap: () => onTogglePoste(GroupePoste.president),
              ),
              _PosteChip(
                label: 'Trésorier',
                icon: Icons.account_balance_wallet_rounded,
                selected: postes.contains(GroupePoste.tresorier),
                enabled: enabled,
                onTap: () => onTogglePoste(GroupePoste.tresorier),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PosteChip extends StatelessWidget {
  const _PosteChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: SignmeSpacing.animationFast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? SignmeColors.primaryLight.withValues(alpha: 0.08) : SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            border: Border.all(
              color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: selected ? SignmeColors.primaryLight : SignmeColors.mediumGray),
              const SizedBox(width: 6),
              Text(
                label,
                style: SignmeTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? SignmeColors.primaryLight : SignmeColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupeChip extends StatefulWidget {
  const _GroupeChip({
    required this.groupe,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
    this.onDelete,
  });

  final GroupeRef groupe;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;
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
        AppSnackbar.error(context, 'Suppression impossible : ${messageFromError(e)}');
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
