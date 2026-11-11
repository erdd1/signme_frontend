import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:signme/features/transactions/presentation/providers/transactions_provider.dart';

class _FakeRemote extends TransactionsRemoteDataSource {
  _FakeRemote() : super(Dio());

  int count = 0;
  bool fail = false;
  int nonLuesCalls = 0;
  int marquerLuesCalls = 0;

  @override
  Future<int> nonLues() async {
    nonLuesCalls++;
    if (fail) throw Exception('hors ligne');
    return count;
  }

  @override
  Future<void> marquerLues() async {
    marquerLuesCalls++;
    if (fail) throw Exception('hors ligne');
  }
}

void main() {
  test('charge le nombre de nouvelles transactions à la création', () async {
    final remote = _FakeRemote()..count = 3;
    final notifier = TransactionsBadgeNotifier(remote, authenticated: true);
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, 3);
  });

  test('déconnecté : aucun appel réseau, aucun badge', () async {
    final remote = _FakeRemote()..count = 3;
    final notifier = TransactionsBadgeNotifier(remote, authenticated: false);
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);

    expect(notifier.state, 0);
    expect(remote.nonLuesCalls, 0);
  });

  test('ouvrir Services remet le badge à zéro tout de suite, puis prévient le serveur', () async {
    final remote = _FakeRemote()..count = 2;
    final notifier = TransactionsBadgeNotifier(remote, authenticated: true);
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);

    final fini = notifier.markRead();
    expect(notifier.state, 0); // optimiste : pas d'attente du réseau
    await fini;

    expect(remote.marquerLuesCalls, 1);
  });

  test('sans nouveauté, markRead ne fait aucun appel', () async {
    final remote = _FakeRemote();
    final notifier = TransactionsBadgeNotifier(remote, authenticated: true);
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);

    await notifier.markRead();

    expect(remote.marquerLuesCalls, 0);
  });

  test('une panne réseau garde le badge affiché (le sondage suivant corrige)', () async {
    final remote = _FakeRemote()..count = 4;
    final notifier = TransactionsBadgeNotifier(remote, authenticated: true);
    addTearDown(notifier.dispose);
    await Future<void>.delayed(Duration.zero);
    expect(notifier.state, 4);

    remote.fail = true;
    await notifier.refresh();

    expect(notifier.state, 4);
  });
}
