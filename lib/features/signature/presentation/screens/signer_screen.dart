import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/signature_provider.dart';

// ── État signer ───────────────────────────────────────────────────────────────
class SignerState {
  const SignerState({
    this.selectedMonths = const [],
    this.selectedYear = 2026,
    this.operator_       = 'ORANGE MONEY',
    this.phone           = '',
    this.isLoading       = false,
    this.success         = false,
    this.campayRef,
    this.error,
    this.amountPerMonth  = 1000,
    this.feesPerMonth    = 50,
    this.signatureDate,
    this.alreadySignedMonths = const [],
    this.paymentStatus   = 'idle', // idle, processing, completed, failed
    this.paymentProgress = 0.0,
    // Présentiel
    this.selectedUserId,
    this.selectedUserNom = '',
    this.members         = const [],
    this.isLoadingMembers = false,
    this.memberSearchQuery = '',
    this.filteredMembers = const [],
    this.memberStatus,
    this.isLoadingMemberStatus = false,
    this.successType = '', // '' | 'distance' | 'presentiel'
  });

  final List<String> selectedMonths;
  final int     selectedYear;
  final String  operator_;
  final String  phone;
  final bool    isLoading;
  final bool    success;
  final String? campayRef;
  final String? error;
  final int     amountPerMonth;
  final int     feesPerMonth;
  final DateTime? signatureDate;
  final List<String> alreadySignedMonths;
  final String  paymentStatus;    // idle | processing | completed | failed
  final double  paymentProgress;  // 0.0 à 1.0
  // Présentiel
  final int?    selectedUserId;
  final String  selectedUserNom;
  final List<Map<String, dynamic>> members;
  final bool    isLoadingMembers;
  final String  memberSearchQuery;
  final List<Map<String, dynamic>> filteredMembers;
  final Map<String, dynamic>? memberStatus; // {status: 'signé|non_signé', ...}
  final bool    isLoadingMemberStatus;
  final String  successType; // '' | 'distance' | 'presentiel'

  // Montants autorisés (FCFA)
  static const List<int> ALLOWED_AMOUNTS = [15, 500, 1000, 1500, 2000, 2500, 3000, 4000, 5000, 10000];

  // Calcul des frais selon le montant
  static int calculateFees(int amount) {
    if (amount >= 15 && amount < 500) return 5;
    if (amount >= 500 && amount <= 1000) return 50;
    if (amount >= 1500 && amount <= 4500) return 100;
    if (amount >= 5000 && amount <= 9500) return 150;
    if (amount >= 10000) return 200;
    return 0;
  }

  // Validation du numéro selon l'opérateur
  static bool isValidPhoneNumber(String phone, String operator_) {
    if (phone.length != 9) return false;
    
    if (operator_ == 'ORANGE MONEY') {
      return phone.startsWith('6') || phone.startsWith('2');
    } else if (operator_ == 'MTN MOBILE MONEY') {
      return phone.startsWith('6') || phone.startsWith('5');
    }
    return false;
  }

  // Validation des mois: actuel + passés + prochain mois uniquement
  static bool isValidMonth(String month) {
    final now = DateTime.now();
    final currentMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    
    // Calcul du mois suivant
    final nextMonthDate = DateTime(now.year, now.month + 1, 1);
    final nextMonth = '${nextMonthDate.year}-${nextMonthDate.month.toString().padLeft(2, '0')}';
    
    // Valide si: mois <= mois actuel OR mois == mois suivant
    return month.compareTo(currentMonth) <= 0 || month == nextMonth;
  }

  int get totalAmount => (amountPerMonth + feesPerMonth) * selectedMonths.length;

