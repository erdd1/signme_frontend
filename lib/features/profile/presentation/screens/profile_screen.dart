import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/utils/profile_image_picker.dart';
import '../../../../core/widgets/index.dart';
import '../../../users/presentation/providers/lookup_providers.dart';
import '../../../users/presentation/providers/users_provider.dart';
import '../../../users/presentation/utils/user_display_formatters.dart';
import '../../../users/presentation/widgets/add_lookup_bottom_sheet.dart';
import '../../../users/presentation/widgets/groupes_multi_select.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  File? _pendingPhotoFile;
  
  // Correction : Changement du type bool en int? pour le cache busting
  int? _bustPhotoCache;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authNotifierProvider.notifier).refreshProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final authState = ref.watch(authNotifierProvider);
    final UserEntity? user = authState.auth?.user;

    if (!authState.isAuthenticated || user == null) {
      return const SignmeLoader();
    }

    return RefreshIndicator(
      color: SignmeColors.primaryLight,
      onRefresh: () => ref.read(authNotifierProvider.notifier).refreshProfile(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(SignmeSpacing.lg, SignmeSpacing.lg, SignmeSpacing.lg, 120),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // === SECTION MON PROFIL ===
            _buildProfileHeader(context, user),
            const SizedBox(height: SignmeSpacing.xxxl),

            // === SECTION INFORMATIONS PERSONNELLES ===
            _buildSectionTitle('Informations Personnelles'),
            const SizedBox(height: SignmeSpacing.md),
            _buildPersonalInfoSection(context, user, ref),
            const SizedBox(height: SignmeSpacing.xxxl),

            // === SECTION PARAMÈTRES & SÉCURITÉ ===
            _buildSectionTitle('Notifications & Sécurité'),
            const SizedBox(height: SignmeSpacing.md),
            _buildSettingsSection(context, ref),
            const SizedBox(height: SignmeSpacing.xxxl),

            // === BOUTON DÉCONNEXION ===
            _buildLogoutButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, UserEntity user) {
    final canChangePhoto = AppPermissions.canChangeOwnProfilePhoto(user);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SignmeColors.primaryLight, SignmeColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      ),
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      child: Column(
        children: [
          ProfilePhotoAvatar(
            photoUrl: user.photoUrl,
            localFile: _pendingPhotoFile,
            displayName: user.nom,
            radius: 40,
            bustNetworkCache: _bustPhotoCache,
            onChangePhoto: canChangePhoto
                ? () => _pickAndUploadProfilePhoto(context, user)
                : null,
          ),
          if (canChangePhoto) ...[
            const SizedBox(height: SignmeSpacing.xs),
            Text(
              'Appuyez sur l\'icône pour changer votre photo',
              style: SignmeTypography.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: SignmeSpacing.lg),

          // === NOM ===
          Text(
            user.nom,
            style: SignmeTypography.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 24,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.sm),

          // === EMAIL ===
          Text(
            user.email,
            style: SignmeTypography.bodySmall.copyWith(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.md),

          // === RÔLE BADGE ===
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.md, vertical: SignmeSpacing.sm),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.4)),
            ),
            child: Text(
              user.roleLabel,
              style: SignmeTypography.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAndUploadProfilePhoto(
    BuildContext context,
    UserEntity user,
  ) async {
    try {
      final file = await ProfileImagePicker.pick(context);
      if (file == null || !mounted) return;

      setState(() => _pendingPhotoFile = file);

      await ref.read(usersActionsProvider.notifier).uploadPhoto(
            userId: user.id,
            photoFile: file,
          );

      if (mounted) {
        setState(() {
          _pendingPhotoFile = null;
          // Correction : Attribution du timestamp actuel pour forcer le rafraîchissement
          _bustPhotoCache = DateTime.now().millisecondsSinceEpoch;
        });
        await ref.read(authNotifierProvider.notifier).refreshProfile();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo de profil mise à jour'),
            backgroundColor: SignmeColors.success,
          ),
        );
      }
    } on ProfileImageTooLargeException catch (e) {
      if (!mounted) return;
      setState(() => _pendingPhotoFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: SignmeColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _pendingPhotoFile = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur : $e'),
          backgroundColor: SignmeColors.error,
        ),
      );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: SignmeTypography.headlineSmall.copyWith(
        color: SignmeColors.black,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context, UserEntity user, WidgetRef ref) {
    // TOUS les champs: éditables ET non-éditables
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder, width: 1),
      ),
      child: Column(
        children: [
          // === NOM - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.person_rounded,
            label: 'Nom',
            value: user.nom,
            editable: true,
            field: 'nom',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === EMAIL - NON ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.mail_rounded,
            label: 'Email',
            value: user.email,
            editable: false,
            field: 'email',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === ÉGLISE - NON ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.church_rounded,
            label: 'Église',
            value: user.churchNom ?? '(Non défini)',
            editable: false,
            field: 'churchId',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === RÔLE - NON ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.verified_rounded,
            label: 'Rôle',
            value: user.roleLabel,
            editable: false,
            field: 'role',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === TÉLÉPHONE - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.phone_rounded,
            label: 'Téléphone',
            value: user.telephone ?? '(Non défini)',
            editable: true,
            field: 'telephone',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === SEXE - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.wc_rounded,
            label: 'Sexe',
            value: formatSexeLabel(user.sexe),
            editable: true,
            field: 'sexe',
            user: user,
            ref: ref,
            onTap: () => _showSexeDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === DATE DE NAISSANCE - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.cake_rounded,
            label: 'Date de naissance',
            value: formatIsoDateLabel(user.dateNaissance),
            editable: true,
            field: 'dateNaissance',
            user: user,
            ref: ref,
            onTap: () => _showDateNaissanceDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === QUARTIER - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.home_rounded,
            label: 'Quartier de résidence',
            value: user.quartier?.nom ?? '(Non défini)',
            editable: true,
            field: 'quartierId',
            user: user,
            ref: ref,
            onTap: () => _showQuartierDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === VILLE - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.location_city_rounded,
            label: 'Ville de résidence',
            value: user.ville == null
                ? '(Non défini)'
                : user.ville!.estDiaspora
                    ? '${user.ville!.nom} (Diaspora)'
                    : user.ville!.nom,
            editable: true,
            field: 'villeId',
            user: user,
            ref: ref,
            onTap: () => _showVilleDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === PROFESSION - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.work_rounded,
            label: 'Profession',
            value: user.profession ?? '(Non défini)',
            editable: true,
            field: 'profession',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === GROUPES - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.group_rounded,
            label: 'Groupes',
            value: user.groupes.isEmpty
                ? '(Non défini)'
                : user.groupes.map((g) => g.nom).join(', '),
            editable: true,
            field: 'groupeIds',
            user: user,
            ref: ref,
            onTap: () => _showGroupesDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === ORIGINAIRE DE - ÉDITABLE ===
          _buildInfoField(
            context: context,
            icon: Icons.location_on_rounded,
            label: 'Originaire de',
            value: user.originaireDe ?? '(Non défini)',
            editable: true,
            field: 'originaireDe',
            user: user,
            ref: ref,
            onTap: () => _showOriginaireDeDialog(context, user, ref),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === DATE CONFIRMATION - LECTURE SEULE ===
          _buildInfoField(
            context: context,
            icon: Icons.event_rounded,
            label: 'Date de confirmation',
            value: user.dateConfirmation ?? '(Non défini)',
            editable: true,
            field: 'dateConfirmation',
            user: user,
            ref: ref,
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),

          // === LIEU CONFIRMATION - LECTURE SEULE ===
          _buildInfoField(
            context: context,
            icon: Icons.place_rounded,
            label: 'Lieu de confirmation',
            value: user.lieuConfirmation ?? '(Non défini)',
            editable: true,
            field: 'lieuConfirmation',
            user: user,
            ref: ref,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required bool editable,
    required String field,
    required UserEntity user,
    required WidgetRef ref,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: editable
          ? (onTap ?? () => _showEditDialog(context, label, value, field, user, ref))
          : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
        child: Row(
          children: [
            // === ICÔNE ===
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SignmeColors.accentSky,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Icon(icon, size: 20, color: SignmeColors.primaryLight),
            ),
            const SizedBox(width: SignmeSpacing.md),

            // === LABEL & VALEUR ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SignmeTypography.bodyMedium.copyWith(
                      color: SignmeColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: SignmeTypography.bodySmall.copyWith(
                      color: editable ? SignmeColors.primaryLight : SignmeColors.mediumGray,
                      fontSize: 12,
                      fontWeight: editable ? FontWeight.w500 : FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // === ICÔNE ÉDITION OU VERROUILLAGE ===
            if (editable)
              const Icon(Icons.edit_rounded, color: SignmeColors.primaryLight, size: 20)
            else
              Icon(Icons.lock_rounded, color: SignmeColors.darkGray.withOpacity(0.5), size: 18),
          ],
        ),
      ),
    );
  }

  /// Envoie un patch de profil et affiche le résultat (succès/erreur) —
  /// réutilisé par tous les dialogs d'édition (génériques et structurés).
  Future<void> _submitProfileField(
    BuildContext context,
    WidgetRef ref,
    Map<String, dynamic> payload,
  ) async {
    final result = await ref.read(submitProfileUpdateProvider(payload).future);
    if (!context.mounted) return;
    result.fold(
      (failure) => AppSnackbar.error(context, failure.message),
      (_) => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil mis à jour avec succès'),
          backgroundColor: SignmeColors.success,
          duration: Duration(seconds: 3),
        ),
      ),
    );
  }

  Widget _dialogTitle(String label, IconData icon) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: SignmeColors.primaryLight.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          ),
          child: Icon(icon, color: SignmeColors.primaryLight, size: 22),
        ),
        const SizedBox(width: SignmeSpacing.md),
        Expanded(
          child: Text(
            'Modifier $label',
            style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );
  }

  void _showSexeDialog(BuildContext context, UserEntity user, WidgetRef ref) {
    String? sexe = user.sexe;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
          backgroundColor: SignmeColors.white,
          title: _dialogTitle('Sexe', Icons.wc_rounded),
          content: Row(
            children: [
              Expanded(
                child: _DialogChoiceChip(
                  label: 'Homme',
                  selected: sexe == 'homme',
                  onTap: () => setState(() => sexe = 'homme'),
                ),
              ),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(
                child: _DialogChoiceChip(
                  label: 'Femme',
                  selected: sexe == 'femme',
                  onTap: () => setState(() => sexe = 'femme'),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.all(SignmeSpacing.lg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text('Annuler', style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.primaryLight)),
            ),
            ElevatedButton(
              onPressed: sexe == null
                  ? null
                  : () {
                      Navigator.pop(dialogContext);
                      _submitProfileField(context, ref, {'sexe': sexe});
                    },
              style: ElevatedButton.styleFrom(backgroundColor: SignmeColors.primaryLight),
              child: const Text('Enregistrer', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDateNaissanceDialog(BuildContext context, UserEntity user, WidgetRef ref) async {
    final current = user.dateNaissance != null ? DateTime.tryParse(user.dateNaissance!) : null;
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? DateTime(DateTime.now().year - 20),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Date de naissance',
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: Theme.of(context).colorScheme.copyWith(primary: SignmeColors.primaryLight),
        ),
        child: child!,
      ),
    );
    if (picked == null || !context.mounted) return;
    final iso = '${picked.year.toString().padLeft(4, '0')}-'
        '${picked.month.toString().padLeft(2, '0')}-'
        '${picked.day.toString().padLeft(2, '0')}';
    await _submitProfileField(context, ref, {'dateNaissance': iso});
  }

  Future<void> _showOriginaireDeDialog(BuildContext context, UserEntity user, WidgetRef ref) async {
    final region = await showSignmePickerSheet<String>(
      context: context,
      title: 'Originaire de',
      items: AppStrings.regionsCameroun,
      itemLabel: (r) => r,
      selected: user.originaireDe,
    );
    if (region == null || !context.mounted) return;
    await _submitProfileField(context, ref, {'originaireDe': region});
  }

  Future<void> _showQuartierDialog(BuildContext context, UserEntity user, WidgetRef ref) async {
    final canManage = AppPermissions.canManageMembers(user);
    final quartiers = ref.read(quartiersListProvider).valueOrNull ?? const <QuartierRef>[];
    final selected = await showSignmePickerSheet<QuartierRef>(
      context: context,
      title: 'Quartier de résidence',
      items: quartiers,
      itemLabel: (q) => q.nom,
      selected: user.quartier,
      onAddNew: canManage
          ? () => showAddLookupBottomSheet<QuartierRef>(
                context: context,
                title: 'Nouveau quartier',
                hint: 'Ex. Essos',
                onSubmit: (nom, _) async {
                  final created = await ref.read(quartiersRemoteDataSourceProvider).create(nom);
                  ref.read(quartiersListProvider.notifier).addItem(created);
                  return created;
                },
              )
          : null,
      onDelete: canManage
          ? (q) async {
              await ref.read(quartiersRemoteDataSourceProvider).delete(q.id);
              ref.read(quartiersListProvider.notifier).removeItem(q);
            }
          : null,
      deleteConfirmMessage: (q) =>
          'Supprimer le quartier "${q.nom}" ? Les membres qui l\'utilisent seront simplement dissociés.',
    );
    if (selected == null || !context.mounted) return;
    await _submitProfileField(context, ref, {'quartierId': selected.id});
  }

  Future<void> _showVilleDialog(BuildContext context, UserEntity user, WidgetRef ref) async {
    final canManage = AppPermissions.canManageMembers(user);
    final villes = ref.read(villesListProvider).valueOrNull ?? const <VilleRef>[];
    final selected = await showSignmePickerSheet<VilleRef>(
      context: context,
      title: 'Ville de résidence',
      items: villes,
      itemLabel: (v) => v.estDiaspora ? '${v.nom} (Diaspora)' : v.nom,
      selected: user.ville,
      onAddNew: canManage
          ? () => showAddLookupBottomSheet<VilleRef>(
                context: context,
                title: 'Nouvelle ville',
                hint: 'Ex. Douala',
                showDiasporaToggle: true,
                onSubmit: (nom, estDiaspora) async {
                  final created = await ref
                      .read(villesRemoteDataSourceProvider)
                      .create(nom, estDiaspora: estDiaspora);
                  ref.read(villesListProvider.notifier).addItem(created);
                  return created;
                },
              )
          : null,
      onDelete: canManage
          ? (v) async {
              await ref.read(villesRemoteDataSourceProvider).delete(v.id);
              ref.read(villesListProvider.notifier).removeItem(v);
            }
          : null,
      deleteConfirmMessage: (v) =>
          'Supprimer la ville "${v.nom}" ? Les membres qui l\'utilisent seront simplement dissociés.',
    );
    if (selected == null || !context.mounted) return;
    await _submitProfileField(context, ref, {'villeId': selected.id});
  }

  void _showGroupesDialog(BuildContext context, UserEntity user, WidgetRef ref) {
    final canManage = AppPermissions.canManageMembers(user);
    Set<int> selectedIds = user.groupes.map((g) => g.id).toSet();
    int? principalId = user.groupePrincipal?.id;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Consumer(
        builder: (sheetContext, sheetRef, _) {
          final groupesAsync = sheetRef.watch(groupesListProvider);
          return StatefulBuilder(
            builder: (sheetContext, setState) => Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(sheetContext).viewInsets.bottom),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(sheetContext).size.height * 0.8),
                decoration: const BoxDecoration(
                  color: SignmeColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(SignmeSpacing.radiusXl)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    SignmeSpacing.lg,
                    SignmeSpacing.lg,
                    SignmeSpacing.lg,
                    SignmeSpacing.navbarClearance,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: SignmeSpacing.lg),
                          decoration: BoxDecoration(
                            color: SignmeColors.lightGrayBorder,
                            borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
                          ),
                        ),
                      ),
                      Text('Groupes', style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: SignmeSpacing.lg),
                      groupesAsync.when(
                        loading: () => const Center(child: CircularProgressIndicator(color: SignmeColors.primaryLight)),
                        error: (e, _) => Text('Chargement impossible', style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error)),
                        data: (groupes) => GroupesMultiSelect(
                          groupes: groupes,
                          selectedIds: selectedIds,
                          principalId: principalId,
                          onAddPressed: canManage
                              ? () async {
                                  final created = await showAddLookupBottomSheet<GroupeRef>(
                                    context: sheetContext,
                                    title: 'Nouveau groupe',
                                    hint: 'Ex. Chorale',
                                    onSubmit: (nom, _) async {
                                      final created = await sheetRef.read(groupesRemoteDataSourceProvider).create(nom);
                                      sheetRef.read(groupesListProvider.notifier).addItem(created);
                                      return created;
                                    },
                                  );
                                  if (created != null) {
                                    setState(() {
                                      selectedIds = {...selectedIds, created.id};
                                      principalId ??= created.id;
                                    });
                                  }
                                }
                              : null,
                          onDelete: canManage
                              ? (g) async {
                                  await sheetRef.read(groupesRemoteDataSourceProvider).delete(g.id);
                                  sheetRef.read(groupesListProvider.notifier).removeItem(g);
                                  setState(() {
                                    selectedIds = {...selectedIds}..remove(g.id);
                                    if (principalId == g.id) {
                                      principalId = selectedIds.isNotEmpty ? selectedIds.first : null;
                                    }
                                  });
                                }
                              : null,
                          onChanged: (ids, principal) => setState(() {
                            selectedIds = ids;
                            principalId = principal;
                          }),
                        ),
                      ),
                      const SizedBox(height: SignmeSpacing.xl),
                      SignmePrimaryButton(
                        label: 'Enregistrer',
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          _submitProfileField(context, ref, {
                            'groupeIds': selectedIds.toList(),
                            if (principalId != null) 'groupePrincipalId': principalId,
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    String label,
    String currentValue,
    String field,
    UserEntity user,
    WidgetRef ref,
  ) {
    final controller = TextEditingController(
      text: currentValue == '(Non défini)' ? '' : currentValue,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SignmeColors.primaryLight.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: const Icon(Icons.edit_rounded, color: SignmeColors.primaryLight, size: 22),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Text(
                'Modifier $label',
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Entrez la nouvelle valeur pour $label',
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
              ),
              const SizedBox(height: SignmeSpacing.lg),
              TextField(
                controller: controller,
                decoration: InputDecoration(
                  labelText: label,
                  hintText: 'Entrez $label',
                  prefixIcon: const Icon(Icons.edit_rounded, color: SignmeColors.primaryLight, size: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                    borderSide: const BorderSide(color: SignmeColors.lightGrayBorder),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                    borderSide: const BorderSide(color: SignmeColors.primaryLight, width: 2),
                  ),
                ),
              ),
            ],
          ),
        ),
        actionsPadding: const EdgeInsets.all(SignmeSpacing.lg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.sm),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
            ),
            child: Text(
              'Annuler',
              style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.primaryLight, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Le champ ne peut pas être vide')),
                );
                return;
              }

              // Fermer le dialog et montrer loading
              try {
                Navigator.pop(dialogContext);
              } catch (_) {}
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                      ),
                      SizedBox(width: SignmeSpacing.md),
                      Text('Mise à jour en cours...'),
                    ],
                  ),
                  backgroundColor: SignmeColors.primaryLight,
                  duration: Duration(minutes: 1),
                ),
              );

              final result = await ref.read(
                submitProfileUpdateProvider({field: newValue}).future,
              );
              
              if (context.mounted) {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                result.fold(
                  (failure) {
                    // Erreur
                    AppSnackbar.error(context, failure.message);
                  },
                  (updatedUser) {
                    // Succès - afficher le message avec le champ mis à jour
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$field mis à jour avec succès'),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  },
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SignmeColors.primaryLight,
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.sm),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
              elevation: 0,
            ),
            child: Text(
              'Enregistrer',
              style: SignmeTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSettingsSection(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: SignmeColors.white,
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.lightGrayBorder, width: 1),
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.lock_rounded,
            label: 'Changer le mot de passe',
            value: '••••••••',
            showChevron: true,
            onTap: () => context.push(AppRoutes.changePassword),
          ),
          const Divider(height: 1, color: SignmeColors.lightGrayBorder, indent: SignmeSpacing.lg, endIndent: SignmeSpacing.lg),
          _buildSettingItem(
            icon: Icons.notifications_rounded,
            label: 'Notifications',
            value: 'Activé',
            showChevron: true,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notifications non disponible...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.md),
        child: Row(
          children: [
            // === ICÔNE ===
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: SignmeColors.accentSky,
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: Icon(icon, size: 20, color: SignmeColors.primaryLight),
            ),
            const SizedBox(width: SignmeSpacing.md),

            // === LABEL & VALEUR ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: SignmeTypography.bodyMedium.copyWith(
                      color: SignmeColors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: SignmeTypography.bodySmall.copyWith(
                      color: SignmeColors.mediumGray,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // === CHEVRON ===
            if (showChevron) Icon(Icons.chevron_right_rounded, color: SignmeColors.mediumGray.withOpacity(0.5), size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return ElevatedButton.icon(
      onPressed: () => _confirmLogout(context, ref),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text('Déconnexion', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      style: ElevatedButton.styleFrom(
        backgroundColor: SignmeColors.error,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: SignmeSpacing.md),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        elevation: 0,
      ),
    );
  }

  void _confirmLogout(BuildContext ctx, WidgetRef ref) {
    // AVANT tout: capturer la référence du notifier
    final authNotifier = ref.read(authNotifierProvider.notifier);

    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg)),
        backgroundColor: SignmeColors.white,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: SignmeColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
              ),
              child: const Icon(Icons.logout_rounded, color: SignmeColors.error, size: 22),
            ),
            const SizedBox(width: SignmeSpacing.md),
            Expanded(
              child: Text(
                'Déconnexion',
                style: SignmeTypography.headlineSmall.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(
          'Êtes-vous sûr de vouloir vous déconnecter ?',
          style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.mediumGray),
        ),
        actionsPadding: const EdgeInsets.all(SignmeSpacing.lg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(_),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.sm),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
            ),
            child: Text(
              'Annuler',
              style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.primaryLight, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Utiliser la référence capturée, pas ref.read()
              final success = await authNotifier.logout();
              if (!_.mounted) return;
              Navigator.pop(_);
              if (!success && ctx.mounted) {
                AppSnackbar.warning(
                  ctx,
                  'Connexion Internet requise pour se déconnecter.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: SignmeColors.error,
              padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.lg, vertical: SignmeSpacing.sm),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd)),
              elevation: 0,
            ),
            child: Text(
              'Déconnecter',
              style: SignmeTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

}

class _DialogChoiceChip extends StatelessWidget {
  const _DialogChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? SignmeColors.primaryLight : SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
          border: Border.all(
            color: selected ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
          ),
        ),
        child: Text(
          label,
          style: SignmeTypography.labelMedium.copyWith(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? Colors.white : SignmeColors.black,
          ),
        ),
      ),
    );
  }
}
