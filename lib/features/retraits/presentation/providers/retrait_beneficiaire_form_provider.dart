import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/retraits_remote_datasource.dart';
import '../../domain/entities/retrait_beneficiaire_entity.dart';
import 'retraits_provider.dart';

class RetraitBeneficiaireFormState {
  const RetraitBeneficiaireFormState({
    this.isLoading = false,
    this.error,
    this.result,
  });

  final bool isLoading;
  final String? error;
  final RetraitBeneficiaireEntity? result;

  bool get success => result != null;
}

class RetraitBeneficiaireFormNotifier extends StateNotifier<RetraitBeneficiaireFormState> {
  RetraitBeneficiaireFormNotifier(this._remote) : super(const RetraitBeneficiaireFormState());

  final RetraitsRemoteDataSource _remote;

  Future<void> enregistrer({required String operator, required String phone}) async {
    // Même garde de ré-entrance que RetraitFormNotifier.initier() : le
    // bouton se désactive au prochain frame seulement, un double-tap rapide
    // peut sinon créer un bénéficiaire en double.
    if (state.isLoading) return;
    state = const RetraitBeneficiaireFormState(isLoading: true);
    try {
      final beneficiaire = await _remote.storeBeneficiaire(operator: operator, phone: phone);
      state = RetraitBeneficiaireFormState(result: beneficiaire);
    } catch (e) {
      state = RetraitBeneficiaireFormState(error: e.toString());
    }
  }
}

final retraitBeneficiaireFormProvider =
    StateNotifierProvider.autoDispose<RetraitBeneficiaireFormNotifier, RetraitBeneficiaireFormState>(
  (ref) => RetraitBeneficiaireFormNotifier(ref.watch(retraitsRemoteDataSourceProvider)),
);
