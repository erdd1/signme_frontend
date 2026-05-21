import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../permissions/app_permissions.dart';
import '../router/app_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';

/// Menu drawer contextuel selon le rôle de l'utilisateur
class RoleMenuDrawer extends ConsumerWidget {
  const RoleMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authNotifierProvider);
    final user = auth.auth?.user;

    if (user == null) return const SizedBox.shrink();

    return Drawer(
      backgroundColor: AppColors.surface,
      child: Column(
        children: [
          // ── Header du drawer ──────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1B5E8F), Color(0xFF0E3A52)],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.nom,
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user.churchNom ?? 'EEC',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),

          // ── Menu items ────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Mon Profil
                _MenuItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Mon Profil',
                  onTap: () {
                    context.pop(); // Fermer drawer
                    context.go(AppRoutes.profile);
                  },
                ),

                // Mon Historique (signatures à distance)
                _MenuItem(
                  icon: Icons.history_outlined,
                  label: 'Mon Historique',
                  onTap: () {
                    context.pop();
                    context.go(AppRoutes.historiquePersonnel);
                  },
                ),

                const Divider(height: 24, indent: 20, endIndent: 20),

                // ── Fonctionnalités par rôle ──────────────────────────
                if (AppPermissions.canViewMembers(user)) ...[
                  _MenuItem(
                    icon: Icons.people_outline_rounded,
                    label: 'Gérer Utilisateurs',
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.users);
                    },
                  ),
                ],

                if (user.isAncien || user.isPasteur) ...[
                  _MenuItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'Historique Signatures',
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.historiqueSignatures);
                    },
                  ),
                ],

                if (user.isPasteur) ...[
                  _MenuItem(
                    icon: Icons.group_rounded,
                    label: 'Anciens de services',
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.anciensDesignations);
                    },
                  ),
                  _MenuItem(
                    icon: Icons.edit_outlined,
                    label: 'Signer les cartes',
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.signer);
                    },
                  ),
                ],

                if (AppPermissions.canManagePublications(user)) ...[
                  _MenuItem(
                    icon: Icons.article_outlined,
                    label: 'Gérer publications',
                    onTap: () {
                      context.pop();
                      // TODO: Implémenter gestion publications
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Fonctionnalité à venir')),
                      );
                    },
                  ),
                ],

                if (user.isSecretaire) ...[
                  _MenuItem(
                    icon: Icons.assessment_outlined,
                    label: 'Rapport secrétaire',
                    onTap: () {
                      context.pop();
                      context.go(AppRoutes.rapportSecretaire);
                    },
                  ),
                ],

                const Divider(height: 24, indent: 20, endIndent: 20),

                // Paramètres (tous les rôles)
                _MenuItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                  onTap: () {
                    context.pop();
                    // TODO: Implémenter paramètres
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Paramètres à venir')),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── Footer: Déconnexion ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(16),
            child: _MenuItem(
              icon: Icons.logout_rounded,
              label: 'Déconnexion',
              iconColor: AppColors.error,
              labelColor: AppColors.error,
              onTap: () {
                // 1. On capture le notifier pendant que le widget est encore vivant
                final authNotifier = ref.read(authNotifierProvider.notifier);

                // 2. On ferme le drawer
                context.pop();

                // 3. On passe le notifier capturé à la boîte de dialogue
                _showLogoutDialog(context, authNotifier);
              },
            ),
          ),
        ],
      ),
    );
  }
  void _showLogoutDialog(BuildContext context, AuthNotifier authNotifier) {
    showDialog(
      context: context,
      barrierDismissible: false, // Empêche de fermer en cliquant à côté pendant l'action
      builder: (dialogContext) => AlertDialog(
        title: Text(
          'Déconnexion',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text('Annuler', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () async {
              // Fermer le dialogue
              Navigator.of(dialogContext).pop();

              // Appeler le logout via le notifier capturé (pas de dépendance au widget ref)
              await authNotifier.logout();
            },
            child: Text(
              'Déconnexion',
              style: GoogleFonts.poppins(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget réutilisable pour item menu
class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = AppColors.primary,
    this.labelColor = AppColors.textPrimary,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 20, color: labelColor.withOpacity(0.5)),
          ],
        ),
      ),
    );
  }
}