  SignerState copyWith({
    List<String>? selectedMonths,
    int? selectedYear,
    String? operator_, String? phone, bool? isLoading, bool? success,
    String? campayRef, String? error, int? amountPerMonth, int? feesPerMonth,
    DateTime? signatureDate,
    List<String>? alreadySignedMonths,
    String? paymentStatus,
    double? paymentProgress,
    int? selectedUserId, String? selectedUserNom,
    List<Map<String, dynamic>>? members, bool? isLoadingMembers,
    String? memberSearchQuery,
    List<Map<String, dynamic>>? filteredMembers,
    Map<String, dynamic>? memberStatus,
    bool? isLoadingMemberStatus,
    String? successType,
    bool clearError = false,
  }) => SignerState(
    selectedMonths:       selectedMonths       ?? this.selectedMonths,
    selectedYear:         selectedYear         ?? this.selectedYear,
    operator_:            operator_            ?? this.operator_,
    phone:                phone                ?? this.phone,
    isLoading:            isLoading            ?? this.isLoading,
    success:              success              ?? this.success,
    campayRef:            campayRef            ?? this.campayRef,
    error:                clearError ? null : error ?? this.error,
    amountPerMonth:       amountPerMonth       ?? this.amountPerMonth,
    feesPerMonth:         feesPerMonth         ?? this.feesPerMonth,
    signatureDate:        signatureDate        ?? this.signatureDate,
    alreadySignedMonths:  alreadySignedMonths  ?? this.alreadySignedMonths,
    paymentStatus:        paymentStatus        ?? this.paymentStatus,
    paymentProgress:      paymentProgress      ?? this.paymentProgress,
    selectedUserId:       selectedUserId       ?? this.selectedUserId,
    selectedUserNom:      selectedUserNom      ?? this.selectedUserNom,
    members:              members              ?? this.members,
    isLoadingMembers:     isLoadingMembers     ?? this.isLoadingMembers,
    memberSearchQuery:    memberSearchQuery    ?? this.memberSearchQuery,
    filteredMembers:      filteredMembers      ?? this.filteredMembers,
    memberStatus:         memberStatus         ?? this.memberStatus,
    isLoadingMemberStatus: isLoadingMemberStatus ?? this.isLoadingMemberStatus,
    successType:          successType          ?? this.successType,
  );
}

class SignerNotifier extends StateNotifier<SignerState> {
  SignerNotifier(this._dio) : super(SignerState(
    signatureDate: DateTime.now(),  // Récupère automatiquement la date du jour
  ));
  final Dio _dio;

  void toggleMonth(String month) {
    final list = List<String>.from(state.selectedMonths);
    if (state.alreadySignedMonths.contains(month)) return; // Ne pas pouvoir désélectionner un mois déjà signé
    list.contains(month) ? list.remove(month) : list.add(month);
    state = state.copyWith(selectedMonths: list);
  }

  void setYear(int year) {
    // Réinitialiser les mois sélectionnés quand on change d'année
    state = state.copyWith(selectedYear: year, selectedMonths: []);
  }

  void setAmount(int amount) {
    final fees = SignerState.calculateFees(amount);
    state = state.copyWith(amountPerMonth: amount, feesPerMonth: fees);
  }

  void setOperator(String op) => state = state.copyWith(operator_: op, clearError: true);
  
  void setPhone(String v) => state = state.copyWith(phone: v, clearError: true);
  
  void setSignatureDate(DateTime date) => state = state.copyWith(signatureDate: date);
  
  void selectUser(int id, String nom) {
    state = state.copyWith(selectedUserId: id, selectedUserNom: nom, memberSearchQuery: '', clearError: true);
    fetchMemberStatus(id);
  }

