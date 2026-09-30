import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../domain/entities/member_signature_status.dart';
import '../../domain/repositories/signature_repository.dart';
import '../utils/payment_status_poller.dart';

// ── État Signer ───────────────────────────────────────────────────────────────
class SignerState {
  const SignerState({
    this.selectedMonths = const [],
    this.selectedYear = 2026,
    this.operator_       = 'ORANGE MONEY',
    this.phone           = '',
    this.isLoading       = false,
    this.success         = false,
    this.paymentRef,
    this.transactionId,
    this.paymentMessage,
    this.error,
    this.amountPerMonth  = 1000,
    this.feesPerMonth    = 50,
    this.signatureDate,
    this.alreadySignedMonths = const [],
    this.paymentStatus   = 'idle',
    this.paymentProgress = 0.0,
    this.selectedUserId,
    this.selectedUserNom = '',
    this.members         = const [],
    this.isLoadingMembers = false,
    this.memberSearchQuery = '',
    this.filteredMembers = const [],
    this.memberStatus,
    this.isLoadingMemberStatus = false,
    this.successType = '',
    this.canSignPresentielNow = true,
    this.isCheckingPresentielAvailability = false,
    this.memberSignedMonths = const [],
    this.isLoadingMemberSignedMonths = false,
  });

  final List<String> selectedMonths;
  final int     selectedYear;
  final String  operator_;
  final String  phone;
  final bool    isLoading;
  final bool    success;
  final String? paymentRef;
  final int? transactionId;
  final String? paymentMessage;
  final String? error;
  final int     amountPerMonth;
  final int     feesPerMonth;
  final DateTime? signatureDate;
  final List<String> alreadySignedMonths;
  final String  paymentStatus;
  final double  paymentProgress;
  final int?    selectedUserId;
  final String  selectedUserNom;
  final List<UserEntity> members;
  final bool    isLoadingMembers;
  final String  memberSearchQuery;
  final List<UserEntity> filteredMembers;
  final MemberSignatureStatus? memberStatus;
  final bool    isLoadingMemberStatus;
  final String  successType;
  final bool    canSignPresentielNow;
  final bool    isCheckingPresentielAvailability;

  /// Mois déjà signés par le membre SÉLECTIONNÉ pour [selectedYear], en
  /// présentiel — distinct de [alreadySignedMonths] qui reflète les mois
  /// déjà signés par l'utilisateur connecté lui-même (formulaire à distance).
  final List<String> memberSignedMonths;
  final bool isLoadingMemberSignedMonths;

  static const List<int> ALLOWED_AMOUNTS = [15, 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 10000];

  static int calculateFees(int amount) {
    if (amount >= 15 && amount < 500) return 5;
    if (amount >= 500 && amount <= 1000) return 50;
    if (amount >= 1500 && amount <= 4500) return 100;
    if (amount >= 5000 && amount <= 9500) return 150;
    if (amount >= 10000) return 200;
    return 0;
  }

  // Le plan de numérotation camerounais actuel n'a plus que des numéros
  // mobiles commençant par 6, quel que soit l'opérateur — et c'est aussi le
  // SEUL préfixe accepté par le backend (NotchPayGateway::formatPhoneNumber).
  // Accepter '2'/'5' ici laissait passer des numéros que le paiement
  // rejetait ensuite avec une erreur serveur générique non explicite.
  static bool isValidPhoneNumber(String phone, String operator_) {
    if (phone.length != 9) return false;
    if (operator_ == 'ORANGE MONEY' || operator_ == 'MTN MOBILE MONEY') {
      return phone.startsWith('6');
    }
    return false;
  }

  int get totalAmount => (amountPerMonth + feesPerMonth) * selectedMonths.length;

