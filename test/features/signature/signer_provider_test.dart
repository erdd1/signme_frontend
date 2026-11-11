import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/auth/domain/entities/user_entity.dart';
import 'package:signme/features/signature/domain/entities/member_signature_status.dart';
import 'package:signme/features/signature/domain/entities/payment_transaction_status.dart';
import 'package:signme/features/signature/domain/entities/signature_entity.dart';
import 'package:signme/features/signature/domain/repositories/signature_repository.dart';
import 'package:signme/features/signature/domain/signable_months.dart';
import 'package:signme/features/signature/presentation/providers/signer_provider.dart';

class _PendingSearch {
  _PendingSearch({required this.query, required this.completer});
  final String query;
  final Completer<List<UserEntity>> completer;
}

/// Fake ciblé : seules [searchMembers], [initiateDistancePayment] et
/// [getTransactionStatus] sont exercées par les scénarios de ce fichier — les
/// autres méthodes de l'interface ne sont jamais appelées ici.
class _FakeSignatureRepository implements SignatureRepository {
  final List<_PendingSearch> pending = [];
  final List<Completer<DistancePaymentInitResult>> pendingPayments = [];
  final List<Map<String, Object?>> paymentRequests = [];

  @override
  Future<List<UserEntity>> searchMembers(String query) {
    final completer = Completer<List<UserEntity>>();
    pending.add(_PendingSearch(query: query, completer: completer));
    return completer.future;
  }

  @override
  Future<MaCarteData> getMaCarte(int year) => throw UnimplementedError();

  @override
  Future<DistancePaymentInitResult> initiateDistancePayment({
    required List<String> months,
    required int amount,
    required String paymentMethod,
    String? paymentOperator,
    String? phoneNumber,
  }) {
    paymentRequests.add({
      'amount': amount,
      'paymentMethod': paymentMethod,
      'paymentOperator': paymentOperator,
      'phoneNumber': phoneNumber,
    });
    final completer = Completer<DistancePaymentInitResult>();
    pendingPayments.add(completer);
    return completer.future;
  }

  @override
  Future<PaymentTransactionStatus> getTransactionStatus(int transactionId) async =>
      const PaymentTransactionStatus(status: 'completed', progress: 1.0, isTerminal: true);

  @override
  Future<bool> initiatePresentielSignature({
    required int userId,
    required List<String> months,
    required int amount,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<UserEntity>> getPasteurMembers() => throw UnimplementedError();

  @override
  Future<MemberSignatureStatus?> getMemberStatus(
    int userId,
    String monthParam,
  ) =>
      throw UnimplementedError();

  @override
  Future<Map<String, dynamic>?> canSignPresentielNow() =>
      throw UnimplementedError();
}

UserEntity _member(int id, String nom) =>
    UserEntity(id: id, nom: nom, email: '$nom@test.com', role: 'paroissien');

void main() {
  test(
    'une réponse de recherche de membre obsolète n\'écrase pas la liste de '
    'suggestions plus récente (risque de signer/payer pour le mauvais membre)',
    () async {
      final repo = _FakeSignatureRepository();
      final notifier = SignerNotifier(repo);
      addTearDown(notifier.dispose);

      notifier.searchMembers('Je');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.pending.length, 1);
      expect(repo.pending.single.query, 'Je');

      notifier.searchMembers('Jean');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.pending.length, 2);
      expect(repo.pending.last.query, 'Jean');

      // La réponse la plus récente ("Jean") arrive d'abord…
      repo.pending.last.completer.complete([_member(1, 'Jean Dupont')]);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.filteredMembers.map((m) => m.nom), ['Jean Dupont']);

      // …puis la réponse obsolète ("Je") arrive après coup.
      repo.pending.first.completer.complete([
        _member(2, 'Jeanne Petit'),
        _member(1, 'Jean Dupont'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.filteredMembers.map((m) => m.nom), ['Jean Dupont']);
    },
  );

  test(
    'searchMembers() debounce : une frappe rapide ne déclenche qu\'un seul '
    'appel réseau',
    () async {
      final repo = _FakeSignatureRepository();
      final notifier = SignerNotifier(repo);
      addTearDown(notifier.dispose);

      notifier.searchMembers('Je');
      notifier.searchMembers('Jea');
      notifier.searchMembers('Jean');

      await Future<void>.delayed(const Duration(milliseconds: 100));
      expect(repo.pending, isEmpty);

      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.pending.length, 1);
      expect(repo.pending.single.query, 'Jean');
    },
  );

  test(
    'initiateDistance() : un double-appel (double-tap trop rapide pour que '
    "le bouton n'ait eu le temps de se désactiver) ne déclenche qu'un seul "
    'paiement',
    () async {
      final repo = _FakeSignatureRepository();
      final notifier = SignerNotifier(repo);
      addTearDown(notifier.dispose);

      // Opérateur + numéro valides : requis depuis la suppression du
      // paiement par carte (mobile money uniquement désormais).
      notifier.setOperator('ORANGE MONEY');
      notifier.setPhone('699112233');

      final first = notifier.initiateDistance();
      final second = notifier.initiateDistance();

      expect(await second, isFalse);
      expect(repo.pendingPayments.length, 1);

      repo.pendingPayments.single.complete(
        const DistancePaymentInitResult(
          transactionId: 1,
          paymentReference: 'REF1',
          totalAmount: 1000,
        ),
      );
      expect(await first, isTrue);
    },
  );

