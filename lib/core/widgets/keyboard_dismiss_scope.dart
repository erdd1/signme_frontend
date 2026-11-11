import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../design_system/signme_colors.dart';

/// Permet de refermer le clavier partout dans l'application :
/// - un toucher en dehors d'un champ de saisie referme le clavier ;
/// - sur iOS, les claviers numériques (nombre, téléphone) n'ont pas de touche
///   de validation : une barre « Terminé » s'affiche alors au-dessus du clavier.
///
/// Quand la barre « Terminé » est affichée, la hauteur qu'elle occupe est
/// ajoutée à celle du clavier vue par les écrans : le contenu est donc
/// remonté d'autant et le champ en cours de saisie reste visible au-dessus
/// de la barre (au lieu d'être caché derrière).
///
/// À placer une seule fois, dans le `builder` de l'application.
/// Hauteur de la barre « Terminé ».
const double kKeyboardDoneBarHeight = 44;

class KeyboardDismissScope extends StatefulWidget {
  const KeyboardDismissScope({super.key, required this.child});

  final Widget child;

  @override
  State<KeyboardDismissScope> createState() => _KeyboardDismissScopeState();
}

class _KeyboardDismissScopeState extends State<KeyboardDismissScope> {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() {
    if (mounted) setState(() {});
  }

  void _dismiss() => FocusManager.instance.primaryFocus?.unfocus();

  /// Le champ actuellement actif utilise-t-il un clavier numérique ?
  bool get _numericFieldFocused {
    final context = FocusManager.instance.primaryFocus?.context;
    final keyboard = context?.findAncestorWidgetOfExactType<EditableText>()?.keyboardType;

    return keyboard != null &&
        (keyboard.index == TextInputType.number.index || keyboard.index == TextInputType.phone.index);
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final keyboardHeight = media.viewInsets.bottom;
    final showDoneBar =
        defaultTargetPlatform == TargetPlatform.iOS && keyboardHeight > 0 && _numericFieldFocused;

    final content = showDoneBar
        ? MediaQuery(
            data: media.copyWith(
              viewInsets: media.viewInsets.copyWith(bottom: keyboardHeight + kKeyboardDoneBarHeight),
            ),
            child: widget.child,
          )
        : widget.child;

    return Stack(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _dismiss,
          child: content,
        ),
        if (showDoneBar)
          Positioned(
            left: 0,
            right: 0,
            bottom: keyboardHeight,
            child: _DoneBar(onDone: _dismiss),
          ),
      ],
    );
  }
}

/// Barre « Terminé » collée au clavier numérique (accessoire iOS classique).
class _DoneBar extends StatelessWidget {
  const _DoneBar({required this.onDone});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SignmeColors.surface,
      elevation: 2,
      child: Container(
        height: kKeyboardDoneBarHeight,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: SignmeColors.lightGrayBorder)),
        ),
        child: TextButton(
          onPressed: onDone,
          child: const Text(
            'Terminé',
            style: TextStyle(
              color: SignmeColors.primaryLight,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}
