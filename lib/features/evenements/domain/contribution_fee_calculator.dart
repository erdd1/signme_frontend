/// Calculateur de frais pour les contributions aux événements (module
/// crowdfunding). Réplique EXACTEMENT la grille de
/// `App\Modules\Evenement\Application\Services\ContributionFeeCalculatorService`
/// côté backend — utilisé uniquement pour l'affichage instantané. Le backend
/// recalcule toujours les frais côté serveur, jamais confiance au frontend.
abstract final class ContributionFeeCalculator {
  static const int montantMin = 500;
  static const int montantMax = 1000000;
  static const int multipleDe = 50;

  // TODO(TEST TEMPORAIRE) : montant de 15 FCFA (frais 5 FCFA) ajouté
  // uniquement pour tester le flux de paiement CamPay sans débiter de
  // grosses sommes. À SUPPRIMER avant mise en production définitive — miroir
  // exact du TODO côté backend (ContributionFeeCalculatorService).
  static const int _montantTestTemporaire = 15;

  static bool isValidAmount(int montant) {
    // TODO(TEST TEMPORAIRE) : à supprimer.
    if (montant == _montantTestTemporaire) return true;

    return montant >= montantMin &&
        montant <= montantMax &&
        montant % multipleDe == 0;
  }

  /// Retourne les frais applicables, ou null si le montant est hors barème.
  static int? calculate(int montant) {
    if (!isValidAmount(montant)) return null;

    // TODO(TEST TEMPORAIRE) : à supprimer.
    if (montant == _montantTestTemporaire) return 5;

    if (montant >= 500 && montant <= 950) return 50;
    if (montant >= 1000 && montant <= 5000) return 100;
    if (montant >= 5050 && montant <= 10000) return 200;
    if (montant >= 10050 && montant <= 50000) return 300;
    if (montant >= 50050 && montant <= 99950) return 400;
    if (montant >= 100000 && montant <= 999950) {
      final premierChiffre = int.parse(montant.toString()[0]);
      return 400 * premierChiffre;
    }
    if (montant == montantMax) return 10000;

    return null;
  }

  /// Retourne (montant, frais, total) — frais/total null si hors barème.
  static ({int montant, int? frais, int? total}) calculateTotal(int montant) {
    final frais = calculate(montant);
    return (montant: montant, frais: frais, total: frais == null ? null : montant + frais);
  }
}
