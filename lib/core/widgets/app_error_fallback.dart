import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Écran de secours affiché à la place d'un widget dont la construction a
/// échoué — remplace l'écran technique gris/rouge par défaut de Flutter,
/// jamais montré à un vrai utilisateur. N'interrompt jamais l'app : seul le
/// widget fautif est remplacé, le reste de l'écran (navbar, etc.) continue
/// de fonctionner normalement.
///
/// Défensif par construction : pas de dépendance à un Scaffold/Theme
/// ambiant (peut s'afficher n'importe où dans l'arbre, y compris très tôt
/// au démarrage) — enveloppé dans son propre Directionality/couleurs en dur.
class AppErrorFallback extends StatelessWidget {
  const AppErrorFallback({super.key, required this.details});

  final FlutterErrorDetails details;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        color: const Color(0xFFF7F8FA),
        alignment: Alignment.center,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded, color: Color(0xFFE53935), size: 40),
            const SizedBox(height: 12),
            const Text(
              'Un problème est survenu',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
            ),
            if (kDebugMode) ...[
              const SizedBox(height: 8),
              Text(
                details.exceptionAsString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: Color(0xFF6B6B80)),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
