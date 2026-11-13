import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'signme_dialogs.dart';

/// Vrai lorsqu'un formulaire actuellement affiché contient des modifications
/// non enregistrées. Un seul drapeau global : un seul formulaire de saisie
/// est ouvert à la fois dans cette app (pas de formulaires imbriqués).
///
/// Positionné à `true` par l'écran de formulaire dès la première saisie,
/// remis à `false` après un enregistrement réussi ou un abandon confirmé.
final formDirtyProvider = StateProvider<bool>((ref) => false);

/// Affiche la boîte de dialogue de confirmation d'abandon de saisie.
/// Point d'écriture UNIQUE de ce dialogue — réutilisé par
/// [SignmeUnsavedChangesGuard] (retour système/AppBar) et par la navbar
/// flottante de [MainShell] (changement d'onglet), pour éviter toute
/// duplication du même texte/style à plusieurs endroits.
Future<bool> confirmDiscardChanges(BuildContext context) {
  return signmeConfirm(
    context,
    title: 'Abandonner la saisie ?',
    message: 'Vous avez des modifications non enregistrées. Si vous quittez maintenant, elles seront perdues.',
    confirmLabel: 'Quitter sans enregistrer',
    cancelLabel: 'Continuer la saisie',
    isDangerous: true,
  );
}

/// Enveloppe un écran de formulaire pour bloquer toute sortie accidentelle
/// (bouton retour système, geste retour, flèche de l'AppBar) tant que
/// [formDirtyProvider] est `true` — affiche alors [confirmDiscardChanges]
/// et ne quitte que si l'utilisateur confirme.
///
/// Ne couvre PAS la navbar flottante de [MainShell] (qui utilise `go()`,
/// pas un `pop()` — voir `MainShell._onNavTap`, qui consulte le même
/// [formDirtyProvider] et appelle la même [confirmDiscardChanges]).
///
/// Usage:
/// ```dart
/// return SignmeUnsavedChangesGuard(
///   child: Scaffold(...),
/// );
/// ```
class SignmeUnsavedChangesGuard extends ConsumerWidget {
  const SignmeUnsavedChangesGuard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopScope(
      canPop: !ref.read(formDirtyProvider),
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final confirmed = await confirmDiscardChanges(context);
        if (confirmed) {
          ref.read(formDirtyProvider.notifier).state = false;
          if (context.mounted) Navigator.of(context).pop();
        }
      },
      child: child,
    );
  }
}
