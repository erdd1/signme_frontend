import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/transactions/domain/entities/transaction_entity.dart';

Map<String, dynamic> _json({Map<String, dynamic> extra = const {}}) => {
      'id': 'contribution:abc',
      'type': 'contribution',
      'motif': 'Contribution — Excellence scolaire',
      'details': <String>[],
      'eglise': 'EEC Messamendongo',
      'montant': 1000,
      'frais': 100,
      'montantTotal': 1100,
      'statut': 'completed',
      'paymentMethod': 'mobile_money',
      'paymentLabel': 'Orange Money',
      'paymentNumber': '699803165',
      'cardBrand': null,
      'cardLast4': null,
      'reference': 'REF-1',
      'receivedBy': null,
      'createdAt': '2026-11-11T02:14:05+01:00',
      ...extra,
    };

void main() {
  group('formatCameroonPhone', () {
    test('formate un numéro de 9 chiffres comme dans les relevés', () {
      expect(formatCameroonPhone('699803165'), '+237 6 99 80 31 65');
    });

    test('accepte l\'indicatif 237 et ignore la ponctuation', () {
      expect(formatCameroonPhone('237699803165'), '+237 6 99 80 31 65');
      expect(formatCameroonPhone('+237 6 99 80 31 65'), '+237 6 99 80 31 65');
    });

    test('un format inconnu est renvoyé tel quel', () {
      expect(formatCameroonPhone('12345'), '12345');
    });
  });

  group('TransactionEntity.fromJson', () {
    test('lit une transaction Mobile Money', () {
      final t = TransactionEntity.fromJson(_json());

      expect(t.type, TransactionType.contribution);
      expect(t.status, TransactionStatus.completed);
      expect(t.montantTotal, 1100);
      expect(t.account, '+237 6 99 80 31 65');
      expect(t.typeLabel, 'Contribution à un événement');
      expect(t.createdAt.isUtc || t.createdAt.timeZoneOffset != null, isTrue);
    });

    test('un paiement par carte affiche la marque et les 4 derniers chiffres', () {
      final t = TransactionEntity.fromJson(_json(extra: {
        'type': 'don',
        'paymentMethod': 'card',
        'paymentLabel': 'Carte bancaire',
        'paymentNumber': null,
        'cardBrand': 'VISA',
        'cardLast4': '4242',
      }));

      expect(t.isCard, isTrue);
      expect(t.account, 'VISA •••• 4242');
      expect(t.typeLabel, 'Don');
    });

    test('une carte non confirmée (sans chiffres) reste « Carte bancaire »', () {
      final t = TransactionEntity.fromJson(_json(extra: {
        'paymentMethod': 'card',
        'paymentLabel': 'Carte bancaire',
        'paymentNumber': null,
        'statut': 'pending',
      }));

      expect(t.account, 'Carte bancaire');
      expect(t.status, TransactionStatus.pending);
    });

    test('les espèces n\'ont pas de numéro', () {
      final t = TransactionEntity.fromJson(_json(extra: {
        'type': 'signature',
        'paymentMethod': 'cash',
        'paymentLabel': 'Espèces',
        'paymentNumber': null,
        'receivedBy': 'Ancien Paul',
        'details': ['Mars 2026', 'Avril 2026'],
      }));

      expect(t.isCash, isTrue);
      expect(t.account, 'Espèces');
      expect(t.details, ['Mars 2026', 'Avril 2026']);
      expect(t.typeLabel, 'Signature (Sainte-Cène)');
    });

    test('un échec et un statut inconnu', () {
      expect(TransactionEntity.fromJson(_json(extra: {'statut': 'failed'})).status, TransactionStatus.failed);
      expect(TransactionEntity.fromJson(_json(extra: {'statut': '???'})).status, TransactionStatus.pending);
    });

    test('tolère des champs manquants sans lever d\'exception', () {
      final t = TransactionEntity.fromJson({});

      expect(t.montantTotal, 0);
      expect(t.motif, '');
      expect(t.paymentMethod, 'mobile_money');
    });
  });

  test('TransactionsPage.hasMore suit la pagination', () {
    expect(const TransactionsPage(items: [], currentPage: 1, lastPage: 3).hasMore, isTrue);
    expect(const TransactionsPage(items: [], currentPage: 3, lastPage: 3).hasMore, isFalse);
  });
}
