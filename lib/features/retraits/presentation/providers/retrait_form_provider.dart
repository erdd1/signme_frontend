import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/retraits_remote_datasource.dart';
import '../../domain/entities/retrait_entity.dart';
import 'retraits_provider.dart';

class RetraitFormState {
  const RetraitFormState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  final bool isLoading;
  final String? error;
  final RetraitEntity? result;

  bool get success => result != null;
}

class RetraitFormNotifier extends StateNotifier<RetraitFormState> {
  RetraitFormNotifier(this._remote) : super(const RetraitFormState());

  final RetraitsRemoteDataSource _remote;

  Future<void> initier(int montant) async {
    // Le bouton "Confirmer le retrait" n'est pas désactivé via `isLoading`
    // (il disparaît au changement d'étape, mais seulement au prochain
    // frame) — un double-tap très rapide peut encore appeler cette méthode
    // deux fois avant ce rendu. Garde de ré-entrance ici, à la source :
    // un retrait dupliqué est un vrai transfert d'argent, pas une simple
    // gêne visuelle.
    if (state.isLoading) return;

    state = const RetraitFormState(isLoading: true);
    try {
      final retrait = await _remote.initiateRetrait(montant);
      state = RetraitFormState(result: retrait);
    } catch (e) {
      state = RetraitFormState(error: e.toString());
    }
  }
}

final retraitFormProvider = StateNotifierProvider.autoDispose<RetraitFormNotifier, RetraitFormState>(
  (ref) => RetraitFormNotifier(ref.watch(retraitsRemoteDataSourceProvider)),
);
