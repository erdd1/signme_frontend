import 'package:flutter/material.dart';

/// Réduit son contenu de la hauteur du clavier — ce que fait un Scaffold avec
/// `resizeToAvoidBottomInset`, mais pour le seul contenu : le reste d'un
/// empilement (navbar flottante, bandeaux) garde sa position.
///
/// La hauteur du clavier est retirée du MediaQuery des descendants : ils ne
/// la compensent pas une seconde fois (feuilles du bas, boîtes de dialogue
/// qui ajoutent déjà `viewInsets.bottom`).
class KeyboardAvoidingBody extends StatelessWidget {
  const KeyboardAvoidingBody({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: MediaQuery.removeViewInsets(
        context: context,
        removeBottom: true,
        child: child,
      ),
    );
  }
}
