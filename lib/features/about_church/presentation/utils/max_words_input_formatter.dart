import 'package:flutter/services.dart';

/// Bloque toute saisie qui ferait dépasser [maxWords] mots — miroir client
/// de `App\Modules\AboutChurch\Http\Requests\Rules\MaxWordsRule` côté
/// backend. Distinct de la pagination d'affichage (~10 lignes/page) : cette
/// limite empêche uniquement la création d'un contenu déraisonnablement
/// long, quel que soit le nombre de pages qu'il occupera à l'affichage.
class MaxWordsInputFormatter extends TextInputFormatter {
  MaxWordsInputFormatter(this.maxWords);

  final int maxWords;

  static int countWords(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 0;
    return trimmed.split(RegExp(r'\s+')).length;
  }

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (countWords(newValue.text) <= maxWords) return newValue;
    // Saisie refusée : on revient à l'ancienne valeur (le champ n'accepte
    // plus de nouveaux caractères une fois la limite atteinte).
    return oldValue;
  }
}
