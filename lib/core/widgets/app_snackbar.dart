import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design_system/index.dart';

/// Point d'entrée unique des messages éphémères de l'app (palette SignMe).
/// Le succès et l'erreur s'accompagnent d'un léger retour haptique.
abstract final class AppSnackbar {
  static void success(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _show(context, message, SignmeColors.success, Icons.check_circle_rounded);
  }

  static void error(BuildContext context, String message) {
    HapticFeedback.mediumImpact();
    _show(context, message, SignmeColors.error, Icons.error_rounded);
  }

  static void info(BuildContext context, String message) =>
      _show(context, message, SignmeColors.primaryLight, Icons.info_rounded);

  static void warning(BuildContext context, String message) =>
      _show(context, message, SignmeColors.warning, Icons.warning_rounded);

  static void _show(BuildContext context, String message, Color color, IconData icon) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        behavior:        SnackBarBehavior.floating,
        shape:           RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin:          const EdgeInsets.all(16),
        duration:        const Duration(seconds: 3),
      ),
    );
  }
}
