import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/evenements/domain/card_fee_calculator.dart';
import 'package:signme/features/evenements/domain/entities/card_payment_config_entity.dart';

/// Mêmes cas que CardFeeCalculatorServiceTest côté backend : l'affichage
/// instantané doit toujours donner le même total que le serveur.
void main() {
  group('CardFeeCalculator', () {
    test('grossUp : majore sans borne de barème (cumul de mois de signature)', () {
      expect(CardFeeCalculator.grossUp(2000, 5), 2106);
      expect(CardFeeCalculator.grossUp(120000, 5), 126316); // au-delà du barème d'une contribution
      expect(CardFeeCalculator.grossUp(0, 5), isNull);
      expect(CardFeeCalculator.grossUp(1000, 100), isNull);
      expect(CardFeeCalculator.grossUp(1000, -1), isNull);
    });

    test('le total est majoré pour que l\'église reçoive exactement le montant', () {
      expect(CardFeeCalculator.calculateTotal(1000, 4.8), 1051); // 1050,42 -> 1051
      expect(CardFeeCalculator.calculate(1000, 4.8), 51);
    });

    test('pas de FCFA en trop à cause des erreurs de virgule flottante', () {
      expect(CardFeeCalculator.calculateTotal(950, 5.0), 1000);
    });

    test('taux nul : aucun frais', () {
      expect(CardFeeCalculator.calculate(5000, 0), 0);
    });

    test('mêmes bornes et même pas que les autres contributions', () {
      for (final bad in [499, 505, 1000050, 0, -500]) {
        expect(CardFeeCalculator.calculateTotal(bad, 4.8), isNull, reason: '$bad');
      }
      expect(CardFeeCalculator.calculateTotal(500, 0), 500);
      expect(CardFeeCalculator.calculateTotal(1000000, 0), 1000000);
    });

    test('un taux absurde est refusé', () {
      expect(CardFeeCalculator.calculateTotal(1000, 100), isNull);
      expect(CardFeeCalculator.calculateTotal(1000, -1), isNull);
    });
  });

  group('CardPaymentConfigEntity', () {
    test('lit l\'interrupteur et le taux du serveur', () {
      final config = CardPaymentConfigEntity.fromJson({'enabled': true, 'currency': 'XAF', 'feePercent': 4.8});

      expect(config.enabled, isTrue);
      expect(config.feePercent, 4.8);
    });

    test('une réponse incomplète désactive l\'option carte', () {
      expect(CardPaymentConfigEntity.fromJson({}).enabled, isFalse);
      expect(CardPaymentConfigEntity.disabled.enabled, isFalse);
    });
  });
}
