import 'package:flutter/widgets.dart';

/// Validators réutilisables pour les formulaires Flutter
abstract final class AppValidators {
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est obligatoire';
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Ce champ est obligatoire';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(value.trim())) return 'Email invalide';
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    if (value.length < 6) return 'Minimum 6 caractères';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Numéro incomplet (9 chiffres minimum)';
    return null;
  }

  static FormFieldValidator<String> minLength(int min) {
    return (value) {
      if (value == null || value.isEmpty) return 'Ce champ est obligatoire';
      if (value.length < min) return 'Minimum $min caractères';
      return null;
    };
  }

  static FormFieldValidator<String> maxLength(int max) {
    return (value) {
      if (value != null && value.length > max) return 'Maximum $max caractères';
      return null;
    };
  }
}
