import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// SIGNME ANCHORED ACTION MENU - Menu d'actions ancré au widget déclencheur.
///
/// Reprend le langage visuel de [SignmeCompactDropdown] (CompositedTransform,
/// conteneur blanc, ombre légère, jamais plein écran) mais pour une liste
/// d'actions (icône + libellé + callback) plutôt qu'une sélection de valeur.
/// S'ouvre automatiquement vers le haut si l'espace sous le déclencheur est
/// insuffisant (ex. FAB en bas d'écran, au-dessus de la navbar), vers le bas
/// sinon.
class SignmeAnchoredActionMenuItem {
  const SignmeAnchoredActionMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class SignmeAnchoredActionMenu extends StatefulWidget {
  const SignmeAnchoredActionMenu({
    super.key,
    required this.items,
    required this.builder,
    this.menuWidth = 220,
    this.itemHeight = 48,
  });

  /// Actions affichées dans le menu, dans l'ordre.
  final List<SignmeAnchoredActionMenuItem> items;

  /// Construit le widget déclencheur (ex. FloatingActionButton). Reçoit une
  /// callback [onTap] à assigner au `onPressed`/`onTap` du déclencheur.
  final Widget Function(BuildContext context, VoidCallback onTap) builder;

  final double menuWidth;
  final double itemHeight;

  @override
  State<SignmeAnchoredActionMenu> createState() => _SignmeAnchoredActionMenuState();
}

class _SignmeAnchoredActionMenuState extends State<SignmeAnchoredActionMenu> {
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

  void _toggleMenu() {
    if (_overlayEntry != null) {
      _removeOverlay();
      setState(() {});
      return;
    }

    final renderBox = context.findRenderObject() as RenderBox;
    final triggerSize = renderBox.size;
    final triggerTopLeft = renderBox.localToGlobal(Offset.zero);
    final screenHeight = MediaQuery.of(context).size.height;

    final menuHeight = widget.itemHeight * widget.items.length;
    final spaceBelow = screenHeight - (triggerTopLeft.dy + triggerSize.height);
    final openUpward = spaceBelow < menuHeight + SignmeSpacing.md;

    _overlayEntry = OverlayEntry(
      builder: (overlayContext) => _AnchoredActionMenuOverlay(
        layerLink: _layerLink,
        menuWidth: widget.menuWidth,
        itemHeight: widget.itemHeight,
        items: widget.items,
        openUpward: openUpward,
        onDismiss: () {
          _removeOverlay();
          setState(() {});
        },
      ),
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: widget.builder(context, _toggleMenu),
    );
  }
}

class _AnchoredActionMenuOverlay extends StatelessWidget {
  const _AnchoredActionMenuOverlay({
    required this.layerLink,
    required this.menuWidth,
    required this.itemHeight,
    required this.items,
    required this.openUpward,
    required this.onDismiss,
  });

  final LayerLink layerLink;
  final double menuWidth;
  final double itemHeight;
  final List<SignmeAnchoredActionMenuItem> items;
  final bool openUpward;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onDismiss,
          ),
        ),
        CompositedTransformFollower(
          link: layerLink,
          targetAnchor: openUpward ? Alignment.topRight : Alignment.bottomRight,
          followerAnchor: openUpward ? Alignment.bottomRight : Alignment.topRight,
          offset: Offset(0, openUpward ? -8 : 8),
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
                    for (var i = 0; i < items.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, color: SignmeColors.lightGrayBorder),
                      InkWell(
                        onTap: () {
                          onDismiss();
                          items[i].onTap();
                        },
                        child: Container(
                          height: itemHeight,
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md),
                          child: Row(
                            children: [
                              Icon(items[i].icon, size: 18, color: SignmeColors.primaryLight),
                              const SizedBox(width: SignmeSpacing.sm),
                              Expanded(
                                child: Text(
                                  items[i].label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: SignmeTypography.bodyMedium,
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