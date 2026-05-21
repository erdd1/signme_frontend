import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../signature/domain/entities/signature_entity.dart';
import '../../../signature/presentation/providers/signature_provider.dart';

class HistoriqueScreen extends ConsumerStatefulWidget {
  const HistoriqueScreen({super.key});

  @override
  ConsumerState<HistoriqueScreen> createState() => _HistoriqueScreenState();
}

class _HistoriqueScreenState extends ConsumerState<HistoriqueScreen> {
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      if (_scrollCtrl.position.pixels >=
          _scrollCtrl.position.maxScrollExtent - 150) {
        ref.read(historiqueProvider.notifier).loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user  = ref.watch(authNotifierProvider).auth?.user;
    final state = ref.watch(historiqueProvider);
    final canViewAll = user != null && AppPermissions.canViewAllHistorique(user);

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      appBar: AppBar(
        title: Text(AppStrings.historiqueTitle,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation:   0,
        centerTitle: true,
        actions: [
          // Filtre visible seulement pour admin/pasteur/trésorier
          if (canViewAll)
            PopupMenuButton<String?>(
              icon: const Icon(Icons.filter_list_rounded,
                  color: AppColors.textPrimary),
              onSelected: (v) {
                final notifier = ref.read(historiqueProvider.notifier);
                if (v == null) {
                  notifier.clearFilters();
                } else {
                  notifier.setFilter(type: v, clearType: false);
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: null,          child: Text('Tous types')),
                PopupMenuItem(value: 'presentiel',  child: Text('Présentiel')),
                PopupMenuItem(value: 'distance',    child: Text('Distance')),
              ],
            ),
        ],
      ),

      // ── Info role banner pour paroissien ─────────────────────────────────
      body: Column(
        children: [
          if (!canViewAll && user != null)
            Container(
              width: double.infinity,
              color: AppColors.primarySurface,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(children: [
                const Icon(Icons.person_outline_rounded,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Affichage de votre historique personnel',
                  style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500),
                ),
              ]),
            ),
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  Widget _buildBody(HistoriqueState state) {
    if (state.isLoading && state.signatures.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: 6,
        itemBuilder: (_, __) => const Padding(
          padding: EdgeInsets.only(bottom: 10),
          child: _SignatureCardShimmer(),
        ),
      );
    }

    if (state.signatures.isEmpty) {
      return RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () => ref.read(historiqueProvider.notifier).refresh(),
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            const SizedBox(height: 80),
            const Icon(Icons.history_toggle_off_rounded,
                size: 64, color: AppColors.textHint),
            const SizedBox(height: 12),
            Center(
              child: Text(AppStrings.noHistorique,
                  style: GoogleFonts.poppins(
                      color: AppColors.textSecondary, fontSize: 14)),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => ref.read(historiqueProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollCtrl,
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        itemCount: state.signatures.length + (state.hasMore ? 1 : 0),
        itemBuilder: (_, i) {
          if (i < state.signatures.length) {
            return _SignatureCard(sig: state.signatures[i]);
          }
          return state.isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: _SignatureCardShimmer())
              : const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── Signature Card ────────────────────────────────────────────────────────────
class _SignatureCard extends StatelessWidget {
  const _SignatureCard({required this.sig});
  final SignatureEntity sig;

  String _fmt(int v) => v.toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ' ');

  @override
  Widget build(BuildContext context) {
    final typeColor = sig.isPresentiel ? AppColors.success : AppColors.secondary;
    final typeLabel = sig.isPresentiel ? AppStrings.presentiel : AppStrings.distance;

    final Color statusColor;
    final IconData statusIcon;
    if (sig.isCompleted) {
      statusColor = AppColors.success;
      statusIcon  = Icons.check_circle_rounded;
    } else if (sig.isFailed) {
      statusColor = AppColors.error;
      statusIcon  = Icons.cancel_rounded;
    } else {
      statusColor = AppColors.warning;
      statusIcon  = Icons.pending_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border, width: 0.8),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03),
              blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12)),
          child: Icon(statusIcon, color: statusColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(AppStrings.moisFull[sig.monthIndex.clamp(0, 11)],
                  style: GoogleFonts.poppins(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary)),
              const SizedBox(width: 4),
              Text('${sig.year}',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondary)),
            ]),
            const SizedBox(height: 4),
            Wrap(spacing: 6, children: [
              _Badge(label: typeLabel, color: typeColor),
              if (sig.ancienNom != null)
                Text(sig.ancienNom!,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary)),
              // Nom du paroissien si vu par un responsable
              if (sig.nomParoissien.isNotEmpty && sig.nomParoissien != sig.ancienNom)
                Text(sig.nomParoissien,
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textSecondary)),
            ]),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('${_fmt(sig.amount)} F',
              style: GoogleFonts.poppins(
                  fontSize: 15, fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary)),
          if (sig.fees > 0)
            Text('+${_fmt(sig.fees)} frais',
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textSecondary)),
        ]),
      ]),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});
  final String label;
  final Color  color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(5)),
    child: Text(label,
        style: GoogleFonts.poppins(
            fontSize: 10, fontWeight: FontWeight.w600, color: color)),
  );
}

class _SignatureCardShimmer extends StatelessWidget {
  const _SignatureCardShimmer();

  @override
  Widget build(BuildContext context) => Container(
    height: 76, padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 0.8)),
    child: const Row(children: [
      AppShimmerBox(width: 44, height: 44, radius: 12),
      SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppShimmerBox(width: 120, height: 13, radius: 6),
          SizedBox(height: 6),
          AppShimmerBox(width: 80, height: 10, radius: 5),
        ],
      )),
      AppShimmerBox(width: 70, height: 16, radius: 8),
    ]),
  );
}
