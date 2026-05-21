import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../providers/users_provider.dart';

/// Dialogue pour créer un nouvel utilisateur
class CreateUserDialog extends ConsumerStatefulWidget {
  const CreateUserDialog({super.key, required this.currentUserRole});
  
  final String currentUserRole;

  @override
  ConsumerState<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends ConsumerState<CreateUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _professionCtrl = TextEditingController();
  
  String? _selectedRole;
  bool _isLoading = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _emailCtrl.dispose();
    _telCtrl.dispose();
    _professionCtrl.dispose();
    super.dispose();
  }

  /// Retourne les rôles possibles selon le rôle de l'utilisateur courant
  List<String> get _availableRoles {
    if (widget.currentUserRole == 'pasteur') {
      // Pasteur peut créer: secrétaire, trésorier, ancien, paroissien
      return ['secretaire', 'tresorier', 'ancien', 'paroissien'];
    } else if (widget.currentUserRole == 'secretaire') {
      // Secrétaire peut créer: ancien, paroissien, trésorier
      return ['ancien', 'paroissien', 'tresorier'];
    }
    return [];
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedRole == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final data = {
      'nom': _nomCtrl.text,
      'email': _emailCtrl.text,
      'role': _selectedRole,
      'telephone': _telCtrl.text.isNotEmpty ? _telCtrl.text : null,
      'profession': _professionCtrl.text.isNotEmpty ? _professionCtrl.text : null,
    };

    final success = await ref.read(usersListProvider.notifier).createUser(data);

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utilisateur créé avec succès')),
        );
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ref.watch(usersListProvider).error ?? 'Erreur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Ajouter un utilisateur',
        style: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nom
              TextFormField(
                controller: _nomCtrl,
                decoration: InputDecoration(
                  labelText: 'Nom complet *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Requis' : null,
              ),
              const SizedBox(height: 16),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                validator: (v) {
                  if (v?.isEmpty ?? true) return 'Requis';
                  if (!v!.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Rôle
              DropdownButtonFormField<String>(
                initialValue: _selectedRole,
                decoration: InputDecoration(
                  labelText: 'Rôle *',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                items: _availableRoles
                    .map((r) => DropdownMenuItem(
                          value: r,
                          child: Text(_roleLabel(r)),
                        ))
                    .toList(),
                onChanged: (v) => setState(() => _selectedRole = v),
                validator: (v) => v == null ? 'Sélectionnez un rôle' : null,
              ),
              const SizedBox(height: 16),

              // Téléphone
              TextFormField(
                controller: _telCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profession
              TextFormField(
                controller: _professionCtrl,
                decoration: InputDecoration(
                  labelText: 'Profession',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                  ),
                )
              : const Text('Créer'),
        ),
      ],
    );
  }

  String _roleLabel(String role) {
    const map = {
      'pasteur': 'PASTEUR',
      'secretaire': 'SECRÉTAIRE',
      'tresorier': 'TRÉSORIER',
      'ancien': 'ANCIEN',
      'paroissien': 'PAROISSIEN',
    };
    return map[role] ?? role.toUpperCase();
  }
}
