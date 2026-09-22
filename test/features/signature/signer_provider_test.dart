import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/auth/domain/entities/user_entity.dart';
import 'package:signme/features/signature/domain/entities/member_signature_status.dart';
import 'package:signme/features/signature/domain/entities/payment_transaction_status.dart';
import 'package:signme/features/signature/domain/entities/signature_entity.dart';
import 'package:signme/features/signature/domain/repositories/signature_repository.dart';
import 'package:signme/features/signature/presentation/providers/signer_provider.dart';

class _PendingSearch {
  _PendingSearch({required this.query, required this.completer});
  final String query;
  final Completer<List<UserEntity>> completer;
}

/// Fake ciblé : seule [searchMembers] est exercée par ce test, les autres
/// méthodes de l'interface ne sont jamais appelées par [SignerNotifier] dans
/// ces scénarios (recherche de membre uniquement).
class _FakeSignatureRepository implements SignatureRepository {
  final List<_PendingSearch> pending = [];
  final List<Completer<DistancePaymentInitResult>> pendingPayments = [];

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
    final completer = Completer<DistancePaymentInitResult>();
    pendingPayments.add(completer);
    return completer.future;
  }

  @override
  Future<PaymentTransactionStatus> getTransactionStatus(int transactionId) =>
      throw UnimplementedError();

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

      notifier.setPaymentMethod('card'); // évite la validation du numéro

      final first = notifier.initiateDistance();
      final second = notifier.initiateDistance();

      expect(await second, isFalse);
      expect(repo.pendingPayments.length, 1);

      repo.pendingPayments.single.complete(
        const DistancePaymentInitResult(
          transactionId: 1,
          paymentReference: 'REF1',
          totalAmount: 1000,
          authorizationUrl: 'https://pay.example/checkout',
        ),
      );
      expect(await first, isTrue);
    },
  );
}
