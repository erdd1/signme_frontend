import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../domain/entities/signature_entity.dart';
import '../providers/signature_provider.dart';

class MaCarteScreen extends ConsumerWidget {
  const MaCarteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(maCarteProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      appBar: AppBar(
        title: Text(AppStrings.maCarteTitle,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: state.isLoading && state.data == null
          ? _buildShimmer()
          : _buildContent(context, state, ref),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const CarteHeaderShimmer(),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: 8,
              itemBuilder: (_, __) => const Padding(
                padding: EdgeInsets.only(bottom: 1),
                child: TableRowShimmer(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, MaCarteState state, WidgetRef ref) {
    final data = state.data;
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(maCarteProvider.notifier).load(state.year ?? DateTime.now().year),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Bannière Signature ─────────────────────────────────────
            _buildBanner(context, data),
            const SizedBox(height: 20),

            // ── Table Offrandes ────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color:        AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border:       Border.all(color: AppColors.border, width: 0.8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      AppStrings.offrandes,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  // ── En-tête du tableau ───────────────────────────────
                  _buildTableHeader(state.year ?? DateTime.now().year),
                  const Divider(height: 1, color: AppColors.divider),
                  // ── Lignes ──────────────────────────────────────────
                  ...List.generate(12, (i) => _buildTableRow(i, data, state.year ?? DateTime.now().year)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(BuildContext context, MaCarteData? data) {
    final hasPending = data?.hasPendingSignature ?? false;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.assignment_ind_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.maCarteSainte,
                    style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(
                  hasPending ? AppStrings.signaturePending : AppStrings.signatureOk,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.signer),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(AppStrings.signerBtn,
                  style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTableHeader(int currentYear) {
    // Affiche l'année courante + 4 prochaines
    final years = List.generate(5, (i) => currentYear + i);
    return Container(
      color: AppColors.surfaceVariant,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text('Mois',
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
          ),
          ...years.map((y) => Expanded(
            child: Text(
              y.toString(),
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: y == currentYear ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildTableRow(int monthIdx, MaCarteData? data, int currentYear) {
    final sig = data?.signaturesParMois[monthIdx.toString()];
    final isCurrentMonth = monthIdx == (DateTime.now().month - 1) &&
        currentYear == DateTime.now().year;

    return Column(
      children: [
        Container(
          color: isCurrentMonth ? AppColors.primarySurface : Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          child: Row(
            children: [
              SizedBox(
                width: 40,
                child: Text(
                  AppStrings.moisShort[monthIdx],
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: isCurrentMonth ? FontWeight.w700 : FontWeight.w400,
                    color: isCurrentMonth ? AppColors.primary : AppColors.textPrimary,
                  ),
                ),
              ),
              // Année courante — données réelles
              Expanded(child: _cellValue(sig, isCurrentYear: true)),
              // Autres années — vide
              ...List.generate(4, (_) => Expanded(child: _cellValue(null, isCurrentYear: false))),
            ],
          ),
        ),
        if (monthIdx < 11) const Divider(height: 1, color: AppColors.divider, indent: 12),
      ],
    );
  }

  Widget _cellValue(SignatureEntity? sig, {required bool isCurrentYear}) {
    if (!isCurrentYear || sig == null) {
      return Text(AppStrings.noSign,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textHint));
    }

    final fmt   = NumberFormat('#,###', 'fr_FR');
    final color = sig.isCompleted ? AppColors.signed : (sig.isPending ? AppColors.warning : AppColors.error);

    return Text(
      fmt.format(sig.amount),
      textAlign: TextAlign.center,
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: color),
    );
  }
}
