/// Formatte le sexe ('homme'/'femme') pour l'affichage.
String formatSexeLabel(String? sexe) {
  switch (sexe) {
    case 'homme':
      return 'Homme';
    case 'femme':
      return 'Femme';
    default:
      return '—';
  }
}

/// Formatte une date ISO (YYYY-MM-DD) en DD/MM/YYYY pour l'affichage.
String formatIsoDateLabel(String? iso) {
  if (iso == null || iso.isEmpty) return '—';
  final date = DateTime.tryParse(iso);
  if (date == null) return '—';
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/'
      '${date.year}';
}
