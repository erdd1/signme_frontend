/// Politique de mot de passe forte — SignMe
///
/// Utilisé par :
///   - reset_password_screen.dart
///   - change_password_screen.dart (si existant)
///
/// Règles :
///   ✓ 10 à 30 caractères
///   ✓ Au moins une majuscule
///   ✓ Au moins une minuscule
///   ✓ Au moins un chiffre
///   ✓ Au moins un caractère spécial : ! @ # $ % ^ & * ?
///   ✗ Aucun espace autorisé
abstract final class PasswordPolicy {
  // ── Patterns ──────────────────────────────────────────────────────────────

  static final _hasUppercase    = RegExp(r'[A-Z]');
  static final _hasLowercase    = RegExp(r'[a-z]');
  static final _hasDigit        = RegExp(r'\d');
  static final _hasSpecial      = RegExp(r'[!@#$%^&*?]');
  static final _hasNoSpace      = RegExp(r'^\S+$');

  // ── Checks individuels ────────────────────────────────────────────────────

  static bool hasMinLength(String v)    => v.length >= 10;
  static bool hasMaxLength(String v)    => v.length <= 30;
  static bool hasUppercase(String v)    => _hasUppercase.hasMatch(v);
  static bool hasLowercase(String v)    => _hasLowercase.hasMatch(v);
  static bool hasDigit(String v)        => _hasDigit.hasMatch(v);
  static bool hasSpecialChar(String v)  => _hasSpecial.hasMatch(v);
  static bool hasNoSpace(String v)      => _hasNoSpace.hasMatch(v) || v.isEmpty;

  // ── Validation globale ────────────────────────────────────────────────────

  /// Retourne `true` si TOUS les critères sont satisfaits.
  static bool isValid(String v) =>
      hasMinLength(v) &&
      hasMaxLength(v) &&
      hasUppercase(v) &&
      hasLowercase(v) &&
      hasDigit(v) &&
      hasSpecialChar(v) &&
      hasNoSpace(v);

  /// Message pour les formulaires Flutter (validator callback).
  /// Retourne `null` si valide, sinon le premier problème rencontré.
  static String? validate(String? v) {
    if (v == null || v.isEmpty) return 'Le mot de passe est obligatoire.';
    if (!hasNoSpace(v))     return 'Le mot de passe ne doit pas contenir d\'espaces.';
    if (!hasMinLength(v))   return 'Minimum 10 caractères requis.';
    if (!hasMaxLength(v))   return 'Maximum 30 caractères autorisés.';
    if (!hasUppercase(v))   return 'Au moins une lettre majuscule requise.';
    if (!hasLowercase(v))   return 'Au moins une lettre minuscule requise.';
    if (!hasDigit(v))       return 'Au moins un chiffre requis.';
    if (!hasSpecialChar(v)) return 'Au moins un caractère spécial requis (! @ # \$ % ^ & * ?).';
    return null;
  }
}