  group('paiement par carte', () {
    const checkout = 'https://checkout.flutterwave.test/pay/sig123';

    SignerNotifier cardNotifier(_FakeSignatureRepository repo) {
      final notifier = SignerNotifier(repo);
      addTearDown(notifier.dispose);
      notifier.setPaymentMethod('card');
      notifier.setCardFeePercent(5);
      notifier.setAmount(1000);
      notifier.toggleMonth('2026-01');
      notifier.toggleMonth('2026-02');
      return notifier;
    }

    test('le total est majoré des frais de carte, à la charge du fidèle', () {
      final notifier = cardNotifier(_FakeSignatureRepository());

      expect(notifier.state.netAmount, 2000);
      expect(notifier.state.totalAmount, 2106); // 2000 / 0,95 = 2105,3 -> 2106
      expect(notifier.state.cardFees, 106);
    });

    test('Mobile Money garde ses frais fixes par mois (inchangé)', () {
      final notifier = cardNotifier(_FakeSignatureRepository());
      notifier.setPaymentMethod('mobile_money');

      expect(notifier.state.totalAmount, 2100); // (1000 + 50) x 2
      expect(notifier.state.cardFees, 106);
    });

    test('sans numéro ni opérateur : la carte part avec method=card', () async {
      final repo = _FakeSignatureRepository();
      final notifier = cardNotifier(repo);

      final future = notifier.initiateDistance();
      expect(repo.paymentRequests.single, {
        'amount': 1000,
        'paymentMethod': 'card',
        'paymentOperator': null,
        'phoneNumber': null,
      });

      repo.pendingPayments.single.complete(const DistancePaymentInitResult(
        transactionId: 7,
        paymentReference: 'SIGNME-SIG-1',
        totalAmount: 2106,
        checkoutUrl: checkout,
      ));
      expect(await future, isTrue);
      expect(notifier.state.checkoutUrl, checkout);
      expect(notifier.state.paymentStatus, 'completed');
    });

    test('sans page de paiement renvoyée : échec propre, rien à ouvrir', () async {
      final repo = _FakeSignatureRepository();
      final notifier = cardNotifier(repo);

      final future = notifier.initiateDistance();
      repo.pendingPayments.single.complete(const DistancePaymentInitResult(
        transactionId: 7,
        paymentReference: 'SIGNME-SIG-1',
        totalAmount: 2106,
      ));

      expect(await future, isFalse);
      expect(notifier.state.paymentStatus, 'failed');
      expect(notifier.state.checkoutUrl, isNull);
    });

    test('Mobile Money exige toujours un numéro valide', () async {
      final repo = _FakeSignatureRepository();
      final notifier = cardNotifier(repo);
      notifier.setPaymentMethod('mobile_money');
      notifier.setPhone('123');

      expect(await notifier.initiateDistance(), isFalse);
      expect(repo.paymentRequests, isEmpty);
      expect(notifier.state.error, 'Numéro invalide');
    });

    test('la réponse serveur est lue avec checkout_url', () {
      final init = DistancePaymentInitResult.fromJson({
        'transaction_id': 7,
        'payment_reference': 'SIGNME-SIG-1',
        'total_amount': 2106,
        'checkout_url': checkout,
      });
      final status = PaymentTransactionStatus.fromJson({
        'status': 'pending',
        'checkout_url': checkout,
      });

      expect(init.checkoutUrl, checkout);
      expect(status.checkoutUrl, checkout);
      expect(DistancePaymentInitResult.fromJson({'transaction_id': 1}).checkoutUrl, isNull);
    });
  });

  group('mois signables (jusqu\'au mois prochain)', () {
    test('le dernier mois signable est le mois prochain, avec le passage d\'année', () {
      expect(SignableMonths.last(DateTime(2026, 10, 15)), '2026-11');
      expect(SignableMonths.last(DateTime(2026, 12, 15)), '2027-01');
      expect(SignableMonths.last(DateTime(2026, 1, 31)), '2026-02'); // pas de débordement un 31
    });

    test('octobre : novembre oui, décembre non ; décembre : janvier oui, février non', () {
      final octobre = DateTime(2026, 10, 15);
      expect(SignableMonths.isSignable('2026-11', octobre), isTrue);
      expect(SignableMonths.isSignable('2026-12', octobre), isFalse);

      final decembre = DateTime(2026, 12, 15);
      expect(SignableMonths.isSignable('2027-01', decembre), isTrue);
      expect(SignableMonths.isSignable('2027-02', decembre), isFalse);
    });

    test('le mois courant et les mois passés restent signables', () {
      final now = DateTime(2026, 10, 15);
      expect(SignableMonths.isSignable('2026-10', now), isTrue);
      expect(SignableMonths.isSignable('2026-01', now), isTrue);
    });

    test('la sélection ignore un mois au-delà du mois prochain (distance et présentiel)', () {
      final notifier = SignerNotifier(_FakeSignatureRepository());
      addTearDown(notifier.dispose);
      final now = DateTime.now();
      final suivant = SignableMonths.last(now);
      final trop = DateTime(now.year, now.month + 2);
      final tropLoin = '${trop.year}-${trop.month.toString().padLeft(2, '0')}';

      notifier.toggleMonth(suivant);
      notifier.toggleMonth(tropLoin);
      expect(notifier.state.selectedMonths, [suivant]);

      notifier.reset();
      notifier.togglePresentielMonth(tropLoin);
      expect(notifier.state.selectedMonths, isEmpty);
      notifier.togglePresentielMonth(suivant);
      expect(notifier.state.selectedMonths, [suivant]);
    });
  });
}
