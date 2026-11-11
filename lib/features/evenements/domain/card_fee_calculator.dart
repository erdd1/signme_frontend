import 'contribution_fee_calculator.dart';

/// Frais du paiement par carte — réplique de
/// `App\Modules\Evenement\Application\Services\CardFeeCalculatorService` côté
/// backend, pour l'affichage instantané uniquement (le serveur recalcule
/// toujours frais et total).
///
/// Le fournisseur retient un pourcentage du total débité : pour que l'église
/// reçoive exactement le montant prévu, total = montant / (1 - taux), arrondi
/// au FCFA supérieur. Mêmes bornes de montant que les autres contributions.
abstract final class CardFeeCalculator {
  /// Frais de carte, ou null si le montant est hors barème ou le taux invalide.
  static int? calculate(int montant, double percent) {
    final total = calculateTotal(montant, percent);
    return total == null ? null : total - montant;
  }

  /// Total à débiter, ou null si le montant est hors barème ou le taux invalide.
  static int? calculateTotal(int montant, double percent) {
    if (!ContributionFeeCalculator.isValidAmount(montant)) return null;
    if (percent < 0 || percent >= 100) return null;

    // Arrondi à 6 décimales avant ceil() : évite qu'une erreur de virgule
    // flottante (ex. 1000.0000000000001) ajoute 1 FCFA de trop.
    final exact = montant / (1 - percent / 100);
    return double.parse(exact.toStringAsFixed(6)).ceil();
  }
}
