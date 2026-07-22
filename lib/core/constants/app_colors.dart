import 'package:flutter/material.dart';

/// Palette de couleurs EEC SignCard — Navy Blue + Gold accent
abstract final class AppColors {

  // ── Primaires ───────────────────────────────────────────────────────────
  static const Color primary        = Color(0xFF1A2B6B); // Navy blue EEC
  static const Color primaryLight   = Color(0xFF2D45A0);
  static const Color primarySurface = Color(0xFFEEF1FA); // Navy très clair
  static const Color secondary      = Color(0xFFF4A522); // Gold/amber accent

  // ── Fonds & Surfaces ────────────────────────────────────────────────────
  static const Color background     = Color(0xFFF6F7FB);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F2F8);

  // ── Textes ──────────────────────────────────────────────────────────────
  static const Color textPrimary    = Color(0xFF0D1B3E);
  static const Color textSecondary  = Color(0xFF6B7A99);
  static const Color textHint       = Color(0xFFB0BAD3);
  static const Color textOnPrimary  = Colors.white;

  // ── Bordures & Séparateurs ──────────────────────────────────────────────
  static const Color border         = Color(0xFFDFE4F0);
  static const Color divider        = Color(0xFFEEF1F8);

  // ── États ───────────────────────────────────────────────────────────────
  static const Color success        = Color(0xFF22C55E);
  static const Color successLight   = Color(0xFFDCFCE7);
  static const Color error          = Color(0xFFEF4444);
  static const Color errorLight     = Color(0xFFFEE2E2);
  static const Color warning        = Color(0xFFF59E0B);
  static const Color warningLight   = Color(0xFFFEF3C7);
  static const Color info           = Color(0xFF3B82F6);
  static const Color infoLight      = Color(0xFFDBEAFE);

  // ── Signature ───────────────────────────────────────────────────────────
  static const Color signed         = Color(0xFF22C55E); // mois signé (vert)
  static const Color notSigned      = Color(0xFFB0BAD3); // – (gris)

  // ── Navigation ──────────────────────────────────────────────────────────
  static const Color navBackground  = Color(0xFFFFFFFF);
  static const Color navActive      = Color(0xFF1A2B6B);
  static const Color navInactive    = Color(0xFF6B7A99);

  // ── Shimmer ─────────────────────────────────────────────────────────────
  static const Color shimmerBase      = Color(0xFFE8ECF5);
  static const Color shimmerHighlight = Color(0xFFF5F7FF);

  // ── Gradients ───────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A2B6B), Color(0xFF2D45A0)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );

  static const LinearGradient loginGradient = LinearGradient(
    colors: [Color(0xFFF6F7FB), Color(0xFFEEF1FA)],
    begin:  Alignment.topCenter,
    end:    Alignment.bottomCenter,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF4A522), Color(0xFFFFCC60)],
    begin:  Alignment.topLeft,
    end:    Alignment.bottomRight,
  );

  // ── Couleurs par rôle ───────────────────────────────────────────────────
  static Color roleColor(String role) {
    const map = {
      'pasteur':        Color(0xFF1A2B6B),
      'secretaire':     Color(0xFF0EA5E9),
      'tresorier':      Color(0xFF22C55E),
      'ancien':         Color(0xFFF4A522),
      'paroissien':     Color(0xFF6B7A99),
    };
    return map[role] ?? const Color(0xFF6B7A99);
  }
}
