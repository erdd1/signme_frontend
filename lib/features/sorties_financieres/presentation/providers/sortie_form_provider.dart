import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/sorties_remote_datasource.dart';
import 'sorties_financieres_provider.dart';

class SortieFormState {
  const SortieFormState({
    this.isLoading = false,
    this.error,
    this.success = false,
  });

  final bool isLoading;
  final String? error;
  final bool success;
}

class SortieFormNotifier extends StateNotifier<SortieFormState> {
  SortieFormNotifier(this._remote) : super(const SortieFormState());

  final SortiesRemoteDataSource _remote;

  // Chaque méthode ci-dessous est déclenchée par un bouton qui se désactive
  // via `isLoading`, mais seulement au prochain frame — un double-tap très
  // rapide peut encore appeler la méthode deux fois avant ce rendu. Garde de
  // ré-entrance à la source dans chacune : une sortie financière dupliquée
  // (ou une suppression en double) est un vrai mouvement d'argent, pas une
  // simple gêne visuelle.

  Future<void> createSimple({required int montant, required String description, String? reference}) async {
    if (state.isLoading) return;
    state = const SortieFormState(isLoading: true);
    try {
      await _remote.createSimple({
        'montant': montant,
        'description': description,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
      });
      state = const SortieFormState(success: true);
    } catch (e) {
      state = SortieFormState(error: e.toString());
    }
  }

  Future<void> createFrais({required int montant, required String description, String? reference}) async {
    if (state.isLoading) return;
    state = const SortieFormState(isLoading: true);
    try {
      await _remote.createFrais({
        'montant': montant,
        'description': description,
        if (reference != null && reference.isNotEmpty) 'reference': reference,
      });
      state = const SortieFormState(success: true);
    } catch (e) {
      state = SortieFormState(error: e.toString());
    }
  }

  Future<void> update(String uuid, {int? montant, String? description, String? reference}) async {
    if (state.isLoading) return;
    state = const SortieFormState(isLoading: true);
    try {
      await _remote.update(uuid, {
        if (montant != null) 'montant': montant,
        if (description != null) 'description': description,
        if (reference != null) 'reference': reference,
      });
      state = const SortieFormState(success: true);
    } catch (e) {
      state = SortieFormState(error: e.toString());
    }
  }

  Future<void> delete(String uuid) async {
    if (state.isLoading) return;
    state = const SortieFormState(isLoading: true);
    try {
      await _remote.delete(uuid);
      state = const SortieFormState(success: true);
    } catch (e) {
      state = SortieFormState(error: e.toString());
    }
  }
}

final sortieFormProvider = StateNotifierProvider.autoDispose<SortieFormNotifier, SortieFormState>(
  (ref) => SortieFormNotifier(ref.watch(sortiesRemoteDataSourceProvider)),
);
