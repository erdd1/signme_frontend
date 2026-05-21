import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../signature/presentation/providers/signature_provider.dart';

class FinancesScreen extends ConsumerStatefulWidget {
  const FinancesScreen({super.key});

  @override
  ConsumerState<FinancesScreen> createState() => _FinancesScreenState();
}

class _FinancesScreenState extends ConsumerState<FinancesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).auth?.user;

    // ── Guard: rôles non autorisés ─────────────────────────────────────────
    if (user == null || !AppPermissions.canViewFinances(user)) {
      return Scaffold(
        drawer: const RoleMenuDrawer(),
        appBar: AppBar(
          title: Text(AppStrings.financesTitle,
              style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: true,
        ),
        body: _AccessDeniedWidget(
          role: user?.role ?? '',
          module: 'Finances',
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      appBar: AppBar(
        title: Text(AppStrings.financesTitle,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: AppStrings.rapportAnnuel),
            Tab(text: AppStrings.comparaison),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _RapportAnnuelTab(),
          _ComparaisonTab(),
        ],
      ),
    );
  }
}

// ── Accès refusé ─────────────────────────────────────────────────────────────
class _AccessDeniedWidget extends StatelessWidget {
  const _AccessDeniedWidget({required this.role, required this.module});
  final String role;
  final String module;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  shape: BoxShape.circle),
              child: const Icon(Icons.lock_outline_rounded,
                  size: 36, color: AppColors.warning),
            ),
            const SizedBox(height: 20),
            Text(AppStrings.accessDenied,
                style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            Text(
              AppStrings.accessDeniedSub,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                  fontSize: 14, color: AppColors.textSecondary, height: 1.6),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(
                'Votre rôle : ${AppPermissions.roleLabel(role)}',
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Onglet Rapport Annuel ─────────────────────────────────────────────────────
class _RapportAnnuelTab extends ConsumerWidget {
  const _RapportAnnuelTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state   = ref.watch(financesProvider);
    final year    = state.year ?? DateTime.now().year;
    final monthly = _buildMonthly(state.data);
    final total   = monthly.fold<int>(0, (s, m) => s + m.amount);
    final totalSig = monthly.fold<int>(0, (s, m) => s + m.count);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(financesProvider.notifier).load(year),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur année
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded, size: 28),
                  onPressed: () => ref.read(financesProvider.notifier).previousYear(),
                ),
                Text(year.toString(),
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary)),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded, size: 28),
                  onPressed: () => ref.read(financesProvider.notifier).nextYear(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Card total
            if (state.isLoading)
              const AppShimmerBox(width: double.infinity, height: 90, radius: 16)
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(16)),
                child: Row(children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.account_balance_wallet_rounded,
                        color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total annuel $year',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white.withOpacity(0.8))),
                      Text('${_fmt(total)} FCFA',
                          style: GoogleFonts.poppins(
                              fontSize: 22, fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Text('$totalSig ${AppStrings.signaturesEnregistrees}',
                          style: GoogleFonts.poppins(
                              fontSize: 12, color: Colors.white.withOpacity(0.8))),
                    ],
                  ),
                ]),
              ),
            const SizedBox(height: 20),

            // Tableau
            if (state.isLoading)
              Column(children: List.generate(
                  6, (_) => const Padding(padding: EdgeInsets.only(bottom: 1),
                      child: TableRowShimmer())))
            else
              _MonthlyTable(monthly: monthly,
                  selectedIdx: state.selectedMonthIndex ?? (DateTime.now().month - 1),
                  ref: ref),
          ],
        ),
      ),
    );
  }

  List<_MonthData> _buildMonthly(Map<String, dynamic> raw) {
    final carte  = raw['carte'] as List? ?? [];
    final result = List.generate(12, (i) => _MonthData(i, 0, 0));
    for (final item in carte) {
      final m   = item as Map<String, dynamic>;
      final idx = (m['monthIndex'] as num?)?.toInt() ?? 0;
      if (idx >= 0 && idx < 12) {
        result[idx] = _MonthData(idx,
            result[idx].count  + 1,
            result[idx].amount + ((m['amount'] as num?)?.toInt() ?? 0));
      }
    }
    return result;
  }

  String _fmt(int v) {
    // Simple formatter
    return v.toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');
  }
}

class _MonthData {
  _MonthData(this.idx, this.count, this.amount);
  final int idx, count, amount;
}

class _MonthlyTable extends StatelessWidget {
  const _MonthlyTable(
      {required this.monthly, required this.selectedIdx, required this.ref});
  final List<_MonthData> monthly;
  final int selectedIdx;
  final WidgetRef ref;

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 0.8)),
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Row(children: [
            Expanded(child: Text(AppStrings.moisCol, style: _h())),
            SizedBox(width: 80,
                child: Text(AppStrings.signatures, textAlign: TextAlign.center, style: _h())),
            SizedBox(width: 100,
                child: Text(AppStrings.montantFcfa, textAlign: TextAlign.right, style: _h())),
          ]),
        ),
        ...List.generate(monthly.length, (i) {
          final m    = monthly[i];
          final isSel = i == selectedIdx;
          return Column(children: [
            InkWell(
              onTap: () => ref.read(financesProvider.notifier).selectMonth(i),
              child: Container(
                color: isSel ? AppColors.primarySurface : Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(children: [
                  Expanded(child: Text(AppStrings.moisFull[i],
                      style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: isSel ? FontWeight.w700 : FontWeight.w400,
                          color: isSel ? AppColors.primary : AppColors.textPrimary))),
                  SizedBox(width: 80,
                      child: Text(m.count > 0 ? '${m.count}' : '–',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w600,
                              color: m.count > 0 ? AppColors.success : AppColors.textHint))),
                  SizedBox(width: 100,
                      child: Text(m.amount > 0 ? '${_fmt(m.amount)} F' : '–',
                          textAlign: TextAlign.right,
                          style: GoogleFonts.poppins(
                              fontSize: 13, fontWeight: FontWeight.w500,
                              color: m.amount > 0 ? AppColors.textPrimary : AppColors.textHint))),
                ]),
              ),
            ),
            if (i < monthly.length - 1)
              const Divider(height: 1, color: AppColors.divider, indent: 16),
          ]);
        }),
      ]),
    );
  }

  TextStyle _h() => GoogleFonts.poppins(
      fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary);
}

class _ComparaisonTab extends StatelessWidget {
  const _ComparaisonTab();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.compare_arrows_rounded,
            size: 56, color: AppColors.textHint),
        const SizedBox(height: 12),
        Text('Comparaison disponible prochainement',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 14)),
      ]),
    );
  }
}
