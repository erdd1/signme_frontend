import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/domain/entities/user_entity.dart';
import '../design_system/index.dart';
import '../constants/app_assets.dart';
import '../permissions/app_permissions.dart';
import '../router/app_router.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/badge/domain/entities/badge_count_entity.dart';
import '../../features/badge/presentation/providers/badge_provider.dart';
import 'app_snackbar.dart';
import 'badge_dot.dart';

/// Menu drawer contextuel selon le rôle de l'utilisateur
class RoleMenuDrawer extends ConsumerWidget {
  const RoleMenuDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final UserEntity? user = authState.auth?.user;

    if (user == null) return const SizedBox.shrink();

    // ── Lecture des badges (silencieux si erreur) ─────────────────────────
    final badgeState = ref.watch(badgeNotifierProvider);
    final badges = badgeState.valueOrNull ?? BadgeCountEntity.empty;

    return Drawer(
      backgroundColor: SignmeColors.white,
      child: Column(
        children: [
          // ── Header Premium ──────────────────────────────────────────
          _buildHeader(user),

          // ── Menu items typés ────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
              children: [
                _buildSectionTitle('NAVIGATION'),

                // Finances
                if (AppPermissions.canViewFinances(user))
                  _MenuItem(
                    iconPath: SignmeAssets.finances,
                    label: 'Finances',
                    onTap: () => _navigate(context, AppRoutes.finances),
                  ),

                // Gestion des membres
                if (AppPermissions.canViewMembers(user))
                  _MenuItem(
                    iconPath: SignmeAssets.manageUsers,
                    label: 'Gérer utilisateurs',
                    onTap: () => _navigate(context, AppRoutes.users),
                  ),

                // Historique Signatures (Clergé/Anciens) — avec badge
                if (user.role == 'ancien' || user.role == 'pasteur')
                  _MenuItem(
                    iconPath: SignmeAssets.historySignatures,
                    label: 'Historique Signatures',
                    badgeCount: badges.historiqueSignatures,
                    onTap: () {
                      // Reset badge avant navigation
                      ref
                          .read(badgeNotifierProvider.notifier)
                          .markRead('historique_signatures');
                      _navigate(context, AppRoutes.historiqueSignatures);
                    },
                  ),

                // Administration Pasteur
                if (user.role == 'pasteur') ...[
                  _MenuItem(
                    iconPath: SignmeAssets.serviceAnciens,
                    label: 'Anciens de services',
                    onTap: () =>
                        _navigate(context, AppRoutes.anciensDesignations),
                  ),
                  _MenuItem(
                    iconPath: SignmeAssets.signCard,
                    label: 'Signer les cartes',
                    onTap: () => _navigate(context, AppRoutes.signer),
                  ),
                ],

                // Publications
                if (AppPermissions.canManagePublications(user))
                  _MenuItem(
                    iconPath: SignmeAssets.managePubs,
                    label: 'Gérer publications',
                    onTap: () => _navigate(context, AppRoutes.publications),
                  ),

                // Créer un événement (collecte de fonds)
                if (AppPermissions.canManageEvenements(user))
                  _MenuItem(
                    iconPath: SignmeAssets.add,
                    label: 'Créer un événement',
                    onTap: () => _navigate(context, AppRoutes.evenementCreate),
                  ),

                // Gérer les événements (Actifs / Archivés, montant collecté,
                // nombre de contributeurs) — Pasteur/Secrétaire/Trésorier
                if (AppPermissions.canViewContributionsEvenement(user))
                  _MenuItem(
                    iconPath: SignmeAssets.managePubs,
                    label: 'Gérer les événements',
                    onTap: () => _navigate(context, AppRoutes.gestionEvenements),
                  ),

                // Contributions événement (vue trésorerie)
                if (AppPermissions.canViewContributionsEvenement(user))
                  _MenuItem(
                    iconPath: SignmeAssets.finances,
                    label: 'Contributions événement',
                    onTap: () => _navigate(context, AppRoutes.contributionsEvenement),
                  ),

                // Mes dépenses (tous rôles)
                _MenuItem(
                  iconPath: SignmeAssets.finances,
                  label: 'Mes dépenses',
                  onTap: () => _navigate(context, AppRoutes.mesDepenses),
                ),

                // Rapport Secrétaire
                if (user.role == 'secretaire' || user.role == 'pasteur')
                  _MenuItem(
                    iconPath: SignmeAssets.reportSec,
                    label: 'Rapport secrétaire',
                    onTap: () =>
                        _navigate(context, AppRoutes.rapportSecretaire),
                  ),

                const Divider(
                    height: 32,
                    indent: 20,
                    endIndent: 20,
                    color: SignmeColors.lightGrayBorder),
                _buildSectionTitle('OPTIONS SUPPLEMENTAIRES'),

                _MenuItem(
                  iconPath: SignmeAssets.settings,
                  label: 'Paramètres',
                  onTap: () => _navigate(context, AppRoutes.parametres),
                ),

                _MenuItem(
                  iconPath: SignmeAssets.logout,
                  label: 'Déconnexion',
                  iconColor: SignmeColors.error,
                  labelColor: SignmeColors.error,
                  onTap: () {
                    Scaffold.of(context).closeDrawer();
                    _showLogoutDialog(context, ref);
                  },
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(UserEntity user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SignmeColors.primaryDark, SignmeColors.primaryLight],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            child: Text(
              user.nom[0].toUpperCase(),
              style: SignmeTypography.headlineSmall
                  .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          Text(
            user.nom,
            style: SignmeTypography.labelLarge
                .copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            user.churchNom ?? ' EEC Communauté',
            style: SignmeTypography.bodySmall
                .copyWith(color: Colors.white.withValues(alpha: 0.7)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Text(
        title,
        style: SignmeTypography.labelSmall.copyWith(
          color: SignmeColors.mediumGray,
          letterSpacing: 1.2,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Scaffold.of(context).closeDrawer();
    context.go(route);
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        title: Text('Déconnexion',
            style: SignmeTypography.headlineSmall
                .copyWith(fontWeight: FontWeight.bold)),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () async {
              final success = await authNotifier.logout();
              if (!ctx.mounted) return;
              if (success) {
                Navigator.pop(ctx);
              } else {
                Navigator.pop(ctx);
                AppSnackbar.warning(
                  context,
                  'Connexion Internet requise pour se déconnecter.',
                );
              }
            },
            child: const Text('Déconnecter',
                style: TextStyle(
                    color: SignmeColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.iconColor = SignmeColors.primaryLight,
    this.labelColor = SignmeColors.black,
    this.badgeCount = 0,
  });

  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final Color iconColor;
  final Color labelColor;

  /// Nombre de badges non lus pour cet item (0 = pas de badge)
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            // ── Icône avec badge ─────────────────────────────────────────
            BadgeDot(
              count: badgeCount,
              child: Container(
                width: 36,
                height: 36,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(SignmeSpacing.radiusMd),
                ),
                child: Image.asset(iconPath,
                    color: iconColor, fit: BoxFit.contain),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: SignmeTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                  color: labelColor,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: labelColor.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