  SignerState copyWith({
    List<String>? selectedMonths,
    int? selectedYear,
    String? operator_, String? phone, bool? isLoading, bool? success,
    String? paymentRef,
    int? transactionId,
    String? paymentMessage,
    String? error,
    int? amountPerMonth,
    int? feesPerMonth,
    DateTime? signatureDate,
    List<String>? alreadySignedMonths,
    String? paymentStatus,
    double? paymentProgress,
    int? selectedUserId, String? selectedUserNom,
    List<UserEntity>? members, bool? isLoadingMembers,
    String? memberSearchQuery,
    List<UserEntity>? filteredMembers,
    MemberSignatureStatus? memberStatus,
    bool? isLoadingMemberStatus,
    String? successType,
    bool? canSignPresentielNow,
    bool? isCheckingPresentielAvailability,
    List<String>? memberSignedMonths,
    bool? isLoadingMemberSignedMonths,
    bool clearError = false,
    bool clearUser = false,
  }) => SignerState(
    selectedMonths:       selectedMonths       ?? this.selectedMonths,
    selectedYear:         selectedYear         ?? this.selectedYear,
    operator_:            operator_            ?? this.operator_,
    phone:                phone                ?? this.phone,
    isLoading:            isLoading            ?? this.isLoading,
    success:              success              ?? this.success,
    paymentRef:           paymentRef           ?? this.paymentRef,
    transactionId:        transactionId        ?? this.transactionId,
    paymentMessage:       paymentMessage       ?? this.paymentMessage,
    error:                clearError ? null : error ?? this.error,
    amountPerMonth:       amountPerMonth       ?? this.amountPerMonth,
    feesPerMonth:         feesPerMonth         ?? this.feesPerMonth,
    signatureDate:        signatureDate        ?? this.signatureDate,
    alreadySignedMonths:  alreadySignedMonths  ?? this.alreadySignedMonths,
    paymentStatus:        paymentStatus        ?? this.paymentStatus,
    paymentProgress:      paymentProgress      ?? this.paymentProgress,
    selectedUserId:       clearUser ? null : selectedUserId ?? this.selectedUserId,
    selectedUserNom:      clearUser ? '' : selectedUserNom ?? this.selectedUserNom,
    members:              members              ?? this.members,
    isLoadingMembers:     isLoadingMembers     ?? this.isLoadingMembers,
    memberSearchQuery:    memberSearchQuery    ?? this.memberSearchQuery,
    filteredMembers:      filteredMembers      ?? this.filteredMembers,
    memberStatus:         memberStatus         ?? this.memberStatus,
    isLoadingMemberStatus: isLoadingMemberStatus ?? this.isLoadingMemberStatus,
    successType:          successType          ?? this.successType,
    canSignPresentielNow: canSignPresentielNow ?? this.canSignPresentielNow,
    isCheckingPresentielAvailability: isCheckingPresentielAvailability ?? this.isCheckingPresentielAvailability,
    memberSignedMonths:   memberSignedMonths   ?? this.memberSignedMonths,
    isLoadingMemberSignedMonths: isLoadingMemberSignedMonths ?? this.isLoadingMemberSignedMonths,
  );
}

// ── Signer Notifier ──────────────────────────────────────────────────────────
class SignerNotifier extends StateNotifier<SignerState> {
  SignerNotifier(this._repository) : super(SignerState(
    signatureDate: DateTime.now(),
  ));
  
  final SignatureRepository _repository;
  PaymentStatusPoller? _paymentPoller;
  Timer? _memberSearchDebounce;

  /// Incrémenté à chaque recherche serveur lancée — permet d'ignorer la
  /// réponse d'une requête devenue obsolète (l'utilisateur a tapé un
  /// caractère de plus avant qu'elle ne revienne) au lieu de l'appliquer.
  /// Sans cette garde, une réponse lente pour "Je" arrivant après la réponse
  /// rapide pour "Jean" écraserait la liste de suggestions avec un membre
  /// qui ne correspond plus à la recherche en cours — critique ici puisque
  /// cette liste sert à choisir QUI signe/paie.
  int _memberSearchRequestId = 0;

  static final provider = StateNotifierProvider.autoDispose<SignerNotifier, SignerState>((ref) {
    final notifier = SignerNotifier(ref.watch(signatureRepositoryProvider));
    ref.onDispose(notifier.disposePoller);
    return notifier;
  });

  void disposePoller() => _paymentPoller?.cancel();

  @override
  void dispose() {
    _memberSearchDebounce?.cancel();
    super.dispose();
  }

  void toggleMonth(String month) {
    final list = List<String>.from(state.selectedMonths);
    if (state.alreadySignedMonths.contains(month)) return;
    list.contains(month) ? list.remove(month) : list.add(month);
    state = state.copyWith(selectedMonths: list);
  }

  /// Même logique que [toggleMonth], mais contre [SignerState.memberSignedMonths]
  /// (le membre sélectionné en présentiel) plutôt que [SignerState.alreadySignedMonths]
  /// (l'utilisateur connecté lui-même, formulaire à distance).
  void togglePresentielMonth(String month) {
    final list = List<String>.from(state.selectedMonths);
    if (state.memberSignedMonths.contains(month)) return;
    list.contains(month) ? list.remove(month) : list.add(month);
    state = state.copyWith(selectedMonths: list);
  }

  void setYear(int year) => state = state.copyWith(selectedYear: year, selectedMonths: []);

  void setAmount(int amount) {
    final fees = SignerState.calculateFees(amount);
    state = state.copyWith(amountPerMonth: amount, feesPerMonth: fees);
  }

  void setOperator(String op) => state = state.copyWith(operator_: op, clearError: true);
  void setPhone(String v) => state = state.copyWith(phone: v, clearError: true);

