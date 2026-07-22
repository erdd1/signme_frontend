import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/users_provider.dart';
import '../utils/user_display_formatters.dart';

class UserDetailScreen extends ConsumerWidget {
  const UserDetailScreen({super.key, required this.userId});

  final int userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(authNotifierProvider).auth?.user;
    final asyncUser = ref.watch(userDetailProvider(userId));
    final isBusy = ref.watch(usersActionsProvider).isLoading;

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Fiche membre',
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          asyncUser.maybeWhen(
            data: (user) {
              if (currentUser == null) return const SizedBox.shrink();
              final canEdit = AppPermissions.canManageMembers(currentUser);
              if (!canEdit) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.edit_outlined,
                    color: SignmeColors.primaryLight),
                onPressed: () =>
                    context.push(AppRoutes.userEditPath(user.id)),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: asyncUser.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: SignmeColors.primaryLight),
        ),
        error: (e, _) => SignmeErrorState(
          title: 'Chargement impossible',
          message: messageFromError(e),
          onRetry: () => ref.invalidate(userDetailProvider(userId)),
        ),
        data: (user) => _UserDetailBody(
          user: user,
          currentUser: currentUser,
          isBusy: isBusy,
          onToggleStatus: () => _toggleStatus(context, ref, user),
        ),
      ),
    );
  }

  Future<void> _toggleStatus(
    BuildContext context,
    WidgetRef ref,
    UserEntity user,
  ) async {
    final current = ref.read(authNotifierProvider).auth?.user;
    if (current == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(user.actif ? 'Désactiver le compte ?' : 'Activer le compte ?'),
        content: Text(
          user.actif
              ? '${user.nom} ne pourra plus se connecter.'
              : '${user.nom} pourra à nouveau utiliser l\'application.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              user.actif ? 'Désactiver' : 'Activer',
              style: TextStyle(
                color: user.actif ? SignmeColors.error : SignmeColors.success,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      await ref.read(usersActionsProvider.notifier).toggleStatus(user.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.actif ? 'Compte désactivé' : 'Compte activé',
            ),
            backgroundColor: SignmeColors.success,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      final msg = e is AppException ? e.message : messageFromError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SignmeColors.error),
      );
    }
  }
}

class _UserDetailBody extends StatelessWidget {
  const _UserDetailBody({
    required this.user,
    required this.currentUser,
    required this.isBusy,
    required this.onToggleStatus,
  });

  final UserEntity user;
  final UserEntity? currentUser;
  final bool isBusy;
  final VoidCallback onToggleStatus;

  @override
  Widget build(BuildContext context) {
    final canToggle = currentUser != null &&
        AppPermissions.canToggleMemberStatus(
          currentUser!,
          targetId: user.id,
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        SignmeSpacing.lg,
        SignmeSpacing.md,
        SignmeSpacing.lg,
        120,
      ),
      child: Column(
        children: [
          ProfilePhotoAvatar(
            photoUrl: user.photoUrl,
            displayName: user.nom,
            radius: 48,
          ),
          const SizedBox(height: SignmeSpacing.lg),
          Text(
            user.nom,
            style: SignmeTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            user.roleLabel,
            style: SignmeTypography.labelMedium.copyWith(
              color: SignmeColors.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (user.churchNom != null) ...[
            const SizedBox(height: 4),
            Text(
              user.churchNom!,
              style: SignmeTypography.bodySmall.copyWith(
                color: SignmeColors.mediumGray,
              ),
            ),
          ],
          const SizedBox(height: SignmeSpacing.xl),
          _InfoCard(
            rows: [
              _InfoRow('Email', user.email),
              _InfoRow('Téléphone', user.telephone ?? '—'),
              _InfoRow('Profession', user.profession ?? '—'),
              _InfoRow('Sexe', formatSexeLabel(user.sexe)),
              _InfoRow('Date de naissance', formatIsoDateLabel(user.dateNaissance)),
              _InfoRow('Quartier de résidence', user.quartier?.nom ?? '—'),
              _InfoRow(
                'Ville de résidence',
                user.ville == null
                    ? '—'
                    : user.ville!.estDiaspora
                        ? '${user.ville!.nom} (Diaspora)'
                        : user.ville!.nom,
              ),
              _InfoRow('Originaire de', user.originaireDe ?? '—'),
              _InfoRow(
                'Groupes',
                user.groupes.isEmpty
                    ? '—'
                    : user.groupes.map((g) => g.nom).join(', '),
              ),
              _InfoRow(
                'Statut',
                user.actif ? 'Compte actif' : 'Compte inactif',
                valueColor: user.actif ? SignmeColors.success : SignmeColors.error,
              ),
            ],
          ),
          if (canToggle) ...[
            const SizedBox(height: SignmeSpacing.xl),
            SignmeSecondaryButton(
              label: user.actif ? 'Désactiver le compte' : 'Activer le compte',
              onPressed: isBusy ? null : onToggleStatus,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.rows});
  final List<_InfoRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            rows[i],
            if (i < rows.length - 1)
              Divider(
                height: SignmeSpacing.lg,
                color: SignmeColors.lightGrayBorder.withOpacity(0.6),
              ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: SignmeTypography.bodyMedium.copyWith(
              color: SignmeColors.mediumGray,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: SignmeTypography.labelMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? SignmeColors.black,
            ),
          ),
        ),
      ],
    );
  }
}
