import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// COMPACT DROPDOWN - Menu ancré sous le champ (coin bas-droit), jamais
/// plein écran.
///
/// Contrairement à [SignmeDropdown] (bottom sheet plein écran), ce composant
/// est prévu pour des listes de sélection ancrées : menu étroit (largeur
/// calculée sur le texte le plus long, plafonnée à la largeur du champ),
/// aligné à droite, stylé avec les tokens SignMe, défilant au-delà de
/// [maxVisibleItems]. Supporte optionnellement l'ajout [onAddNew] et la
/// suppression [onDelete] d'entrées, comme [SignmeDropdown].


/// ```
class SignmeCompactDropdown<T> extends StatefulWidget {
  const SignmeCompactDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.itemLabel,
    this.onChanged,
    this.hint = 'Sélectionner',
    this.enabled = true,
    this.maxVisibleItems = 7,
    this.onAddNew,
    this.addNewLabel = 'Ajouter',
    this.onDelete,
    this.deleteConfirmMessage,
    this.itemBuilder,
    this.itemHeight = 46,
    this.showLabel = true,
    this.itemBuilderLeadingWidth = 0,
  });

  final String label;
  final T? value;
  final List<T> items;
  final String Function(T item) itemLabel;
  final ValueChanged<T?>? onChanged;
  final String hint;
  final bool enabled;

  /// Nombre d'éléments visibles avant que le menu ne devienne scrollable.
  final int maxVisibleItems;

  /// Ouvre le flux d'ajout rapide ; retourne le nouvel élément créé
  /// (auto-sélectionné) ou `null` si annulé. `null` = capacité désactivée.
  final Future<T?> Function()? onAddNew;
  final String addNewLabel;

  /// Permet de supprimer une entrée depuis le menu. `null` = désactivé.
  final Future<void> Function(T item)? onDelete;
  final String Function(T item)? deleteConfirmMessage;

  /// Rendu personnalisé d'une ligne du menu (ex. icône + texte). Si non
  /// fourni, une simple ligne de texte (via [itemLabel]) est utilisée.
  final Widget Function(T item, bool selected)? itemBuilder;

  /// Hauteur de chaque ligne du menu (à ajuster si [itemBuilder] est plus
  /// grand qu'une simple ligne de texte).
  final double itemHeight;

  /// Masquer le libellé au-dessus du champ (utile quand le champ
  /// déclencheur porte déjà son propre contexte visuel).
  final bool showLabel;

  /// Largeur additionnelle à réserver dans le calcul automatique de la
  /// largeur du menu pour ce que [itemBuilder] ajoute avant le texte
  /// (ex. une icône dans un cercle + son espacement). Le calcul par défaut
  /// ne mesure que le texte de [itemLabel] ; sans ce paramètre, un
  /// [itemBuilder] avec une icône déborde (overflow) dans le menu.
  final double itemBuilderLeadingWidth;

  @override
  State<SignmeCompactDropdown<T>> createState() => _SignmeCompactDropdownState<T>();
}

class _SignmeCompactDropdownState<T> extends State<SignmeCompactDropdown<T>> {
  static const double _kMinMenuWidth = 140;

  final GlobalKey _triggerKey = GlobalKey();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  double _computeMenuWidth(double maxWidth, List<T> items) {
    double widest = 0;
    for (final item in items) {
      final painter = TextPainter(
        text: TextSpan(text: widget.itemLabel(item), style: SignmeTypography.bodyMedium),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
    }
    final withPadding = widest +
        (SignmeSpacing.md * 2) +
        widget.itemBuilderLeadingWidth +
        (widget.onDelete != null ? 36 : 4);
    return withPadding.clamp(_kMinMenuWidth, maxWidth);
  }

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      setState(() {});
      return;
    }