  /// Récupère le statut de signature du membre pour le mois actuel
  Future<void> fetchMemberStatus(int userId) async {
    state = state.copyWith(isLoadingMemberStatus: true);
    try {
      final now = DateTime.now();
      final month = now.month.toString().padLeft(2, '0');
      final year = now.year;
      final monthParam = '$year-$month';

      final resp = await _dio.get(
        ApiConfig.signatureMemberStatus(userId),
        queryParameters: {'month': monthParam},
      );

      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final statusData = resp.data['data'] as Map<String, dynamic>;
        state = state.copyWith(memberStatus: statusData, isLoadingMemberStatus: false);
        print('📋 [MemberStatus] userId=$userId status=${statusData['status']}');
      } else {
        state = state.copyWith(isLoadingMemberStatus: false);
      }
    } catch (e) {
      print('❌ Erreur fetch statut membre: $e');
      state = state.copyWith(isLoadingMemberStatus: false);
    }
  }

  /// Met à jour la requête de recherche et filtre les résultats localement
  void updateMemberSearch(String query) {
    state = state.copyWith(memberSearchQuery: query);
    if (query.isEmpty) {
      state = state.copyWith(filteredMembers: state.members);
      return;
    }
    final q = query.toLowerCase();
    final filtered = state.members.where((m) {
      final nom = (m['nom']?.toString() ?? '').toLowerCase();
      final email = (m['email']?.toString() ?? '').toLowerCase();
      return nom.contains(q) || email.contains(q);
    }).toList();
    state = state.copyWith(filteredMembers: filtered);
  }

  /// Cherche les utilisateurs via l'API
  Future<void> searchMembers(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(filteredMembers: []);
      return;
    }
    state = state.copyWith(isLoadingMembers: true);
    try {
      final resp = await _dio.get(
        ApiConfig.users,
        queryParameters: {
          'search': query,
          'per_page': 20,
        },
      );
      if (resp.statusCode == 200) {
        final list = (resp.data['data'] as List? ?? [])
            .map((e) => e as Map<String, dynamic>)
            .toList();
        state = state.copyWith(filteredMembers: list, isLoadingMembers: false);
      }
    } catch (e) {
      print('❌ Erreur recherche utilisateurs: $e');
      state = state.copyWith(isLoadingMembers: false);
    }
  }

  Future<void> loadMembers() async {
    state = state.copyWith(isLoadingMembers: true);
    try {
      final resp = await _dio.get(ApiConfig.usersPasteur);
      final list = (resp.data['data'] as List? ?? [])
          .map((e) => e as Map<String, dynamic>)
          .toList();
      state = state.copyWith(members: list, filteredMembers: list, isLoadingMembers: false);
    } catch (_) {
      state = state.copyWith(isLoadingMembers: false);
    }
  }

  Future<void> loadAlreadySignedMonths(int userId, int year) async {
    try {
      // Récupérer les mois déjà signés depuis l'API
      final resp = await _dio.get(
        ApiConfig.signatureMaCarte,
        queryParameters: {'year': year},
      );
      if (resp.statusCode == 200 && resp.data['success'] == true) {
        final data = resp.data['data'] as Map<String, dynamic>;
        final signaturesParMois = data['signaturesParMois'] as Map<String, dynamic>? ?? {};
        
        // Extraire les mois signés (clés qui contiennent une signature)
        final signed = signaturesParMois.entries
            .where((e) => e.value != null)
            .map((e) => '$year-${(int.tryParse(e.key) ?? 0) + 1}'.padLeft(7, '0'))
            .toList();
        
        state = state.copyWith(alreadySignedMonths: signed);
      }
    } catch (e) {
      // Silencieusement ignorer l'erreur
    }
  }

  Future<bool> initiateDistance() async {
    // Valider le numéro selon l'opérateur
    if (!SignerState.isValidPhoneNumber(state.phone, state.operator_)) {
      String msg = state.operator_ == 'ORANGE MONEY'
          ? 'Numéro Orange Money invalide'
          : 'Numéro MTN Money invalide';
      state = state.copyWith(error: msg);
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true, paymentStatus: 'processing', paymentProgress: 0.0, success: true, successType: 'distance');
    try {
      // Étape 1: Initier le paiement
      state = state.copyWith(paymentProgress: 0.2);
      
      final resp = await _dio.post(ApiConfig.signatureDistance, data: {
        'months':        state.selectedMonths,
        'amount':        state.amountPerMonth,
        'paymentMethod': state.operator_,
        'phoneNumber':   state.phone,
      });
      
      if (resp.statusCode == 201 && resp.data['success'] == true) {
        final ref_ = resp.data['data']?['campay_reference']?.toString() ?? '';
        final transactionId = resp.data['data']?['transaction_id'] as int?;
        
        state = state.copyWith(campayRef: ref_, paymentProgress: 0.3);
        
        // Si on a un transaction_id, faire un polling pour surveiller le paiement
        if (transactionId != null) {
          await _pollTransactionStatus(transactionId);
        } else {
          // Fallback si pas de transaction_id
          state = state.copyWith(
            isLoading: false, 
            success: true,
            paymentStatus: 'completed',
            paymentProgress: 1.0,
            successType: 'distance',
          );
        }
        
        return true;
      }
      
      state = state.copyWith(
        isLoading: false,
        error: resp.data['message']?.toString() ?? 'Erreur',
        paymentStatus: 'failed',
        success: false,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false, 
        error: e.toString(),
        paymentStatus: 'failed',
        success: false,
      );
      return false;
    }
  }

  /// Sonde le statut de la transaction toutes les 5 secondes pendant max 60 secondes
  Future<void> _pollTransactionStatus(int transactionId) async {
    const int maxDurationSeconds = 180; // 3 minutes
    const int pollIntervalSeconds = 5;
    int elapsedSeconds = 0;
    double currentProgress = 0.3;

    while (elapsedSeconds < maxDurationSeconds) {
      try {
        await Future.delayed(const Duration(seconds: pollIntervalSeconds));
        elapsedSeconds += pollIntervalSeconds;

        // Incrémenter la barre de progression graduellement
        currentProgress = (currentProgress + 0.15).clamp(0.0, 0.95);
        state = state.copyWith(paymentProgress: currentProgress);

        // Récupérer le statut de la transaction
        final resp = await _dio.get(
          ApiConfig.signatureTransactionStatus(transactionId)
        );

        if (resp.statusCode == 200 && resp.data['success'] == true) {
          final txData = resp.data['data'];
          final status = txData?['status']?.toString() ?? 'pending';
          final apiProgress = (txData?['progress'] as num?)?.toDouble();
          
          // Utiliser le progrès de l'API s'il est disponible, sinon utiliser le progrès calculé
          if (apiProgress != null && apiProgress > currentProgress) {
            currentProgress = apiProgress;
            state = state.copyWith(paymentProgress: currentProgress);
          }

          // Si le paiement est confirmé, on arrête le polling
          if (status == 'completed') {
            state = state.copyWith(
              isLoading: false,
              success: true,
              paymentStatus: 'completed',
              paymentProgress: 1.0,
              successType: 'distance',
            );
            return;
          }

          // Si le paiement a échoué
          if (status == 'failed') {
            state = state.copyWith(
              isLoading: false,
              error: 'Paiement échoué',
              paymentStatus: 'failed',
              success: false,
            );
            return;
          }
        }
      } catch (e) {
        // Continuer le polling même en cas d'erreur
        continue;
      }
    }

    // Timeout après 3 minutes - le webhook n'a pas confirmé le paiement
    state = state.copyWith(
      isLoading: false,
      error: 'Délai d\'attente dépassé (3 min). Veuillez vérifier votre solde mobile money et réessayer.',
      paymentStatus: 'failed',
      success: false,
    );
  }

  Future<bool> initiatePresentiel() async {
    if (state.selectedUserId == null || state.selectedMonths.isEmpty) return false;
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final resp = await _dio.post(ApiConfig.signaturePresentiel, data: {
        'userId': state.selectedUserId,
        'months': state.selectedMonths,
        'amount': state.amountPerMonth,
      });
      if (resp.statusCode == 201 && resp.data['success'] == true) {
        state = state.copyWith(isLoading: false, success: true, successType: 'presentiel');
        return true;
      }
      state = state.copyWith(isLoading: false,
          error: resp.data['message']?.toString() ?? 'Erreur');
      return false;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  void reset() => state = const SignerState();
}

