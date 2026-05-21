import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/role_menu_drawer.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_entity.dart';
import '../providers/users_provider.dart';

class UserDetailScreen extends ConsumerStatefulWidget {
  const UserDetailScreen({super.key, required this.userId});

  final int userId;

  @override
  ConsumerState<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends ConsumerState<UserDetailScreen> {
  late TextEditingController _nomCtrl;
  late TextEditingController _telephoneCtrl;
  late TextEditingController _professionCtrl;
  late TextEditingController _groupeCtrl;
  late TextEditingController _originaireCtrl;

  bool _isEditMode = false;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _nomCtrl = TextEditingController();
    _telephoneCtrl = TextEditingController();
    _professionCtrl = TextEditingController();
    _groupeCtrl = TextEditingController();
    _originaireCtrl = TextEditingController();

    // Charger l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userDetailProvider.notifier).loadUser(widget.userId);
    });
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _telephoneCtrl.dispose();
    _professionCtrl.dispose();
    _groupeCtrl.dispose();
    _originaireCtrl.dispose();
    super.dispose();
  }

  void _initializeFields(UserEntity user) {
    _nomCtrl.text = user.nom;
    _telephoneCtrl.text = user.telephone ?? '';
    _professionCtrl.text = user.profession ?? '';
    _groupeCtrl.text = user.groupe ?? '';
    _originaireCtrl.text = user.originaireDe ?? '';
    _selectedRole = user.role;
  }

  Future<void> _updateRole(String? newRole) async {
    if (newRole == null || newRole == _selectedRole) return;

    final success = await ref.read(userDetailProvider.notifier).updateUser(
      widget.userId,
      {'role': newRole},
    );

    if (mounted) {
      if (success) {
        setState(() => _selectedRole = newRole);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Rôle mis à jour avec succès')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      }
    }
  }

  Future<void> _toggleStatus() async {
    final success = await ref.read(userDetailProvider.notifier).toggleStatus(widget.userId);

    if (mounted) {
      if (success) {
        final newStatus = ref.read(userDetailProvider).user?.actif ?? false;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(newStatus ? 'Compte activé' : 'Compte désactivé'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de l\'opération')),
        );
      }
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        final success =
            await ref.read(userDetailProvider.notifier).uploadPhoto(
          widget.userId,
          image.path,
        );

        if (success && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploadée avec succès')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    final success = await ref.read(userDetailProvider.notifier).updateUser(
      widget.userId,
      {
        'nom': _nomCtrl.text,
        'telephone': _telephoneCtrl.text.isEmpty ? null : _telephoneCtrl.text,
        'profession': _professionCtrl.text.isEmpty ? null : _professionCtrl.text,
        'groupe': _groupeCtrl.text.isEmpty ? null : _groupeCtrl.text,
        'originaireDe':
            _originaireCtrl.text.isEmpty ? null : _originaireCtrl.text,
      },
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès')),
        );
        setState(() => _isEditMode = false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur lors de la mise à jour')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userDetailProvider);
    final currentUser = ref.watch(currentUserProvider);

    // Vérifier si l'utilisateur peut éditer ce profil
    final canEdit = currentUser != null &&
        (currentUser.user.id == widget.userId ||
            currentUser.user.role == 'administrateur' ||
            currentUser.user.role == 'pasteur');

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: const RoleMenuDrawer(),
      appBar: AppBar(
        title: Text('Détail Utilisateur',
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600)),
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        actions: [
          if (canEdit && !_isEditMode)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: IconButton(
                icon: const Icon(Icons.edit_rounded),
                onPressed: () {
                  if (userState.user != null) {
                    _initializeFields(userState.user!);
                    setState(() => _isEditMode = true);
                  }
                },
              ),
            ),
        ],
      ),
      body: userState.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : userState.user == null
              ? Center(
                  child: Text(userState.error ?? 'Utilisateur non trouvé',
                      style: GoogleFonts.poppins(
                          color: AppColors.textSecondary, fontSize: 14)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _isEditMode
                      ? _buildEditForm(userState.user!, canEdit, userState)
                      : _buildViewMode(userState.user!, canEdit),
                ),
    );
  }

  Widget _buildViewMode(UserEntity user, bool canEdit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar & Photo Upload
        Center(
          child: Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primary, width: 2),
                  image: user.photoUrl != null
                      ? DecorationImage(
                          image: NetworkImage(user.photoUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.photoUrl == null
                    ? const Icon(Icons.person_rounded,
                        size: 60, color: AppColors.primary)
                    : null,
              ),
              if (canEdit)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadPhoto,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          size: 20, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Info générale
        _buildInfoCard(
          title: 'Informations Générales',
          children: [
            _buildInfoRow('Nom', user.nom),
            _buildInfoRow('Email', user.email),
            _buildInfoRow('Rôle', user.roleLabel),
            _buildInfoRow('Église', user.churchNom ?? 'Non assignée'),
            _buildInfoRow('Statut',
                user.actif ? 'Actif' : 'Inactif',
                color:
                    user.actif ? AppColors.success : AppColors.error),
            if (user.estDeService)
              _buildInfoRow('Service',
                  'Actuellement en service',
                  color: AppColors.primary),
          ],
        ),
        const SizedBox(height: 16),

        // Info Profil
        _buildInfoCard(
          title: 'Informations Personnelles',
          children: [
            if (user.telephone != null)
              _buildInfoRow('Téléphone', user.telephone!),
            if (user.profession != null)
              _buildInfoRow('Profession', user.profession!),
            if (user.groupe != null)
              _buildInfoRow('Groupe / Chorale', user.groupe!),
            if (user.originaireDe != null)
              _buildInfoRow('Originaire de', user.originaireDe!),
          ],
        ),
      ],
    );
  }

  Widget _buildEditForm(UserEntity user, bool canEdit, UserDetailState state) {
    final currentUser = ref.watch(currentUserProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        Center(
          child: GestureDetector(
            onTap: _pickAndUploadPhoto,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 2),
                image: user.photoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(user.photoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: user.photoUrl == null
                  ? const Icon(Icons.camera_alt_rounded,
                      size: 40, color: AppColors.primary)
                  : null,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Formulaire
        Text('Nom*',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _nomCtrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Nom complet',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Téléphone',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _telephoneCtrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: '+237 ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Profession',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _professionCtrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Votre profession',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Groupe / Chorale',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _groupeCtrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Groupe ou chorale',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),

        Text('Originaire de',
            style: GoogleFonts.poppins(
                fontSize: 14, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: _originaireCtrl,
          style: GoogleFonts.poppins(fontSize: 14),
          decoration: InputDecoration(
            hintText: 'Région d\'origine',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── Role Management (Pasteur only) ───────────────────────────────
        _buildRoleSection(user, canEdit),
        
        // ── Account Status ───────────────────────────────────────────────
        if (canEdit && currentUser != null && user.id != currentUser.user.id)
          _buildAccountStatusSection(user, canEdit, state),

        const SizedBox(height: 24),

        // Boutons actions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.close_rounded),
                label: const Text('Annuler'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.border,
                  foregroundColor: AppColors.textPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: state.isUpdating
                    ? null
                    : () => setState(() => _isEditMode = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check_rounded),
                label: const Text('Enregistrer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: state.isUpdating ? null : _saveProfile,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Messages d'erreur
        if (state.error != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error),
            ),
            child: Text(
              state.error!,
              style: GoogleFonts.poppins(
                  fontSize: 12, color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSection(UserEntity user, bool canEdit) {
    final currentUser = ref.watch(currentUserProvider);
    final isPasteur = currentUser != null && currentUser.user.role == 'pasteur';

    if (!isPasteur) return const SizedBox.shrink();

    // Ne pas permettre de modifier le rôle des pasteurs/administrateurs
    if (user.role == 'pasteur' || user.role == 'administrateur') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.primary, width: 0.8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rôle',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ce rôle ne peut pas être modifié',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      );
    }

    // Available roles: exclude administrateur and pasteur
    const availableRoles = ['secretaire', 'tresorier', 'ancien', 'paroissien'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primary, width: 0.8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modifier le Rôle',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: _selectedRole,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  items: availableRoles
                      .map((role) => DropdownMenuItem(
                            value: role,
                            child: Text(
                              role.toUpperCase(),
                              style: GoogleFonts.poppins(fontSize: 13),
                            ),
                          ))
                      .toList(),
                  onChanged: (newRole) => _updateRole(newRole),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rôle actuel: ${user.role.toUpperCase()}',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAccountStatusSection(
      UserEntity user, bool canEdit, UserDetailState state) {
    final currentUser = ref.watch(currentUserProvider);
    final canManageStatus =
        currentUser != null &&
        (currentUser.user.role == 'pasteur' ||
            currentUser.user.role == 'administrateur');

    if (!canManageStatus) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: user.actif
                ? AppColors.success.withOpacity(0.1)
                : AppColors.error.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: user.actif ? AppColors.success : AppColors.error,
              width: 0.8,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    user.actif ? Icons.check_circle : Icons.block,
                    color: user.actif ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    user.actif ? 'Compte Actif' : 'Compte Désactivé',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: user.actif ? AppColors.success : AppColors.error,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(user.actif
                      ? Icons.block_rounded
                      : Icons.check_circle_rounded),
                  label: Text(user.actif
                      ? 'Désactiver le Compte'
                      : 'Activer le Compte'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        user.actif ? AppColors.error : AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: state.isToggling ? null : _toggleStatus,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
