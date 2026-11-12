import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../badge/domain/entities/badge_count_entity.dart';
import '../../../badge/presentation/providers/badge_provider.dart';
import '../../domain/gestion_action.dart';

/// Écran d'un service de gestion (« Gestion actualités », « Gestion finance ») :
/// les actions existantes du menu réunies en un seul endroit. Chaque carte
/// ouvre l'écran existant, inchangé.
class GestionServiceScreen extends ConsumerWidget {
  const GestionServiceScreen({
    super.key,
    required this.titre,
    required this.messageRefus,
    required this.actionsPour,
  });

  final String titre;
  final String messageRefus;
  final List<GestionAction> Function(UserEntity user) actionsPour;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).auth?.user;
    final actions = user == null ? const <GestionAction>[] : actionsPour(user);
    final badges = ref.watch(badgeNotifierProvider).valueOrNull ?? BadgeCountEntity.empty;

    final bottom = MediaQuery.of(context).padding.bottom + SignmeSpacing.xl;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.services),
        ),
      ),
      body: actions.isEmpty
          ? SignmeNoPermissionState(
              title: 'Accès réservé',
              message: messageRefus,
              icon: Icons.lock_outline_rounded,
            )
          : ListView(
              padding: EdgeInsets.fromLTRB(SignmeSpacing.lg, 0, SignmeSpacing.lg, bottom),
              children: [
                Text(
                  titre,
                  style: SignmeTypography.displaySmall.copyWith(fontWeight: FontWeight.w900, height: 1.2),
                ),
                const SizedBox(height: SignmeSpacing.lg),
                for (var i = 0; i < actions.length; i++) ...[
                  // Titre de rubrique au premier élément de chaque rubrique.
                  if (actions[i].section != null && (i == 0 || actions[i - 1].section != actions[i].section))
                    Padding(
                      padding: EdgeInsets.only(bottom: SignmeSpacing.sm, top: i == 0 ? 0 : SignmeSpacing.sm),
                      child: Text(
                        actions[i].section!,
                        style: SignmeTypography.labelLarge
                            .copyWith(color: SignmeColors.textSecondary, fontWeight: FontWeight.w700),
                      ),
                    ),
                  _ActionCard(
                    action: actions[i],
                    badgeCount: badges.countFor(actions[i].badgeType ?? ''),
                    onTap: () => _ouvrir(context, ref, actions[i]),
                  ),
                  if (i < actions.length - 1) const SizedBox(height: SignmeSpacing.md),
                ],
              ],
            ),
    );
  }

  /// Un onglet de l'application (Finances) s'ouvre comme avant depuis le menu ;
  /// les autres écrans s'empilent pour revenir ici avec le retour.
  void _ouvrir(BuildContext context, WidgetRef ref, GestionAction action) {
    final badge = action.badgeType;
    if (badge != null) ref.read(badgeNotifierProvider.notifier).markRead(badge);

    if (action.estOnglet) {
      context.go(action.route);
    } else {
      context.push(action.route);
    }
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action, required this.badgeCount, required this.onTap});

  final GestionAction action;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '${action.titre}. ${action.description}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(SignmeSpacing.lg),
          decoration: BoxDecoration(
            color: SignmeColors.white,
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
            border: Border.all(color: SignmeColors.lightGrayBorder),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
          ),
          child: Row(
            children: [
              BadgeDot(
                count: badgeCount,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: SignmeColors.accentSky,
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  ),
                  child: Icon(action.icone, color: SignmeColors.primaryLight, size: 24),
                ),
              ),
              const SizedBox(width: SignmeSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(action.titre, style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.w800, fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(
                      action.description,
                      style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.textSecondary, height: 1.3),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: SignmeColors.mediumGray),
            ],
          ),
        ),
      ),
    );
  }
}