final signerProvider =
    StateNotifierProvider.autoDispose<SignerNotifier, SignerState>((ref) {
  return SignerNotifier(ref.watch(dioProvider));
});

// ── Écran Signer ──────────────────────────────────────────────────────────────
class SignerScreen extends ConsumerStatefulWidget {
  const SignerScreen({super.key});

  @override
  ConsumerState<SignerScreen> createState() => _SignerScreenState();
}

class _SignerScreenState extends ConsumerState<SignerScreen>
    with SingleTickerProviderStateMixin {
  final _formKey  = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    final user     = ref.read(authNotifierProvider).auth?.user;
    final canPres  = user != null && AppPermissions.canSignPresentiel(user);
    _tab = TabController(length: canPres ? 2 : 1, vsync: this);
    if (canPres) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(signerProvider.notifier).loadMembers();
      });
    }
    // Charger les mois déjà signés au démarrage
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(signerProvider.notifier).loadAlreadySignedMonths(user.id, DateTime.now().year);
      });
    }
  }

  @override
  void dispose() {
    _tab.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state   = ref.watch(signerProvider);
    final user    = ref.watch(authNotifierProvider).auth?.user;
    final canPres = user != null && AppPermissions.canSignPresentiel(user);

    if (state.success && state.successType == 'distance') return _buildSuccess(state);
    if (state.success && state.successType == 'presentiel') return _buildSuccessPresentiel(state);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(AppStrings.signerTitle,
            style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        bottom: canPres
            ? TabBar(
                controller: _tab,
                tabs: const [
                  Tab(text: 'Distance (Mobile Money)'),
                  Tab(text: 'Présentiel'),
                ],
              )
            : null,
      ),
      body: canPres
          ? TabBarView(
              controller: _tab,
              children: [_distanceForm(state), _presentielForm(state)],
            )
          : _distanceForm(state),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formulaire Distance
  // ─────────────────────────────────────────────────────────────────────────
  Widget _distanceForm(SignerState state) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Montant de la signature ───────────────────────────────
            _sectionTitle('Montant de la signature'),
            const SizedBox(height: 10),
            _amountDropdown(state),
            
            const SizedBox(height: 22),
            
            // ─── Frais par mois ────────────────────────────────────────
            _feeDisplay(state),
            
            const SizedBox(height: 22),
            
            // ─── Sélectionner l'année et les mois ──────────────────────
            _sectionTitle('Sélectionner l\'année'),
            const SizedBox(height: 10),
            _yearSelector(state),
            
            const SizedBox(height: 22),
            
            _sectionTitle('Sélectionner les mois (${state.selectedYear})'),
            const SizedBox(height: 10),
            _monthGrid(state, state.selectedYear),
            
            const SizedBox(height: 22),
            
            // ─── Mode de paiement ──────────────────────────────────────
            _sectionTitle('Mode de paiement'),
            const SizedBox(height: 10),
            _operatorRow(state),
            
            const SizedBox(height: 20),
            
            // ─── Numéro Mobile Money ───────────────────────────────────
            _sectionTitle('Numéro de paiement'),
            const SizedBox(height: 10),
            TextFormField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              onChanged: (v) => ref.read(signerProvider.notifier).setPhone(v),
              style: GoogleFonts.poppins(fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ex: 6XX XXX XXX',
                prefixIcon: const Icon(Icons.phone_rounded,
                    color: AppColors.textSecondary, size: 20),
                errorText: _getPhoneError(state),
              ),
              validator: (v) {
                if (v == null || v.isEmpty) return AppStrings.requiredField;
                if (v.length < 9) return 'Numéro incomplet';
                return null;
              },
            ),
            
            const SizedBox(height: 24),
            
            // ─── Résumé ────────────────────────────────────────────────
            if (state.selectedMonths.isNotEmpty) ...[
              _summary(state), 
              const SizedBox(height: 24),
            ],
            
            // ─── Bouton de validation ──────────────────────────────────
            AppPrimaryButton(
              label: AppStrings.confirmerPaiement,
              enabled: state.selectedMonths.isNotEmpty && 
                       state.phone.length >= 9 &&
                       SignerState.isValidPhoneNumber(state.phone, state.operator_),
              isLoading: state.isLoading,
              onPressed: _submitDistance,
            ),
            
            if (state.error != null) ...[
              const SizedBox(height: 10),
              Text(state.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(color: AppColors.error, fontSize: 12)),
            ],
          ],
        ),
      ),
    );
  }

  String? _getPhoneError(SignerState state) {
    if (state.phone.isEmpty) return null;
    if (state.phone.length < 9) return null;
    if (!SignerState.isValidPhoneNumber(state.phone, state.operator_)) {
      return state.operator_ == 'ORANGE MONEY'
          ? 'Numéro Orange invalide (commence par 6 ou 2)'
          : 'Numéro MTN invalide (commence par 6 ou 5)';
    }
    return null;
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Formulaire Présentiel
  // ─────────────────────────────────────────────────────────────────────────
  Widget _presentielForm(SignerState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle('Sélectionner le membre'),
          const SizedBox(height: 10),
          _memberPicker(state),
          const SizedBox(height: 22),
          if (state.selectedUserId != null) ...[
            _memberSummaryCard(state),
            const SizedBox(height: 22),
          ],
          _sectionTitle('Montant de l\'offrande'),
          const SizedBox(height: 10),
          _amountDropdown(state),
          const SizedBox(height: 22),
          _sectionTitle('Sélectionner l\'année'),
          const SizedBox(height: 10),
          _yearSelector(state),
          const SizedBox(height: 22),
          _sectionTitle('Sélectionner les mois (${state.selectedYear})'),
          const SizedBox(height: 10),
          _monthGrid(state, state.selectedYear),
          const SizedBox(height: 28),
          AppPrimaryButton(
            label: AppStrings.confirmerPres,
            enabled: state.selectedUserId != null && state.selectedMonths.isNotEmpty,
            isLoading: state.isLoading,
            onPressed: _submitPresentiel,
          ),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            Text(state.error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: AppColors.error, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _memberPicker(SignerState state) {
    final selectedText = state.selectedUserNom.isNotEmpty
        ? state.selectedUserNom
        : state.memberSearchQuery;

    return Column(
      children: [
        TextField(
          onChanged: (query) {
            ref.read(signerProvider.notifier).updateMemberSearch(query);
            if (query.length >= 2) {
              ref.read(signerProvider.notifier).searchMembers(query);
            }
          },
          decoration: InputDecoration(
            hintText: 'Rechercher un membre (nom, email)...',
            hintStyle: GoogleFonts.poppins(color: AppColors.textHint),
            prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
            suffixIcon: state.memberSearchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      ref.read(signerProvider.notifier).updateMemberSearch('');
                    },
                    child: const Icon(Icons.clear, color: AppColors.textSecondary),
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          ),
        ),
        if (state.memberSearchQuery.isNotEmpty && state.filteredMembers.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: state.filteredMembers.length,
              itemBuilder: (ctx, idx) {
                final member = state.filteredMembers[idx];
                final id = (member['id'] as num).toInt();
                final nom = member['nom']?.toString() ?? 'Sans nom';
                final email = member['email']?.toString() ?? '';

                return ListTile(
                  onTap: () {
                    ref.read(signerProvider.notifier).selectUser(id, nom);
                  },
                  title: Text(nom, style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                  subtitle: Text(email, style: GoogleFonts.poppins(fontSize: 12)),
                  trailing: const Icon(Icons.check_circle_outline, color: AppColors.primary),
                );
              },
            ),
          ),
        if (state.memberSearchQuery.isNotEmpty && state.filteredMembers.isEmpty && !state.isLoadingMembers)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              border: Border.all(color: AppColors.warning),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(Icons.search_off, color: AppColors.warning, size: 40),
                const SizedBox(height: 12),
                Text('Aucun résultat trouvé',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    )),
                const SizedBox(height: 6),
                Text('Aucun membre ne correspond à "${state.memberSearchQuery}"',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    )),
              ],
            ),
          ),
        if (state.isLoadingMembers)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: SizedBox(
              height: 40,
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        if (state.selectedUserNom.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              border: Border.all(color: AppColors.primary),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Membre sélectionné',
                          style: GoogleFonts.poppins(fontSize: 12, color: AppColors.textSecondary)),
                      Text(state.selectedUserNom,
                          style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Widget affichant le résumé du membre sélectionné
  Widget _memberSummaryCard(SignerState state) {
    // Trouver les données complètes du membre sélectionné
    final memberData = state.filteredMembers.isNotEmpty
        ? state.filteredMembers.firstWhere(
            (m) => (m['id'] as num).toInt() == state.selectedUserId,
            orElse: () => <String, dynamic>{},
          )
        : {};

    final photoUrl = memberData['photoUrl']?.toString() ?? memberData['photo_url']?.toString() ?? '';
    final nom = state.selectedUserNom;
    final role = memberData['role']?.toString() ?? 'Membre';
    final email = memberData['email']?.toString() ?? '';

    // Données du statut de signature
    final memberStatus = state.memberStatus;
    final isSigned = memberStatus?['status'] == 'signé';
    final statusColor = isSigned ? const Color(0xFF2196F3) : const Color(0xFFE53935); // Bleu vs Rouge
    final statusIcon = isSigned ? Icons.check_circle : Icons.cancel;
    final statusLabel = isSigned ? 'Signé' : 'Non signé';

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Photo du membre
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: photoUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(photoUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: photoUrl.isEmpty
                    ? const Icon(Icons.person, color: AppColors.primary, size: 30)
                    : null,
              ),
              const SizedBox(width: 16),
              // Infos du membre
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(nom,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(role,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        )),
                    const SizedBox(height: 4),
                    Text(email,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textHint,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              // Badge "Sélectionné"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('Sélectionné',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary,
                        )),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Badge du statut de signature (mois actuel)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              border: Border.all(color: statusColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                state.isLoadingMemberStatus
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        ),
                      )
                    : Icon(statusIcon, size: 16, color: statusColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Statut ce mois (${DateTime.now().month}/${DateTime.now().year})',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          )),
                      const SizedBox(height: 2),
                      Text(statusLabel,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widgets communs
  // ─────────────────────────────────────────────────────────────────────────
  Widget _yearSelector(SignerState state) {
    final years = List.generate(5, (i) => 2026 + i);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: years.map((year) {
          final isSelected = state.selectedYear == year;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                ref.read(signerProvider.notifier).setYear(year);
                ref.read(signerProvider.notifier).loadAlreadySignedMonths(
                  ref.read(authNotifierProvider).auth?.user?.id ?? 0,
                  year,
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  year.toString(),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _amountDropdown(SignerState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: state.amountPerMonth,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: AppColors.textSecondary),
          items: SignerState.ALLOWED_AMOUNTS.map((amount) {
            return DropdownMenuItem<int>(
              value: amount,
              child: Text(
                '$amount FCFA',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: AppColors.textPrimary),
              ),
            );
          }).toList(),
          onChanged: (amount) {
            if (amount != null) {
              ref.read(signerProvider.notifier).setAmount(amount);
            }
          },
        ),
      ),
    );
  }

  Widget _feeDisplay(SignerState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Frais par mois',
                  style: GoogleFonts.poppins(
                      fontSize: 12, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('${state.feesPerMonth} FCFA',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ],
          ),
          Text('Montant: ${state.amountPerMonth} FCFA',
              style: GoogleFonts.poppins(
                  fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _monthGrid(SignerState state, int year) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: List.generate(12, (i) {
        final month = '$year-${(i + 1).toString().padLeft(2, '0')}';
        final isSel = state.selectedMonths.contains(month);
        final isAlreadySigned = state.alreadySignedMonths.contains(month);
        final isValidMonth = SignerState.isValidMonth(month);
        final isDisabled = isAlreadySigned || !isValidMonth;
        
        return GestureDetector(
          onTap: isDisabled ? null : () {
            HapticFeedback.lightImpact();
            ref.read(signerProvider.notifier).toggleMonth(month);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isDisabled 
                  ? AppColors.divider
                  : (isSel ? AppColors.primary : AppColors.surface),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isDisabled
                      ? AppColors.border
                      : (isSel ? AppColors.primary : AppColors.border)),
            ),
            child: Text(
              AppStrings.moisShort[i],
              style: GoogleFonts.poppins(
                fontSize:   13,
                fontWeight: (isSel || isDisabled) ? FontWeight.w600 : FontWeight.w400,
                color: isDisabled
                    ? AppColors.textHint
                    : (isSel ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _operatorRow(SignerState state) {
    final ops = [AppStrings.orangeMoney, AppStrings.mtnMoney];
    return Row(
      children: ops.asMap().entries.map((e) {
        final op  = e.value;
        final isSel = state.operator_ == op;
        return Expanded(
          child: GestureDetector(
            onTap: () => ref.read(signerProvider.notifier).setOperator(op),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: EdgeInsets.only(right: e.key == 0 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color:        isSel ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border:       Border.all(
                    color: isSel ? AppColors.primary : AppColors.border),
              ),
              child: Text(
                op == AppStrings.orangeMoney ? 'Orange Money' : 'MTN MoMo',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13, fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                  color: isSel ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _summary(SignerState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Column(children: [
        _row('Mois sélectionnés', '${state.selectedMonths.length} mois'),
        const SizedBox(height: 8),
        _row('Montant / mois', '${state.amountPerMonth} FCFA'),
        if (state.feesPerMonth > 0) ...[
          const SizedBox(height: 8),
          _row('Frais de service', '${state.feesPerMonth} FCFA'),
        ],
        const Divider(height: 20, color: AppColors.border),
        _row('TOTAL À PAYER', '${state.totalAmount} FCFA', bold: true),
      ]),
    );
  }

  Widget _row(String l, String v, {bool bold = false}) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(l, style: GoogleFonts.poppins(
          fontSize: 13,
          color: AppColors.textSecondary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400)),
      Text(v, style: GoogleFonts.poppins(
          fontSize: 13,
          color: bold ? AppColors.primary : AppColors.textPrimary,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w500)),
    ],
  );

  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.poppins(
          fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary));

  // ─────────────────────────────────────────────────────────────────────────
  // Submit handlers
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _submitDistance() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    // Vérifier que tous les mois sélectionnés sont valides
    final state = ref.read(signerProvider);
    final invalidMonths = state.selectedMonths.where((m) => !SignerState.isValidMonth(m)).toList();
    if (invalidMonths.isNotEmpty) {
      AppSnackbar.error(context, 'Certains mois ne sont pas autorisés pour la signature');
      return;
    }
    
    FocusScope.of(context).unfocus();
    final ok = await ref.read(signerProvider.notifier).initiateDistance();
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(signerProvider).error;
      if (err != null) AppSnackbar.error(context, err);
    } else {
      // Rafraîchir la carte après une signature réussie
      ref.read(maCarteProvider.notifier).load(ref.read(signerProvider).selectedYear);
    }
  }

  Future<void> _submitPresentiel() async {
    // Vérifier que tous les mois sélectionnés sont valides
    final state = ref.read(signerProvider);
    final invalidMonths = state.selectedMonths.where((m) => !SignerState.isValidMonth(m)).toList();
    if (invalidMonths.isNotEmpty) {
      AppSnackbar.error(context, 'Certains mois ne sont pas autorisés pour la signature');
      return;
    }
    
    FocusScope.of(context).unfocus();
    final ok = await ref.read(signerProvider.notifier).initiatePresentiel();
    if (!mounted) return;
    if (!ok) {
      final err = ref.read(signerProvider).error;
      if (err != null) AppSnackbar.error(context, err);
    } else {
      // Rafraîchir la carte après une signature réussie
      ref.read(maCarteProvider.notifier).load(ref.read(signerProvider).selectedYear);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Écran succès avec suivi du paiement
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSuccess(SignerState state) {
    final isProcessing = state.paymentStatus == 'processing';
    final isCompleted = state.paymentStatus == 'completed';
    final isFailed = state.paymentStatus == 'failed';
    
    // Si erreur, revenir au formulaire après 3 secondes
    if (isFailed && state.error != null) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          ref.read(signerProvider.notifier).reset();
          Navigator.of(context).pop();
        }
      });
    }

    return WillPopScope(
      onWillPop: () async => !isProcessing, // Empêcher de revenir pendant le traitement
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Icône ─────────────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 90, 
                height: 90,
                decoration: BoxDecoration(
                  gradient: isFailed 
                      ? LinearGradient(colors: [AppColors.error, AppColors.error.withOpacity(0.8)])
                      : AppColors.primaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted ? Icons.check_rounded :
                  isProcessing ? Icons.hourglass_bottom_rounded :
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),
              
              // ─── Titre ─────────────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: GoogleFonts.poppins(
                  fontSize: 22, 
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                child: Text(
                  isCompleted ? 'Signature enregistrée !' :
                  isProcessing ? 'Signature initiée !' :
                  'Erreur de paiement',
                ),
              ),
              const SizedBox(height: 12),
              
              // ─── Description ───────────────────────────────────────────
              Text(
                isProcessing 
                    ? 'Une notification de paiement a été envoyée sur votre téléphone. Validez sur votre application Mobile Money.'
                    : isCompleted 
                        ? 'Votre paiement a été effectué avec succès, merci pour votre signature.'
                        : (state.error ?? 'Une erreur est survenue. Réessai en cours...'),
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14, 
                  color: isFailed ? AppColors.error : AppColors.textSecondary,
                  height: 1.6,
                ),
              ),
              
              // ─── Barre de progression (pendant traitement et après) ────
              if (isProcessing || isCompleted) ...[
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: state.paymentProgress,
                    minHeight: 6,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
              
              // ─── Code USSD (seulement pendant traitement) ──────────────
              if (isProcessing && state.campayRef != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'Tapez #${state.campayRef}#',
                    style: GoogleFonts.poppins(
                      fontSize: 13, 
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              
              const SizedBox(height: 36),
              
              // ─── Bouton action ─────────────────────────────────────────
              if (isCompleted)
                AppPrimaryButton(
                  label: 'Fermer',
                  onPressed: () {
                    ref.read(signerProvider.notifier).reset();
                    context.pop();
                    // Rafraîchir la carte
                    ref.read(maCarteProvider.notifier).load(state.selectedYear);
                  },
                )
              else if (isProcessing)
                AppPrimaryButton(
                  label: 'Fermer',
                  onPressed: null, // Désactivé pendant le traitement
                  enabled: false,
                )
              else if (isFailed)
                Column(
                  children: [
                    Text(
                      'Retour au formulaire...',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(
                        backgroundColor: AppColors.border,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Écran de succès pour la signature présentielle
  /// Affiche l'icône + message avec bouton Fermer
  Widget _buildSuccessPresentiel(SignerState state) {
    return WillPopScope(
      onWillPop: () async => true,
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ─── Icône de succès ───────────────────────────────────────
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 56,
                ),
              ),
              const SizedBox(height: 32),

              // ─── Titre succès ──────────────────────────────────────────
              Text(
                'Signature enregistrée',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // ─── Message de remerciement ───────────────────────────────
              Text(
                'Merci !',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // ─── Bouton Fermer ─────────────────────────────────────────
              AppPrimaryButton(
                label: 'Fermer',
                onPressed: () {
                  ref.read(signerProvider.notifier).reset();
                  Navigator.of(context).pop();
                  // Rafraîchir la carte
                  ref.read(maCarteProvider.notifier).load(state.selectedYear);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

