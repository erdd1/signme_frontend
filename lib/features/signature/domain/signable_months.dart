/// Mois pour lesquels une signature est possible : jusqu'au mois PROCHAIN
/// inclus, jamais au-delà (en octobre : novembre oui, décembre non ; en
/// décembre 2026 : janvier 2027 oui, février 2027 non). Réplique de
/// `SignatureService::dernierMoisSignable()` côté serveur, pour verrouiller
/// l'affichage — le serveur reste l'autorité et refuse tout mois trop lointain.
abstract final class SignableMonths {
  /// Dernier mois signable, au format « AAAA-MM ».
  static String last(DateTime now) {
    // DateTime normalise le mois 13 en janvier de l'année suivante.
    final next = DateTime(now.year, now.month + 1);
    return _key(next.year, next.month);
  }

  /// [month] au format « AAAA-MM ». Les mois passés restent signables (sous
  /// les autres contraintes : déjà signé, plancher communiant…).
  static bool isSignable(String month, DateTime now) => month.compareTo(last(now)) <= 0;

  static String _key(int year, int month) => '$year-${month.toString().padLeft(2, '0')}';
}
