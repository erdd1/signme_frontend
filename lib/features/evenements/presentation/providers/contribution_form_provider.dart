import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../domain/contribution_fee_calculator.dart';
import '../../domain/repositories/contribution_repository.dart';
import '../utils/contribution_status_poller.dart';

class ContributionFormState {
  const ContributionFormState({
    this.montant = 500,
    this.note = '',
    this.paymentMethod = 'mobile_money',
    this.operator_ = 'ORANGE MONEY',
    this.phone = '',
    this.isLoading = false,
    this.success = false,
    this.contributionUuid,
    this.authorizationUrl,
    this.paymentMessage,
    this.error,
    this.paymentStatus = 'idle',
    this.paymentProgress = 0.0,
    this.selectedGroupeId,
  });

  final int montant;
  final String note;
  final String paymentMethod; // mobile_money | card
  final String operator_;
  final String phone;
  final bool isLoading;
  final bool success;
  final String? contributionUuid;
  final String? authorizationUrl;
  final String? paymentMessage;
  final String? error;
  final String paymentStatus; // idle | processing | completed | failed
  final double paymentProgress;
  final int? selectedGroupeId;

  int? get frais => ContributionFeeCalculator.calculate(montant);
  int? get total {
    final f = frais;
    return f == null ? null : montant + f;
  }

  static bool isValidPhoneNumber(String phone, String operator_) {
    if (phone.length != 9) return false;
    if (operator_ == 'ORANGE MONEY') {
      return phone.startsWith('6') || phone.startsWith('2');
    } else if (operator_ == 'MTN MOBILE MONEY') {
      return phone.startsWith('6') || phone.startsWith('5');
    }
    return false;
  }

  ContributionFormState copyWith({
    int? montant,
    String? note,
    String? paymentMethod,
    String? operator_,
    String? phone,
    bool? isLoading,
    bool? success,
    String? contributionUuid,
    String? authorizationUrl,
    String? paymentMessage,
    String? error,
    String? paymentStatus,
    double? paymentProgress,
    bool clearError = false,
    int? selectedGroupeId,
    bool clearSelectedGroupeId = false,
    bool clearAuthorizationUrl = false,
  }) =>
      ContributionFormState(
        montant: montant ?? this.montant,
        note: note ?? this.note,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        operator_: operator_ ?? this.operator_,
        phone: phone ?? this.phone,
        isLoading: isLoading ?? this.isLoading,
        success: success ?? this.success,
        contributionUuid: contributionUuid ?? this.contributionUuid,
        authorizationUrl:
            clearAuthorizationUrl ? null : authorizationUrl ?? this.authorizationUrl,
        paymentMessage: paymentMessage ?? this.paymentMessage,
        error: clearError ? null : error ?? this.error,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        paymentProgress: paymentProgress ?? this.paymentProgress,
        selectedGroupeId:
            clearSelectedGroupeId ? null : selectedGroupeId ?? this.selectedGroupeId,
      );
}

class ContributionFormNotifier extends StateNotifier<ContributionFormState> {
  ContributionFormNotifier(this._repository) : super(const ContributionFormState());

  final ContributionRepository _repository;
  ContributionStatusPoller? _poller;

  void disposePoller() => _poller?.cancel();

  void setMontant(int montant) => state = state.copyWith(montant: montant, clearError: true);
  void setNote(String note) =>
      state = state.copyWith(note: note.length > 100 ? note.substring(0, 100) : note);
  void setOperator(String op) => state = state.copyWith(operator_: op, clearError: true);
  void setPhone(String phone) => state = state.copyWith(phone: phone, clearError: true);
  void setPaymentMethod(String method) =>
      state = state.copyWith(paymentMethod: method, clearError: true);
  void setGroupe(int? groupeId) => state = state.copyWith(
        selectedGroupeId: groupeId,
        clearSelectedGroupeId: groupeId == null,
        clearError: true,
      );