  void selectUser(int? id, String nom) {
    if (id == null || id == 0) {
      state = state.copyWith(
        clearUser: true,
        memberSearchQuery: '',
        filteredMembers: state.members,
        memberSignedMonths: const [],
      );
      return;
    }
    state = state.copyWith(
      selectedUserId: id,
      selectedUserNom: nom,
      memberSearchQuery: '',
      clearError: true,
      filteredMembers: [],
      // Un membre différent : le statut de signature affiché ne doit jamais
      // rester celui du précédent le temps du rechargement.
      memberSignedMonths: const [],
    );
    _fetchMemberStatus(id);
  }

  /// Statut de signature du membre sélectionné pour chaque mois de [year] —
  /// alimente le repère "Signé"/"Non signé" de la grille de mois en
  /// présentiel (étape 2). Un appel par mois (l'API existante n'expose que
  /// le statut d'UN mois à la fois), lancés en parallèle.
  Future<void> loadMemberSignedMonths(int userId, int year) async {
    state = state.copyWith(isLoadingMemberSignedMonths: true, memberSignedMonths: const []);
    try {
      final entries = await Future.wait(List.generate(12, (i) async {
        final month = '$year-${(i + 1).toString().padLeft(2, '0')}';
        final status = await _repository.getMemberStatus(userId, month);
        return MapEntry(month, status?.isSigned ?? false);
      }));
      final signed = entries.where((e) => e.value).map((e) => e.key).toList();
      state = state.copyWith(memberSignedMonths: signed, isLoadingMemberSignedMonths: false);
    } catch (e) {
      // Non bloquant : la grille retombe simplement sur "aucun mois signé
      // connu" — le backend refuse de toute façon une signature en doublon.
      AppLogger.error('Échec du chargement des mois déjà signés du membre', e);
      state = state.copyWith(isLoadingMemberSignedMonths: false);
    }
  }

  Future<void> _fetchMemberStatus(int userId) async {
    state = state.copyWith(isLoadingMemberStatus: true);
    final now = DateTime.now();
    final monthParam = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final status = await _repository.getMemberStatus(userId, monthParam);
    state = state.copyWith(memberStatus: status, isLoadingMemberStatus: false);
  }

  void updateMemberSearch(String query) {
    state = state.copyWith(memberSearchQuery: query);
    if (query.isEmpty) {
      state = state.copyWith(filteredMembers: state.members);
      return;
    }
    final q = query.toLowerCase();
    state = state.copyWith(filteredMembers: state.members.where((m) =>
        m.nom.toLowerCase().contains(q) ||
        (m.matricule?.toLowerCase().contains(q) ?? false)).toList());
  }

  /// Recherche serveur debouncée (350 ms) : évite de spammer l'API à chaque
  /// frappe et, combiné à [_memberSearchRequestId], ignore toute réponse
  /// devenue obsolète — voir le commentaire sur ce champ.
  void searchMembers(String query) {
    if (query.trim().length < 2) return;
    _memberSearchDebounce?.cancel();
    _memberSearchDebounce = Timer(
      const Duration(milliseconds: 350),
      () => _performMemberSearch(query),
    );
  }

  Future<void> _performMemberSearch(String query) async {
    final requestId = ++_memberSearchRequestId;
    state = state.copyWith(isLoadingMembers: true);
    try {
      final results = await _repository.searchMembers(query);
      if (requestId != _memberSearchRequestId) return;
      state = state.copyWith(filteredMembers: results, isLoadingMembers: false);
    } catch (e) {
      if (requestId != _memberSearchRequestId) return;
      state = state.copyWith(isLoadingMembers: false);
    }
  }

  Future<void> loadMembers(UserEntity user) async {
    state = state.copyWith(isLoadingMembers: true);
    try {
      // Pour pasteur et ancien de service, appeler getPasteurMembers()
      if (user.isPasteur || (user.isAncien && user.estDeService)) {
        final results = await _repository.getPasteurMembers();
        state = state.copyWith(members: results, filteredMembers: results, isLoadingMembers: false);
      } else {
        state = state.copyWith(isLoadingMembers: false);
      }
    } catch (_) {
      state = state.copyWith(isLoadingMembers: false);
    }
  }

  Future<void> loadAlreadySignedMonths(int userId, int year) async {
    try {
      final data = await _repository.getMaCarte(year);
      final signed = data.signaturesParMois.entries
          .where((e) => e.value != null)
          .map((e) => '$year-${(int.tryParse(e.key) ?? 0) + 1}'.padLeft(7, '0'))
          .toList();
      state = state.copyWith(alreadySignedMonths: signed);
    } catch (e) {
      // Échec non bloquant : le backend refuse de toute façon une signature
      // en doublon. Journalisé pour ne pas masquer un vrai problème réseau.
      AppLogger.error('Échec du chargement des mois déjà signés', e);
    }
  }

