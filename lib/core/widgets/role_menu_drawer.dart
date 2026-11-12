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
import '../../features/celebrations/presentation/providers/celebrations_provider.dart';
import '../../features/historique_personnel/presentation/providers/historique_personnel_combined_provider.dart';
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

                // Mon historique (tous rôles) — ex-onglet de la navbar, avec badge
                _MenuItem(
                  icon: Icons.history_rounded,
                  label: 'Mon historique',
                  badgeCount: badges.historique,
                  onTap: () {
                    ref.read(badgeNotifierProvider.notifier).markRead('historique');
                    // Rafraîchit l'année courante (cas majoritaire) — les
                    // autres années restent rafraîchissables dans l'écran.
                    ref
                        .read(historiquePersonnelCombinedProvider(DateTime.now().year.toString()).notifier)
                        .refresh();
                    _navigate(context, AppRoutes.historiquePersonnel);
                  },
                ),

                // Finances, sorties financières et retraits : réunis dans le service
                // « Gestion finance » (onglet Services).

                // Gestion des membres
                if (AppPermissions.canViewMembers(user))
                  _MenuItem(
                    iconPath: SignmeAssets.manageUsers,
                    label: 'Gérer utilisateurs',
                    onTap: () => _navigate(context, AppRoutes.users),
                  ),

                // Historique des signatures et rapport secrétaire : réunis dans le
                // service « Rapport signatures » (onglet Services).

                // Administration Pasteur
                if (user.role == 'pasteur') ...[
                  _MenuItem(
                    iconPath: SignmeAssets.serviceAnciens,
                    label: 'Anciens de services',
                    onTap: () =>
                        _navigate(context, AppRoutes.anciensDesignations),
                  ),
                ],

                // Créer / gérer les événements, leurs contributions et les publications :
                // réunis dans le service « Gestion actualités » (onglet Services).

                // Mes dépenses (tous rôles)
                _MenuItem(
                  iconPath: SignmeAssets.finances,
                  label: 'Mes dépenses',
                  onTap: () => _navigate(context, AppRoutes.mesDepenses),
                ),

                // Célébrations — anniversaire + occasions calendaires (tous rôles)
                _MenuItem(
                  icon: Icons.celebration_rounded,
                  label: 'Célébrations',
                  badgeCount: ref.watch(unreadCelebrationsCountProvider),
                  onTap: () => _navigate(context, AppRoutes.celebrations),
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
    // Le drawer Material joue sa propre animation de fermeture (~246ms,
    // Flutter DrawerController) qui reste au-dessus du contenu — si on
    // navigue en même temps, la transition vers la destination démarre EN
    // PARALLÈLE de cette fermeture : les deux animations tournent en même
    // temps et les éléments du menu restent visiblement superposés à
    // l'écran de destination pendant qu'il apparaît. On capture le router
    // AVANT de fermer (le contexte du drawer est démonté une fois fermé) et
    // on attend la fin de la fermeture avant de lancer la navigation.
    final router = GoRouter.of(context);
    Scaffold.of(context).closeDrawer();
    Future.delayed(const Duration(milliseconds: 250), () => router.go(route));
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
    this.iconPath,
    this.icon,
    required this.label,
    required this.onTap,
    this.iconColor = SignmeColors.primaryLight,
    this.labelColor = SignmeColors.black,
    this.badgeCount = 0,
  }) : assert(iconPath != null || icon != null, 'Fournir iconPath (asset) ou icon (Material).');

  /// Asset PNG monochrome teinté via [iconColor] — convention historique.
  final String? iconPath;

  /// Alternative Material Icons, pour un nouvel item sans asset dédié.
  final IconData? icon;
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
                child: icon != null
                    ? Icon(icon, color: iconColor, size: 20)
                    : Image.asset(iconPath!, color: iconColor, fit: BoxFit.contain),
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
