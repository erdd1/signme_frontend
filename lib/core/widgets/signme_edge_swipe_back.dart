import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Retour par glissement depuis le bord gauche, sur iPhone uniquement.
///
/// Les pages de l'app utilisent une transition en fondu commune (voir
/// `_fadePage` dans le routeur), qui ne fournit pas le geste « glisser pour
/// revenir » d'iOS. Ce widget le rétablit sans changer la transition : un
/// glissement vers la droite parti du bord gauche déclenche le même retour
/// que la flèche — il respecte donc les gardes de saisie non enregistrée.
///
/// Sur Android, le retour système (geste ou bouton) existe déjà : le widget
/// ne fait rien.
class SignmeEdgeSwipeBack extends StatefulWidget {
  const SignmeEdgeSwipeBack({super.key, required this.child});

  final Widget child;

  /// Largeur de la zone sensible, collée au bord gauche de l'écran.
  static const double edgeWidth = 20;

  /// Distance (px) ou vitesse (px/s) à partir desquelles le geste vaut retour.
  static const double minDistance = 64;
  static const double minVelocity = 320;

  @override
  State<SignmeEdgeSwipeBack> createState() => _SignmeEdgeSwipeBackState();
}

class _SignmeEdgeSwipeBackState extends State<SignmeEdgeSwipeBack> {
  double _dragged = 0;

  Future<void> _back() async {
    // Même ordre que le retour système : la page courante d'abord (elle peut
    // refuser via PopScope), puis la pile principale.
    final handled = await Navigator.of(context).maybePop();
    if (handled || !mounted) return;
    await Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform != TargetPlatform.iOS) return widget.child;

    return Stack(
      children: [
        widget.child,
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          width: SignmeEdgeSwipeBack.edgeWidth,
          child: GestureDetector(
            // Translucide : les touchers simples atteignent le contenu dessous.
            behavior: HitTestBehavior.translucent,
            onHorizontalDragStart: (_) => _dragged = 0,
            onHorizontalDragUpdate: (d) => _dragged += d.delta.dx,
            onHorizontalDragEnd: (d) {
              final velocity = d.primaryVelocity ?? 0;
              if (_dragged >= SignmeEdgeSwipeBack.minDistance || velocity >= SignmeEdgeSwipeBack.minVelocity) {
                _back();
              }
            },
          ),
        ),
      ],
    );
  }
}
