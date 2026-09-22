import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/auth/data/models/user_model.dart';
import 'package:signme/features/users/data/datasources/users_remote_datasource.dart';
import 'package:signme/features/users/presentation/providers/users_provider.dart';

class _PendingCall {
  _PendingCall({required this.search, required this.completer});
  final String? search;
  final Completer<List<UserModel>> completer;
}

/// Ne touche jamais au réseau : chaque appel à [list] est mis en attente
/// dans [pending] et résolu manuellement par le test, dans l'ordre voulu —
/// ce qui permet de simuler une réponse lente arrivant APRÈS une réponse
/// plus récente, exactement le scénario du bug corrigé.
class _FakeUsersRemoteDataSource extends UsersRemoteDataSource {
  _FakeUsersRemoteDataSource() : super(Dio());

  final List<_PendingCall> pending = [];

  @override
  Future<List<UserModel>> list({
    int page = 1,
    Map<String, dynamic>? filters,
  }) {
    final completer = Completer<List<UserModel>>();
    pending.add(
      _PendingCall(search: filters?['search'] as String?, completer: completer),
    );
    return completer.future;
  }
}

UserModel _user(int id, String nom) =>
    UserModel(id: id, nom: nom, email: '$nom@test.com', role: 'paroissien');

void main() {
  test(
    'une réponse de recherche obsolète (arrivée en retard) n\'écrase pas '
    'des résultats plus récents',
    () async {
      final remote = _FakeUsersRemoteDataSource();
      final notifier = UsersListNotifier(remote);
      addTearDown(notifier.dispose);

      // Résout le chargement initial déclenché par le constructeur.
      remote.pending.single.completer.complete([]);
      await Future<void>.delayed(Duration.zero);

      notifier.search('J');
      // Laisse le debounce (350ms) déclencher l'appel réseau pour "J".
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(remote.pending.length, 2);
      expect(remote.pending.last.search, 'J');

      notifier.search('Jean');
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(remote.pending.length, 3);
      expect(remote.pending.last.search, 'Jean');

      // La réponse "Jean" (la plus récente) arrive D'ABORD…
      remote.pending.last.completer.complete([_user(1, 'Jean Dupont')]);
      await Future<void>.delayed(Duration.zero);
      expect(notifier.state.users.map((u) => u.nom), ['Jean Dupont']);

      // …puis la réponse "J" (obsolète) arrive APRÈS coup — sans la garde,
      // elle écraserait l'état avec des résultats qui ne correspondent plus
      // à ce que l'utilisateur a tapé.
      remote.pending[1].completer.complete([
        _user(2, 'Jacques Martin'),
        _user(1, 'Jean Dupont'),
      ]);
      await Future<void>.delayed(Duration.zero);

      expect(notifier.state.users.map((u) => u.nom), ['Jean Dupont']);
      expect(notifier.state.searchQuery, 'Jean');
    },
  );

  test('search() debounce : une frappe rapide ne déclenche qu\'un seul appel réseau', () async {
    final remote = _FakeUsersRemoteDataSource();
    final notifier = UsersListNotifier(remote);
    addTearDown(notifier.dispose);

    remote.pending.single.completer.complete([]);
    await Future<void>.delayed(Duration.zero);

    notifier.search('J');
    notifier.search('Je');
    notifier.search('Jea');
    notifier.search('Jean');

    // Bien avant les 350ms de debounce : aucun nouvel appel réseau encore.
    await Future<void>.delayed(const Duration(milliseconds: 100));
    expect(remote.pending.length, 1);

    await Future<void>.delayed(const Duration(milliseconds: 400));
    expect(remote.pending.length, 2);
    expect(remote.pending.last.search, 'Jean');
  });
}
