// ── Extensions utilitaires ────────────────────────────────────────────────────
import 'package:intl/intl.dart';

extension IntFormatExt on int {
  /// Formate un montant en XAF : 7500 → "7 500 FCFA"
  String toXaf() => '${NumberFormat('#,###', 'fr_FR').format(this)} FCFA';

  /// Formate un montant court : 7500 → "7 500 F"
  String toXafShort() => '${NumberFormat('#,###', 'fr_FR').format(this)} F';
}

extension StringExt on String {
  /// Capitalise la première lettre
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Retourne les initiales (ex: "Jean Dupont" → "JD")
  String get initials {
    final parts = trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts.last[0]}'.toUpperCase();
  }
}

extension DateTimeExt on DateTime {
  /// Retourne "YYYY-MM" (format backend)
  String toMonthString() {
    final m = month.toString().padLeft(2, '0');
    return '$year-$m';
  }

  /// Retourne si c'est le mois courant
  bool get isCurrentMonth {
    final now = DateTime.now();
    return year == now.year && month == now.month;
  }
}
