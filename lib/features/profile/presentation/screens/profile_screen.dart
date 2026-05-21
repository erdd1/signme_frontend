import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.auth?.user;

    // Si déconnecté, afficher un écran vide — le routeur va rediriger
    if (!auth.isAuthenticated || user == null) {
      return const Scaffold(
        body: SizedBox.expand(),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.profile,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
        child: Column(
          children: [
            // ── Avatar + Nom ─────────────────────────────────────────────
            _buildHeader(user),
            const SizedBox(height: 24),

            // ── Infos ────────────────────────────────────────────────────
            _buildInfoCard(user),
            const SizedBox(height: 16),

            // ── Actions ──────────────────────────────────────────────────
            _buildActionsCard(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic user) {
    final role = user != null
        ? (AppStrings.roleLabels[user.role] ?? user.role.toUpperCase())
        : '';

    return Column(
      children: [
        // Avatar
        Container(
          width: 88, height: 88,
          decoration: BoxDecoration(
            shape:  BoxShape.circle,
            border: Border.all(color: AppColors.primary, width: 2),
            color:  AppColors.primarySurface,
          ),
          child: user?.photoUrl != null
              ? ClipOval(child: CachedNetworkImage(imageUrl: user!.photoUrl!, fit: BoxFit.cover))
              : const Icon(Icons.person_rounded, size: 44, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 12),
        Text(user?.nom ?? '',
            style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(user?.email ?? '',
            style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textSecondary)),
        const SizedBox(height: 8),
        // Badge rôle
        if (role.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(role,
                style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
      ],
    );
  }

  Widget _buildInfoCard(dynamic user) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          if (user?.churchNom != null)
            _infoRow(Icons.church_rounded, 'Église', user!.churchNom!),
          if (user?.telephone != null)
            _infoRow(Icons.phone_rounded, 'Téléphone', user!.telephone!),
          if (user?.profession != null)
            _infoRow(Icons.work_rounded, 'Profession', user!.profession!),
          if (user?.groupe != null)
            _infoRow(Icons.group_rounded, 'Groupe', user!.groupe!),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 18, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.poppins(fontSize: 11, color: AppColors.textSecondary)),
              Text(value, style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: AppColors.textPrimary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionsCard(BuildContext ctx, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color:        AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        children: [
          _actionRow(
            icon:  Icons.lock_outline_rounded,
            label: 'Changer le mot de passe',
            color: AppColors.primary,
            onTap: () {}, // TODO
          ),
          const Divider(height: 1, color: AppColors.divider),
          _actionRow(
            icon:  Icons.logout_rounded,
            label: AppStrings.logout,
            color: AppColors.error,
            onTap: () => _confirmLogout(ctx, ref),
          ),
        ],
      ),
    );
  }

  Widget _actionRow({
    required IconData  icon,
    required String    label,
    required Color     color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label,
                style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: color))),
            Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5), size: 20),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, WidgetRef ref) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Déconnexion',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text('Voulez-vous vraiment vous déconnecter ?',
            style: GoogleFonts.poppins(fontSize: 14, color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Annuler', style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              // Appeler le logout — l'état change immédiatement
              // Le routeur détectera le changement via _AuthListenable et redirigera automatiquement
              await ref.read(authNotifierProvider.notifier).logout();
            },
            child: Text('Déconnecter',
                style: GoogleFonts.poppins(color: AppColors.error, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