  Future<bool> initiateDistance() async {
    // Le bouton se désactive via `isLoading`, mais seulement au prochain
    // frame — un double-tap très rapide peut encore atteindre ce callback
    // avant que ce rendu n'ait eu lieu. Garde de ré-entrance ici, à la
    // source, plutôt que de compter uniquement sur l'UI : un paiement
    // dupliqué n'est pas une simple gêne visuelle.
    if (state.isLoading) return false;

    if (!SignerState.isValidPhoneNumber(state.phone, state.operator_)) {
      state = state.copyWith(error: 'Numéro invalide');
      return false;
    }

    _paymentPoller?.cancel();
    _paymentPoller = PaymentStatusPoller(_repository);

    state = state.copyWith(
      isLoading: true,
      paymentStatus: 'processing',
      paymentProgress: 0.15,
      success: true,
      successType: 'distance',
      clearError: true,
    );

    try {
      final init = await _repository.initiateDistancePayment(
        months: state.selectedMonths,
        amount: state.amountPerMonth,
        paymentMethod: 'mobile_money',
        paymentOperator: state.operator_,
        phoneNumber: state.phone,
      );

      state = state.copyWith(
        isLoading: false,
        paymentRef: init.paymentReference,
        transactionId: init.transactionId,
        paymentMessage: init.message ?? 'Validez le paiement sur votre téléphone (${state.operator_}).',
        paymentProgress: 0.3,
        paymentStatus: 'processing',
      );

      return await _pollUntilTerminal();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        success: true,
        error: messageFromError(e),
        paymentStatus: 'failed',
        paymentProgress: 0,
      );
      return false;
    }
  }

  Future<bool> _pollUntilTerminal() async {
    try {
      final finalStatus = await _paymentPoller!.pollUntilTerminal(
        transactionId: state.transactionId!,
        onUpdate: (status) {
          state = state.copyWith(
            paymentStatus: status.status,
            paymentProgress: status.progress.clamp(0.0, 0.99),
            paymentMessage: status.isPending
                ? 'En attente de confirmation du paiement…'
                : state.paymentMessage,
          );
        },
      );

      if (finalStatus.isCompleted) {
        state = state.copyWith(
          paymentStatus: 'completed',
          paymentProgress: 1.0,
          paymentMessage: 'Paiement confirmé. Signature enregistrée.',
        );
        return true;
      }

      if (finalStatus.isFailed) {
        state = state.copyWith(
          success: true,
          paymentStatus: 'failed',
          paymentProgress: 0,
          error: 'Le paiement a été refusé ou a expiré.',
        );
        return false;
      }

      state = state.copyWith(
        success: true,
        paymentStatus: 'processing',
        paymentProgress: 0.7,
        paymentMessage:
            'Paiement en cours. Si vous avez validé le paiement, '
            'la confirmation peut prendre quelques instants.',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        success: true,
        error: messageFromError(e),
        paymentStatus: 'failed',
        paymentProgress: 0,
      );
      return false;
    }
  }

  Future<bool> initiatePresentiel() async {
    // Même garde de ré-entrance qu'initiateDistance() ci-dessus.
    if (state.isLoading) return false;
    if (state.selectedUserId == null || state.selectedMonths.isEmpty) return false;
    state = state.copyWith(isLoading: true);
    try {
      final success = await _repository.initiatePresentielSignature(
        userId: state.selectedUserId!,
        months: state.selectedMonths,
        amount: state.amountPerMonth,
      );
      if (success) {
        state = state.copyWith(isLoading: false, success: true, successType: 'presentiel');
        return true;
      }
      state = state.copyWith(isLoading: false, error: 'Erreur serveur');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: messageFromError(e));
      return false;
    }
  }

  Future<void> checkPresentielAvailability() async {
    state = state.copyWith(isCheckingPresentielAvailability: true);
    try {
      final result = await _repository.canSignPresentielNow();
      if (result != null) {
        final canSign = result['can_sign'] as bool? ?? false;
        state = state.copyWith(
          canSignPresentielNow: canSign,
          isCheckingPresentielAvailability: false,
        );
      } else {
        state = state.copyWith(isCheckingPresentielAvailability: false);
      }
    } catch (_) {
      state = state.copyWith(isCheckingPresentielAvailability: false);
    }
  }

  void reset() {
    disposePoller();
    state = SignerState(signatureDate: DateTime.now());
  }

  /// À appeler par l'écran une fois l'erreur affichée (snackbar), pour ne
  /// pas la réafficher lors d'une reconstruction ultérieure du widget.
  void clearError() {
    if (state.error != null) state = state.copyWith(clearError: true);
  }
}

final signerProvider = SignerNotifier.provider;
