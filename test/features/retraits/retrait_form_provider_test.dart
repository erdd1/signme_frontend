import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:signme/features/retraits/data/datasources/retraits_remote_datasource.dart';
import 'package:signme/features/retraits/domain/entities/retrait_entity.dart';
import 'package:signme/features/retraits/presentation/providers/retrait_form_provider.dart';

/// Ne touche jamais au réseau : [initiateRetrait] est mis en attente dans
/// [pending] et résolu manuellement par le test.
class _FakeRetraitsRemoteDataSource extends RetraitsRemoteDataSource {
  _FakeRetraitsRemoteDataSource() : super(Dio());

  final List<Completer<RetraitEntity>> pending = [];

  @override
  Future<RetraitEntity> initiateRetrait(int montant) {
    final completer = Completer<RetraitEntity>();
    pending.add(completer);
    return completer.future;
  }
}

void main() {
  test(
    'initier() : un double-appel (double-tap trop rapide pour que le bouton '
    "n'ait eu le temps de disparaître) ne déclenche qu'un seul retrait — un "
    'retrait dupliqué est un vrai transfert d\'argent',
    () async {
      final remote = _FakeRetraitsRemoteDataSource();
      final notifier = RetraitFormNotifier(remote);
      addTearDown(notifier.dispose);

      final first = notifier.initier(50000);
      final second = notifier.initier(50000);

      await second;
      expect(remote.pending.length, 1);
      expect(notifier.state.isLoading, isTrue);

      remote.pending.single.complete(
        const RetraitEntity(
          uuid: 'retrait-1',
          montantDemande: 50000,
          frais: 0,
          montantNet: 50000,
          statut: 'pending',
          reference: 'REF-1',
          auteurNom: 'Trésorier',
          createdAt: '2026-01-01T00:00:00Z',
        ),
      );
      await first;

      expect(notifier.state.success, isTrue);
      expect(notifier.state.result?.uuid, 'retrait-1');
    },
  );
}
