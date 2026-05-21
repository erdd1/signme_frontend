import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_shimmer.dart';
import '../providers/rapports_provider.dart';

class RapportSecretaireScreen extends ConsumerStatefulWidget {
  const RapportSecretaireScreen({super.key});

  @override
  ConsumerState<RapportSecretaireScreen> createState() =>
      _RapportSecretaireScreenState();
}

class _RapportSecretaireScreenState extends ConsumerState<RapportSecretaireScreen> {
  String? _selectedMonth;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(rapportSecretaireProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Rapport secrétaire',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sélecteur mois ──────────────────────────────────────────
            Text(
              'Sélectionner le mois',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            _buildMonthSelector(),
            const SizedBox(height: 24),

            // ── Contenu rapport ─────────────────────────────────────────
            if (state.isLoading)
              Column(
                children: List.generate(
                  3,
                  (_) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppShimmerBox(
                      width: double.infinity,
                      height: 100,
                      radius: 12,
                    ),
                  ),
                ),
              )
            else if (state.error != null)
              Center(
                child: Text(
                  state.error!,
                  style: GoogleFonts.poppins(color: AppColors.error),
                ),
              )
            else
              _buildRapportContent(state.data),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(12, (i) {
        final month = '${DateTime.now().year}-${(i + 1).toString().padLeft(2, '0')}';
        final isSel = _selectedMonth == month;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedMonth = month);
            ref.read(rapportSecretaireProvider.notifier).load(month: month);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSel ? AppColors.primary : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: isSel ? AppColors.primary : AppColors.border),
            ),
            child: Text(
              AppStrings.moisShort[i],
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.w400,
                color: isSel ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildRapportContent(Map<String, dynamic> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Total membres
        _buildStatCard(
          icon: Icons.people_rounded,
          label: 'Membres',
          value: '${data['total_members'] ?? 0}',
        ),
        const SizedBox(height: 12),

        // Actifs
        _buildStatCard(
          icon: Icons.check_circle_rounded,
          label: 'Actifs',
          value: '${data['active_members'] ?? 0}',
        ),
        const SizedBox(height: 12),

        // Inactifs
        _buildStatCard(
          icon: Icons.cancel_rounded,
          label: 'Inactifs',
          value: '${data['inactive_members'] ?? 0}',
          color: AppColors.error,
        ),
        const SizedBox(height: 12),

        // Signatures
        _buildStatCard(
          icon: Icons.edit_outlined,
          label: 'Signatures',
          value: '${data['signatures_count'] ?? 0}',
          color: const Color(0xFF6B5B95),
        ),
        const SizedBox(height: 12),

        // Montant total
        _buildStatCard(
          icon: Icons.account_balance_wallet_rounded,
          label: 'Montant collecté',
          value: '${(data['total_amount'] ?? 0)} FCFA',
          color: const Color(0xFF2E8B57),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    Color color = AppColors.primary,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 24, color: color),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
