import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/utils/password_policy.dart';

/// Indicateur compact de force du mot de passe — SignMe.
///
/// Affiche :
///  1. Une barre de progression à 4 segments (rouge → orange → jaune → vert)
///  2. Une seule ligne de texte dynamique : le premier critère manquant,
///     ou "Mot de passe fort" quand tout est OK.
///
/// Invisible si le champ est vide.
///
/// Usage :
/// ```dart
/// PasswordStrengthIndicator(password: _passwordValue)
/// ```
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  // ── Calcul de la force (0–4) ──────────────────────────────────────────────

  int get _strength {
    if (password.isEmpty) return 0;
    int score = 0;
    if (PasswordPolicy.hasNoSpace(password))      score++;
    if (PasswordPolicy.hasMinLength(password))    score++;
    if (PasswordPolicy.hasUppercase(password))    score++;
    if (PasswordPolicy.hasLowercase(password))    score++;
    if (PasswordPolicy.hasDigit(password))        score++;
    if (PasswordPolicy.hasSpecialChar(password))  score++;
    if (PasswordPolicy.hasMaxLength(password))    score++;

    if (score <= 2) return 1;
    if (score <= 4) return 2;
    if (score <= 6) return 3;
    return 4;
  }

  // ── Premier critère manquant (ordre de priorité) ──────────────────────────

  String? get _hint {
    if (password.isEmpty) return null;
    if (!PasswordPolicy.hasNoSpace(password))     return 'Retirez les espaces';
    if (!PasswordPolicy.hasMinLength(password))   return 'Minimum 10 caractères requis';
    if (!PasswordPolicy.hasMaxLength(password))   return 'Maximum 30 caractères autorisés';
    if (!PasswordPolicy.hasUppercase(password))   return 'Ajoutez une lettre majuscule (A-Z)';
    if (!PasswordPolicy.hasLowercase(password))   return 'Ajoutez une lettre minuscule (a-z)';
    if (!PasswordPolicy.hasDigit(password))       return 'Ajoutez un chiffre (0-9)';
    if (!PasswordPolicy.hasSpecialChar(password)) return 'Ajoutez un caractère spécial (! @ # \$ % ^ & * ?)';
    return null; // tous les critères satisfaits
  }

  // ── Couleur selon la force ────────────────────────────────────────────────

  Color get _color => switch (_strength) {
    1 => const Color(0xFFE53935),
    2 => const Color(0xFFFF7043),
    3 => const Color(0xFFFFB300),
    4 => SignmeColors.success,
    _ => SignmeColors.mediumGray,
  };

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final allMet   = PasswordPolicy.isValid(password);
    final hint     = _hint;
    final strength = _strength;
    final color    = _color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Barre de force (4 segments animés) ─────────────────────────────
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                height: 3,
                margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: i < strength ? color : SignmeColors.lightGray,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 6),

        // ── Message dynamique (1 seule ligne) ──────────────────────────────
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.3),
                end:   Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: Row(
            key: ValueKey(hint ?? '__done__'),
            children: [
              Icon(
                allMet
                    ? Icons.check_circle_rounded
                    : Icons.error_outline_rounded,
                size: 12,
                color: color,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  allMet ? 'Mot de passe fort' : (hint ?? ''),
                  style: SignmeTypography.labelSmall.copyWith(
                    color: color,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

