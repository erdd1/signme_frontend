import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/evenements/domain/contribution_fee_calculator.dart';

void main() {
  group('ContributionFeeCalculator', () {
    test('borne basse 500 -> 50', () {
      expect(ContributionFeeCalculator.calculate(500), 50);
    });
    test('exemple utilisateur 700 -> 50', () {
      expect(ContributionFeeCalculator.calculate(700), 50);
    });
    test('borne haute 950 -> 50', () {
      expect(ContributionFeeCalculator.calculate(950), 50);
    });
    test('borne basse 1000 -> 100', () {
      expect(ContributionFeeCalculator.calculate(1000), 100);
    });
    test('exemple utilisateur 4000 -> 100', () {
      expect(ContributionFeeCalculator.calculate(4000), 100);
    });
    test('borne haute 5000 -> 100', () {
      expect(ContributionFeeCalculator.calculate(5000), 100);
    });
    test('borne basse 5050 -> 200', () {
      expect(ContributionFeeCalculator.calculate(5050), 200);
    });
    test('borne haute 10000 -> 200', () {
      expect(ContributionFeeCalculator.calculate(10000), 200);
    });
    test('borne basse 10050 -> 300', () {
      expect(ContributionFeeCalculator.calculate(10050), 300);
    });
    test('borne haute 50000 -> 300', () {
      expect(ContributionFeeCalculator.calculate(50000), 300);
    });
    test('borne basse 50050 -> 400', () {
      expect(ContributionFeeCalculator.calculate(50050), 400);
    });
    test('borne haute 99950 -> 400', () {
      expect(ContributionFeeCalculator.calculate(99950), 400);
    });
    test('borne basse 100000 (premier chiffre 1) -> 400', () {
      expect(ContributionFeeCalculator.calculate(100000), 400);
    });
    test('exemple utilisateur 560000 (premier chiffre 5) -> 2000', () {
      expect(ContributionFeeCalculator.calculate(560000), 2000);
    });
    test('premier chiffre 9 : 950000 -> 3600', () {
      expect(ContributionFeeCalculator.calculate(950000), 3600);
    });
    test('borne haute 999950 -> 3600', () {
      expect(ContributionFeeCalculator.calculate(999950), 3600);
    });
    test('montant maximum 1000000 -> 10000', () {
      expect(ContributionFeeCalculator.calculate(1000000), 10000);
    });

    test('calculateTotal exemple 700 -> 750', () {
      final r = ContributionFeeCalculator.calculateTotal(700);
      expect(r.montant, 700);
      expect(r.frais, 50);
      expect(r.total, 750);
    });

    test('rejects amounts out of bounds or not multiple of 50', () {
      expect(ContributionFeeCalculator.calculate(499), isNull);
      expect(ContributionFeeCalculator.calculate(1000001), isNull);
      expect(ContributionFeeCalculator.calculate(510), isNull);
      expect(ContributionFeeCalculator.calculate(0), isNull);
    });

    test('isValidAmount', () {
      expect(ContributionFeeCalculator.isValidAmount(500), isTrue);
      expect(ContributionFeeCalculator.isValidAmount(1000000), isTrue);
      expect(ContributionFeeCalculator.isValidAmount(499), isFalse);
      expect(ContributionFeeCalculator.isValidAmount(505), isFalse);
    });
  });
}