  /// [requiresGroupeSelection] : true si l'utilisateur appartient à plusieurs
  /// groupes — la sélection est alors obligatoire (avec un seul groupe, le
  /// serveur le déduit automatiquement, aucune sélection nécessaire ici).
  Future<bool> effectuerPaiement(
    String evenementUuid, {
    bool requiresGroupeSelection = false,
  }) async {
    // Le bouton se désactive via `isLoading`, mais seulement au prochain
    // frame — un double-tap très rapide peut encore atteindre ce callback
    // avant que ce rendu n'ait eu lieu. Garde de ré-entrance ici, à la
    // source, plutôt que de compter uniquement sur l'UI : un paiement
    // dupliqué n'est pas une simple gêne visuelle.
    if (state.isLoading) return false;

    final isCard = state.paymentMethod == 'card';

    if (ContributionFeeCalculator.calculate(state.montant) == null) {
      state = state.copyWith(error: 'Montant invalide.');
      return false;
    }
    if (!isCard && !ContributionFormState.isValidPhoneNumber(state.phone, state.operator_)) {
      state = state.copyWith(error: 'Numéro invalide.');
      return false;
    }
    if (requiresGroupeSelection && state.selectedGroupeId == null) {
      state = state.copyWith(error: 'Veuillez sélectionner votre groupe pour cette contribution.');
      return false;
    }

    _poller?.cancel();
    _poller = ContributionStatusPoller(_repository);

    state = state.copyWith(
      isLoading: true,
      success: true,
      paymentStatus: 'processing',
      paymentProgress: 0.15,
      clearError: true,
      clearAuthorizationUrl: true,
    );

    try {
      final contribution = await _repository.initiate(
        evenementUuid: evenementUuid,
        montant: state.montant,
        note: state.note.isEmpty ? null : state.note,
        paymentMethod: state.paymentMethod,
        paymentOperator: isCard ? null : state.operator_,
        paymentNumber: isCard ? null : state.phone,
        groupeId: state.selectedGroupeId,
      );

      state = state.copyWith(
        isLoading: false,
        contributionUuid: contribution.uuid,
        authorizationUrl: contribution.authorizationUrl,
        paymentMessage: isCard
            ? 'Complétez votre paiement par carte.'
            : 'Validez le paiement sur votre téléphone (${state.operator_}).',
        paymentProgress: 0.3,
        paymentStatus: 'processing',
      );

      // Paiement carte : la WebView doit s'ouvrir avant de démarrer le
      // polling (l'écran appelle pollAfterCardCheckout() une fois fermée).
      if (contribution.authorizationUrl != null && contribution.authorizationUrl!.isNotEmpty) {
        return true;
      }

      return await _pollUntilTerminal(contribution.uuid);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: messageFromError(e),
        paymentStatus: 'failed',
        paymentProgress: 0,
      );
      return false;
    }
  }

  /// À appeler après la fermeture de la WebView de paiement carte, pour
  /// démarrer le polling de confirmation (même mécanique que mobile money).
  Future<bool> pollAfterCardCheckout() async {
    if (state.contributionUuid == null) return false;
    return _pollUntilTerminal(state.contributionUuid!);
  }

  Future<bool> _pollUntilTerminal(String contributionUuid) async {
    try {
      final finalStatus = await _poller!.pollUntilTerminal(
        contributionUuid: contributionUuid,
        onUpdate: (status) {
          state = state.copyWith(
            paymentStatus: status.statut,
            paymentProgress: status.progress.clamp(0.0, 0.99),
            paymentMessage:
                status.isPending ? 'En attente de confirmation du paiement…' : state.paymentMessage,
          );
        },
      );

      if (finalStatus.isCompleted) {
        state = state.copyWith(
          paymentStatus: 'completed',
          paymentProgress: 1.0,
          paymentMessage: 'Paiement confirmé. Merci pour votre contribution !',
        );
        return true;
      }

      if (finalStatus.isFailed) {
        state = state.copyWith(
          paymentStatus: 'failed',
          paymentProgress: 0,
          error: 'Le paiement a été refusé ou a expiré.',
        );
        return false;
      }

      state = state.copyWith(
        paymentStatus: 'processing',
        paymentProgress: 0.7,
        paymentMessage: 'Paiement en cours. La confirmation peut prendre quelques instants.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: messageFromError(e),
        paymentStatus: 'failed',
        paymentProgress: 0,
      );
      return false;
    }
  }

  void reset() {
    disposePoller();
    state = const ContributionFormState();
  }
}

final contributionFormProvider = StateNotifierProvider.autoDispose<ContributionFormNotifier, ContributionFormState>(
  (ref) {
    final notifier = ContributionFormNotifier(ref.watch(contributionRepositoryProvider));
    ref.onDispose(notifier.disposePoller);
    return notifier;
  },
);