    final fieldBox = _triggerKey.currentContext!.findRenderObject() as RenderBox;
    final fieldWidth = fieldBox.size.width;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _CompactDropdownMenu<T>(
        layerLink: _layerLink,
        fieldWidth: fieldWidth,
        items: widget.items,
        itemLabel: widget.itemLabel,
        selected: widget.value,
        maxVisibleItems: widget.maxVisibleItems,
        itemBuilder: widget.itemBuilder,
        itemHeight: widget.itemHeight,
        onSelect: (item) {
          widget.onChanged?.call(item);
          _removeOverlay();
          setState(() {});
        },
        onDismiss: () {
          _removeOverlay();
          setState(() {});
        },
        computeWidth: _computeMenuWidth,
        onAddNew: widget.onAddNew,
        addNewLabel: widget.addNewLabel,
        onDelete: widget.onDelete,
        deleteConfirmMessage: widget.deleteConfirmMessage,
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.showLabel)
          Padding(
            padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
            child: Text(
              widget.label,
              style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        CompositedTransformTarget(
          link: _layerLink,
          child: InkWell(
            key: _triggerKey,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            onTap: widget.enabled ? _toggleMenu : null,
            child: Container(
              padding: SignmeSpacing.inputPadding,
              decoration: BoxDecoration(
                color: SignmeColors.accentSky.withOpacity(0.25),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: widget.value != null && widget.itemBuilder != null
                  ? Row(
                      children: [
                        Expanded(child: widget.itemBuilder!(widget.value as T, true)),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: SignmeColors.primaryLight),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.value != null ? widget.itemLabel(widget.value as T) : widget.hint,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: widget.value != null ? SignmeTypography.bodyMedium : SignmeTypography.placeholder,
                          ),
                        ),
                        const Icon(Icons.keyboard_arrow_down_rounded, color: SignmeColors.primaryLight),
                      ],
                    ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Contenu du menu ancré, extrait en widget à état propre pour gérer
/// localement l'ajout/suppression sans recréer l'[OverlayEntry] parent.
class _CompactDropdownMenu<T> extends StatefulWidget {
  const _CompactDropdownMenu({
    required this.layerLink,
    required this.fieldWidth,
    required this.items,
    required this.itemLabel,
    required this.selected,
    required this.maxVisibleItems,
    required this.onSelect,
    required this.onDismiss,
    required this.computeWidth,
    this.onAddNew,
    required this.addNewLabel,
    this.onDelete,
    this.deleteConfirmMessage,
    this.itemBuilder,
    this.itemHeight = 46,
  });

  final LayerLink layerLink;
  final double fieldWidth;
  final List<T> items;
  final String Function(T item) itemLabel;
  final T? selected;
  final int maxVisibleItems;
  final ValueChanged<T> onSelect;
  final VoidCallback onDismiss;
  final double Function(double maxWidth, List<T> items) computeWidth;
  final Future<T?> Function()? onAddNew;
  final String addNewLabel;
  final Future<void> Function(T item)? onDelete;
  final String Function(T item)? deleteConfirmMessage;
  final Widget Function(T item, bool selected)? itemBuilder;
  final double itemHeight;

  @override
  State<_CompactDropdownMenu<T>> createState() => _CompactDropdownMenuState<T>();
}

class _CompactDropdownMenuState<T> extends State<_CompactDropdownMenu<T>> {
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
        widget.onSelect(created);
      } else {
        setState(() => _isAdding = false);
      }
    } catch (_) {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  Future<void> _handleDelete(T item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Text('Supprimer ?', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
        content: Text(
          widget.deleteConfirmMessage?.call(item) ??
              'Voulez-vous vraiment supprimer "${widget.itemLabel(item)}" ?',
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Suppression impossible : $e'), backgroundColor: SignmeColors.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuWidth = widget.computeWidth(widget.fieldWidth, _items);

    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: widget.onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: widget.layerLink,
          targetAnchor: Alignment.bottomRight,
          followerAnchor: Alignment.topRight,
          offset: const Offset(0, 4),
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: menuWidth,
              decoration: BoxDecoration(
                color: SignmeColors.white,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                border: Border.all(color: SignmeColors.lightGrayBorder),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: _items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.all(SignmeSpacing.md),
                              child: Text(
                                'Aucun élément.',
                                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
                              ),
                            )
                          : ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: widget.itemHeight * widget.maxVisibleItems,
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    for (final item in _items)
                                      InkWell(
                                        onTap: () => widget.onSelect(item),
                                        child: Container(
                                          height: widget.itemHeight,
                                          width: double.infinity,
                                          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: widget.itemBuilder != null
                                                    ? widget.itemBuilder!(item, item == widget.selected)
                                                    : Text(
                                                        widget.itemLabel(item),
                                                        maxLines: 1,
                                                        overflow: TextOverflow.ellipsis,
                                                        style: SignmeTypography.bodyMedium.copyWith(
                                                          color: item == widget.selected
                                                              ? SignmeColors.primaryLight
                                                              : SignmeColors.black,
                                                          fontWeight: item == widget.selected
                                                              ? FontWeight.w700
                                                              : FontWeight.normal,
                                                        ),
                                                      ),
                                              ),
                                              if (widget.onDelete != null)
                                                _deletingItem == item
                                                    ? const SizedBox(
                                                        width: 16,
                                                        height: 16,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          color: SignmeColors.error,
                                                        ),
                                                      )
                                                    : InkWell(
                                                        onTap: () => _handleDelete(item),
                                                        child: const Padding(
                                                          padding: EdgeInsets.all(4),
                                                          child: Icon(
                                                            Icons.delete_outline_rounded,
                                                            size: 18,
                                                            color: SignmeColors.error,
                                                          ),
                                                        ),
                                                      ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                    ),
                    if (widget.onAddNew != null) ...[
                      const Divider(height: 1, color: SignmeColors.lightGrayBorder),
                      InkWell(
                        onTap: _handleAddNew,
                        child: Container(
                          height: widget.itemHeight,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md),
                          child: Row(
                            children: [
                              if (_isAdding)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: SignmeColors.primaryLight),
                                )
                              else
                                const Icon(Icons.add_circle_outline_rounded, size: 18, color: SignmeColors.primaryLight),
                              const SizedBox(width: SignmeSpacing.sm),
                              Text(
                                widget.addNewLabel,
                                style: SignmeTypography.bodyMedium.copyWith(
                                  color: SignmeColors.primaryLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
