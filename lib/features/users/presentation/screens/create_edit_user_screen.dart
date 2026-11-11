import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/design_system/index.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/network/dio_exception_mapper.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/utils/profile_image_picker.dart';
import '../../../../core/widgets/index.dart';
import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/user_roles.dart';
import '../providers/lookup_providers.dart';
import '../providers/users_data_providers.dart';
import '../providers/users_provider.dart';
import '../widgets/add_lookup_bottom_sheet.dart';
import '../widgets/groupes_multi_select.dart';

class CreateEditUserScreen extends ConsumerStatefulWidget {
  const CreateEditUserScreen({super.key, this.userId});

  final int? userId;

  @override
  ConsumerState<CreateEditUserScreen> createState() =>
      _CreateEditUserScreenState();
}

class _CreateEditUserScreenState extends ConsumerState<CreateEditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  final _matriculeCtrl = TextEditingController();

  String? _selectedRole;
  bool _isEdit = false;
  bool _prefilled = false;
  bool _isPrefilling = false;
  File? _photoFile;
  String? _existingPhotoUrl;

  // ── Démographie ──────────────────────────────────────────────────────────
  String? _sexe;

  /// Statut communiant — uniquement pertinent (et obligatoire) pour le rôle
  /// paroissien ; les autres rôles sont et seront toujours communiants.
  /// `null` = pas encore choisi (bloque la soumission pour un paroissien).
  bool? _estCommuniant;
  bool _matriculeAutoMode = true;
  bool _isFetchingMatricule = false;
  DateTime? _dateNaissance;
  String? _originaireDe;
  QuartierRef? _quartier;
  VilleRef? _ville;
  /// groupeId → postes cochés (vide = simple membre)
  Map<int, Set<String>> _groupes = {};

  @override
  void initState() {
    super.initState();
    // Nouvel écran de formulaire : jamais de saisie non enregistrée en
    // attente d'un précédent passage.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(formDirtyProvider.notifier).state = false;
    });
    for (final controller in [_nomCtrl, _emailCtrl, _telCtrl, _professionCtrl, _matriculeCtrl]) {
      controller.addListener(_markDirty);
    }
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _professionCtrl.dispose();
    _matriculeCtrl.dispose();
    super.dispose();
  }

  /// Point d'écriture unique du drapeau global — appelé par tout champ
  /// modifié par l'utilisateur (texte, rôle, sexe, date, listes, photo).
  void _markDirty() {
    if (_isPrefilling) return;
    if (!ref.read(formDirtyProvider)) {
      ref.read(formDirtyProvider.notifier).state = true;
    }
  }

  List<String> _creatableRoles(String creatorRole) =>
      UserCreatableRoles.forCreator(creatorRole);

  DateTime? _parseIsoDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  void _prefillFrom(UserEntity user) {
    // Le préremplissage en mode édition modifie les contrôleurs (donc
    // déclenche leurs listeners) sans être une vraie saisie utilisateur —
    // ne doit jamais marquer le formulaire comme modifié.
    _isPrefilling = true;
    _nomCtrl.text = user.nom;
    _emailCtrl.text = user.email;
    _telCtrl.text = user.telephone ?? '';
    _professionCtrl.text = user.profession ?? '';
    _selectedRole = user.role;
    _existingPhotoUrl = user.photoUrl;
    _sexe = user.sexe;
    _estCommuniant = user.estCommuniant;
    _matriculeCtrl.text = user.matricule ?? '';
    _matriculeAutoMode = false;
    _dateNaissance = _parseIsoDate(user.dateNaissance);
    _originaireDe = user.originaireDe;
    _quartier = user.quartier;
    _ville = user.ville;
    _groupes = {for (final g in user.groupes) g.id: g.postes.toSet()};
    _isPrefilling = false;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authNotifierProvider).auth?.user;
    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Session expirée')),
      );
    }

    _isEdit = widget.userId != null;
    final isSaving = ref.watch(usersActionsProvider).isLoading;

    if (_isEdit) {
      final asyncUser = ref.watch(userDetailProvider(widget.userId!));
      return asyncUser.when(
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: SignmeColors.primaryLight),
          ),
        ),
        error: (e, _) => _scaffoldWithError(e.toString()),
        data: (user) {
          if (!_prefilled) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) {
                setState(() {
                  _prefillFrom(user);
                  _prefilled = true;
                });
              }
            });
          }
          return _buildScaffold(
            currentUser,
            isSaving,
            showRoleField: AppPermissions.canEditMemberRole(currentUser),
          );
        },
      );
    }

    return _buildScaffold(currentUser, isSaving, showRoleField: true);
  }

  Widget _scaffoldWithError(String message) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SignmeErrorState(
        title: 'Membre introuvable',
        message: message,
        onRetry: () => ref.invalidate(userDetailProvider(widget.userId!)),
      ),
    );
  }

  Widget _buildScaffold(
    UserEntity currentUser,
    bool isSaving, {
    required bool showRoleField,
  }) {
    final roles = _creatableRoles(currentUser.role);
    final displayRoleField = showRoleField && roles.isNotEmpty;
    final targetId = widget.userId ?? 0;
    final canUploadPhoto = _isEdit
        ? AppPermissions.canUploadMemberPhoto(
            currentUser,
            targetUserId: targetId,
          )
        : AppPermissions.canManageMembers(currentUser);
    final canManageLookups = AppPermissions.canManageMembers(currentUser);

    final quartiersAsync = ref.watch(quartiersListProvider);
    final villesAsync = ref.watch(villesListProvider);
    final groupesAsync = ref.watch(groupesListProvider);

    return SignmeUnsavedChangesGuard(
      child: Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: isSaving ? null : () => context.pop(),
        ),
        title: Text(
          _isEdit ? 'Modifier le membre' : 'Nouveau membre',
          style: SignmeTypography.labelLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            SignmeSpacing.lg,
            SignmeSpacing.md,
            SignmeSpacing.lg,
            120,
          ),
          children: [
            if (canUploadPhoto) ...[
              Center(
                child: Column(
                  children: [
                    ProfilePhotoAvatar(
                      photoUrl: _existingPhotoUrl,
                      localFile: _photoFile,
                      displayName: _nomCtrl.text.trim().isEmpty
                          ? 'Photo du membre'
                          : _nomCtrl.text.trim(),
                      radius: 48,
                      onChangePhoto: isSaving ? null : () => _pickPhoto(context),
                    ),
                    const SizedBox(height: SignmeSpacing.sm),
                    Text(
                      'Photo de profil (optionnel)',
                      style: SignmeTypography.labelSmall.copyWith(
                        color: SignmeColors.mediumGray,
                      ),
                    ),
                    const SizedBox(height: SignmeSpacing.lg),
                  ],
                ),
              ),
            ],
            if (displayRoleField) ...[
              SignmeCompactDropdown<String>(
                label: 'Rôle du membre',
                value: _selectedRole,
                items: roles,
                itemLabel: UserCreatableRoles.label,
                hint: 'Sélectionnez un rôle',
                enabled: !isSaving,
                onChanged: (v) {
                  _markDirty();
                  setState(() {
                    _selectedRole = v;
                    // Un paroissien peut être non communiant, les autres
                    // rôles sont toujours communiants (imposé côté backend).
                    if (v != 'paroissien') _estCommuniant = null;
                  });
                },
              ),
              const SizedBox(height: SignmeSpacing.lg),
            ],
            if (_selectedRole == 'paroissien') ...[
              Text(
                'Statut',
                style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: SignmeSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _SexeChip(
                      label: 'Communiant',
                      selected: _estCommuniant == true,
                      onTap: isSaving
                          ? null
                          : () {
                              _markDirty();
                              setState(() => _estCommuniant = true);
                            },
                    ),
                  ),
                  const SizedBox(width: SignmeSpacing.sm),
                  Expanded(
                    child: _SexeChip(
                      label: 'Non communiant',
                      selected: _estCommuniant == false,
                      onTap: isSaving
                          ? null
                          : () {
                              _markDirty();
                              setState(() => _estCommuniant = false);
                            },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SignmeSpacing.lg),
            ],
            SignmeTextInput(
              label: 'Nom complet',
              hint: 'Ex. Jean Dupont',
              controller: _nomCtrl,
              enabled: !isSaving,
              validator: (v) =>
                  v == null || v.trim().length < 2 ? 'Nom requis' : null,
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmeTextInput(
              label: 'Email',
              hint: 'email@exemple.com',
              controller: _emailCtrl,
              enabled: !_isEdit && !isSaving,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email requis';
                if (!v.contains('@')) return 'Email invalide';
                return null;
              },
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmeTextInput(
              label: 'Téléphone',
              hint: '6XX XXX XXX',
              controller: _telCtrl,
              enabled: !isSaving,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: SignmeSpacing.lg),
            SignmeTextInput(
              label: 'Profession',
              hint: 'Optionnel',
              controller: _professionCtrl,
              enabled: !isSaving,
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Sexe ─────────────────────────────────────────────────────
            Text(
              'Sexe',
              style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SignmeSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SexeChip(
                    label: 'Homme',
                    selected: _sexe == 'homme',
                    onTap: isSaving
                        ? null
                        : () {
                            _markDirty();
                            setState(() => _sexe = 'homme');
                            if (_matriculeAutoMode) _fetchNextMatricule();
                          },
                  ),
                ),
                const SizedBox(width: SignmeSpacing.sm),
                Expanded(
                  child: _SexeChip(
                    label: 'Femme',
                    selected: _sexe == 'femme',
                    onTap: isSaving
                        ? null
                        : () {
                            _markDirty();
                            setState(() => _sexe = 'femme');
                            if (_matriculeAutoMode) _fetchNextMatricule();
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Identifiant (matricule) ──────────────────────────────────
            Text(
              'Identifiant',
              style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: SignmeSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _SexeChip(
                    label: 'Génération automatique',
                    selected: _matriculeAutoMode,
                    onTap: isSaving
                        ? null
                        : () {
                            _markDirty();
                            setState(() => _matriculeAutoMode = true);
                            _fetchNextMatricule();
                          },
                  ),
                ),
                const SizedBox(width: SignmeSpacing.sm),
                Expanded(
                  child: _SexeChip(
                    label: 'Saisie manuelle',
                    selected: !_matriculeAutoMode,
                    onTap: isSaving
                        ? null
                        : () {
                            _markDirty();
                            setState(() => _matriculeAutoMode = false);
                          },
                  ),
                ),
              ],
            ),
            const SizedBox(height: SignmeSpacing.sm),
            if (_sexe == null)
              Text(
                'Sélectionnez le sexe pour définir l\'identifiant.',
                style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.mediumGray),
              )
            else if (_matriculeAutoMode)
              Container(
                padding: SignmeSpacing.inputPadding,
                decoration: BoxDecoration(
                  color: SignmeColors.background,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  border: Border.all(color: SignmeColors.lightGrayBorder),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isFetchingMatricule
                            ? 'Génération en cours…'
                            : (_matriculeCtrl.text.isEmpty
                                ? '—'
                                : _matriculeCtrl.text),
                        style: SignmeTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _isFetchingMatricule
                              ? SignmeColors.mediumGray
                              : SignmeColors.black,
                        ),
                      ),
                    ),
                    if (_isFetchingMatricule)
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        onPressed: isSaving ? null : _fetchNextMatricule,
                        tooltip: 'Régénérer',
                      ),
                  ],
                ),
              )
            else
              SignmeTextInput(
                label: '',
                hint: 'Ex. H011 ou F112',
                controller: _matriculeCtrl,
                enabled: !isSaving,
                inputFormatters: [
                  _UpperCaseTextFormatter(),
                  FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) {
                  final value = v?.trim() ?? '';
                  if (value.isEmpty) return 'Identifiant requis';
                  if (!RegExp(r'^[HF]\d{3}$').hasMatch(value)) {
                    return 'Format attendu : H001-H999 ou F001-F999';
                  }
                  final expectedPrefix = _sexe == 'femme' ? 'F' : 'H';
                  if (value[0] != expectedPrefix) {
                    return 'Doit commencer par "$expectedPrefix" pour ce sexe';
                  }
                  return null;
                },
              ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Date de naissance ────────────────────────────────────────
            SignmeDatePickerField(
              label: 'Date de naissance',
              value: _dateNaissance,
              enabled: !isSaving,
              onChanged: (d) {
                _markDirty();
                setState(() => _dateNaissance = d);
              },
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Originaire de (région) ───────────────────────────────────
            SignmeCompactDropdown<String>(
              label: 'Originaire de',
              value: _originaireDe,
              items: AppStrings.regionsCameroun,
              itemLabel: (r) => r,
              enabled: !isSaving,
              onChanged: (v) {
                _markDirty();
                setState(() => _originaireDe = v);
              },
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Quartier de résidence ────────────────────────────────────
            quartiersAsync.when(
              loading: () => const _LoadingLookupField(label: 'Quartier de résidence'),
              error: (e, _) => _LookupErrorField(
                label: 'Quartier de résidence',
                onRetry: () => ref.read(quartiersListProvider.notifier).load(),
              ),
              data: (quartiers) => SignmeCompactDropdown<QuartierRef>(
                label: 'Quartier de résidence',
                value: quartiers.any((q) => q.id == _quartier?.id) ? _quartier : null,
                items: quartiers,
                itemLabel: (q) => q.nom,
                enabled: !isSaving,
                onChanged: (v) {
                  _markDirty();
                  setState(() => _quartier = v);
                },
                onAddNew: canManageLookups ? () => _addQuartier(context) : null,
                onDelete: canManageLookups ? (q) => _deleteQuartier(q) : null,
                deleteConfirmMessage: (q) =>
                    'Supprimer le quartier "${q.nom}" ? Les membres qui l\'utilisent seront simplement dissociés.',
              ),
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Ville de résidence ───────────────────────────────────────
            villesAsync.when(
              loading: () => const _LoadingLookupField(label: 'Ville de résidence'),
              error: (e, _) => _LookupErrorField(
                label: 'Ville de résidence',
                onRetry: () => ref.read(villesListProvider.notifier).load(),
              ),
              data: (villes) => SignmeCompactDropdown<VilleRef>(
                label: 'Ville de résidence',
                value: villes.any((v) => v.id == _ville?.id) ? _ville : null,
                items: villes,
                itemLabel: (v) => v.estDiaspora ? '${v.nom} (Diaspora)' : v.nom,
                enabled: !isSaving,
                onChanged: (v) {
                  _markDirty();
                  setState(() => _ville = v);
                },
                onAddNew: canManageLookups ? () => _addVille(context) : null,
                onDelete: canManageLookups ? (v) => _deleteVille(v) : null,
                deleteConfirmMessage: (v) =>
                    'Supprimer la ville "${v.nom}" ? Les membres qui l\'utilisent seront simplement dissociés.',
              ),
            ),
            const SizedBox(height: SignmeSpacing.lg),

            // ── Groupes (multi-sélection + poste dans chaque groupe) ────────────
            groupesAsync.when(
              loading: () => const _LoadingLookupField(label: 'Groupes'),
              error: (e, _) => _LookupErrorField(
                label: 'Groupes',
                onRetry: () => ref.read(groupesListProvider.notifier).load(),
              ),
              data: (groupes) => GroupesMultiSelect(
                groupes: groupes,
                selected: _groupes,
                enabled: !isSaving,
                onAddPressed: canManageLookups ? () => _addGroupe(context) : null,
                onDelete: canManageLookups ? (g) => _deleteGroupe(g) : null,
                onChanged: (selected) {
                  _markDirty();
                  setState(() => _groupes = selected);
                },
              ),
            ),
            const SizedBox(height: SignmeSpacing.xxl),
            SignmePrimaryButton(
              label: _isEdit ? 'Enregistrer' : 'Créer le membre',
              isLoading: isSaving,
              onPressed: isSaving ? null : () => _submit(currentUser),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Future<QuartierRef?> _addQuartier(BuildContext context) {
    return showAddLookupBottomSheet<QuartierRef>(
      context: context,
      title: 'Nouveau quartier',
      hint: 'Ex. Essos',
      onSubmit: (nom, _) async {
        final created = await ref
            .read(quartiersRemoteDataSourceProvider)
            .create(nom);
        ref.read(quartiersListProvider.notifier).addItem(created);
        return created;
      },
    );
  }

  Future<void> _deleteQuartier(QuartierRef quartier) async {
    await ref.read(quartiersRemoteDataSourceProvider).delete(quartier.id);
    ref.read(quartiersListProvider.notifier).removeItem(quartier);
    if (mounted && _quartier?.id == quartier.id) {
      setState(() => _quartier = null);
    }
  }

  Future<VilleRef?> _addVille(BuildContext context) {
    return showAddLookupBottomSheet<VilleRef>(
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
    );
  }

  Future<void> _deleteVille(VilleRef ville) async {
    await ref.read(villesRemoteDataSourceProvider).delete(ville.id);
    ref.read(villesListProvider.notifier).removeItem(ville);
    if (mounted && _ville?.id == ville.id) {
      setState(() => _ville = null);
    }
  }

  Future<GroupeRef?> _addGroupe(BuildContext context) async {
    final created = await showAddLookupBottomSheet<GroupeRef>(
      context: context,
      title: 'Nouveau groupe',
      hint: 'Ex. Chorale',
      onSubmit: (nom, _) async {
        final created = await ref
            .read(groupesRemoteDataSourceProvider)
            .create(nom);
        ref.read(groupesListProvider.notifier).addItem(created);
        return created;
      },
    );
    if (created != null && mounted) {
      setState(() {
        _groupes = {..._groupes, created.id: <String>{}};
      });
    }
    return created;
  }

  Future<void> _deleteGroupe(GroupeRef groupe) async {
    await ref.read(groupesRemoteDataSourceProvider).delete(groupe.id);
    ref.read(groupesListProvider.notifier).removeItem(groupe);
    if (mounted) {
      setState(() {
        _groupes = {..._groupes}..remove(groupe.id);
      });
    }
  }

  Future<void> _submit(UserEntity currentUser) async {
    if (!_formKey.currentState!.validate()) return;
    if ((_selectedRole == null) &&
        (!_isEdit || AppPermissions.canEditMemberRole(currentUser))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sélectionnez un rôle'), backgroundColor: SignmeColors.error),
      );
      return;
    }
    if (_matriculeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez le sexe et l\'identifiant du membre'),
          backgroundColor: SignmeColors.error,
        ),
      );
      return;
    }
    if (_selectedRole == 'paroissien' && _estCommuniant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sélectionnez le statut communiant/non communiant'),
          backgroundColor: SignmeColors.error,
        ),
      );
      return;
    }

    final dateNaissanceIso = _dateNaissance != null
        ? '${_dateNaissance!.year.toString().padLeft(4, '0')}-'
            '${_dateNaissance!.month.toString().padLeft(2, '0')}-'
            '${_dateNaissance!.day.toString().padLeft(2, '0')}'
        : null;

    final payload = <String, dynamic>{
      'nom': _nomCtrl.text.trim(),
      if (!_isEdit) 'email': _emailCtrl.text.trim(),
      if (_selectedRole != null &&
          (!_isEdit || AppPermissions.canEditMemberRole(currentUser)))
        'role': _selectedRole,
      if (_telCtrl.text.trim().isNotEmpty) 'telephone': _telCtrl.text.trim(),
      if (_professionCtrl.text.trim().isNotEmpty)
        'profession': _professionCtrl.text.trim(),
      if (_sexe != null) 'sexe': _sexe,
      if (_matriculeCtrl.text.trim().isNotEmpty)
        'matricule': _matriculeCtrl.text.trim(),
      if (_selectedRole == 'paroissien' && _estCommuniant != null)
        'estCommuniant': _estCommuniant,
      if (dateNaissanceIso != null) 'dateNaissance': dateNaissanceIso,
      if (_originaireDe != null) 'originaireDe': _originaireDe,
      if (_quartier != null) 'quartierId': _quartier!.id,
      if (_ville != null) 'villeId': _ville!.id,
      'groupes': [
        for (final e in _groupes.entries) {'id': e.key, 'postes': e.value.toList()},
      ],
    };

    try {
      late final UserEntity saved;
      if (_isEdit) {
        saved = await ref.read(usersActionsProvider.notifier).update(
              widget.userId!,
              payload,
            );
      } else {
        saved = await ref.read(usersActionsProvider.notifier).create(payload);
      }

      if (_photoFile != null &&
          AppPermissions.canUploadMemberPhoto(
            currentUser,
            targetUserId: saved.id,
          )) {
        await ref.read(usersActionsProvider.notifier).uploadPhoto(
              userId: saved.id,
              photoFile: _photoFile!,
            );
      }

      if (mounted) {
        ref.read(formDirtyProvider.notifier).state = false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEdit ? 'Membre mis à jour' : 'Membre créé avec succès',
            ),
            backgroundColor: SignmeColors.success,
          ),
        );
        context.pop();
      }
    } on ProfileImageTooLargeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: SignmeColors.error),
      );
    } catch (e) {
      if (!mounted) return;
      final msg = e is AppException ? e.message : messageFromError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: SignmeColors.error),
      );
    }
  }

  Future<void> _fetchNextMatricule() async {
    if (_sexe == null) return;
    setState(() => _isFetchingMatricule = true);
    try {
      final matricule =
          await ref.read(usersRemoteDataSourceProvider).nextMatricule(_sexe!);
      if (!mounted) return;
      setState(() {
        _matriculeCtrl.text = matricule;
        _isFetchingMatricule = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isFetchingMatricule = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e is AppException ? e.message : messageFromError(e)),
          backgroundColor: SignmeColors.error,
        ),
      );
    }
  }

  Future<void> _pickPhoto(BuildContext context) async {
    try {
      final file = await ProfileImagePicker.pick(context);
      if (file != null && mounted) {
        _markDirty();
        setState(() => _photoFile = file);
      }
    } on ProfileImageTooLargeException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: SignmeColors.error),
      );
    }
  }
}

class _UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class _SexeChip extends StatelessWidget {
  const _SexeChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback? onTap;

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

class _LoadingLookupField extends StatelessWidget {
  const _LoadingLookupField({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: Text(label, style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold)),
        ),
        const AppShimmerBox(width: double.infinity, height: 52, radius: SignmeSpacing.radiusMd),
      ],
    );
  }
}

class _LookupErrorField extends StatelessWidget {
  const _LookupErrorField({required this.label, required this.onRetry});
  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: SignmeSpacing.sm),
          child: Text(label, style: SignmeTypography.inputLabel.copyWith(fontWeight: FontWeight.bold)),
        ),
        InkWell(
          onTap: onRetry,
          child: Container(
            padding: SignmeSpacing.inputPadding,
            decoration: BoxDecoration(
              color: SignmeColors.error.withOpacity(0.08),
              borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, size: 18, color: SignmeColors.error),
                const SizedBox(width: SignmeSpacing.sm),
                Expanded(
                  child: Text(
                    'Chargement impossible — appuyez pour réessayer',
                    style: SignmeTypography.bodySmall.copyWith(color: SignmeColors.error),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
