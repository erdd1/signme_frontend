import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.nom,
    required this.email,
    required this.role,
    this.churchId,
    this.churchNom,
    this.photoUrl,
    this.telephone,
    this.actif = true,
    this.estDeService = false,
    this.groupe,
    this.profession,
    this.originaireDe,
  });

  final int id;
  final String nom;
  final String email;
  final String role;
  final int? churchId;
  final String? churchNom;
  final String? photoUrl;
  final String? telephone;
  final bool actif;
  final bool estDeService;
  final String? groupe;
  final String? profession;
  final String? originaireDe;

  String get roleLabel {
    const map = {
      'administrateur': 'ADMINISTRATEUR',
      'pasteur': 'PASTEUR',
      'secretaire': 'SECRÉTAIRE',
      'tresorier': 'TRÉSORIER',
      'ancien': 'ANCIEN',
      'paroissien': 'PAROISSIEN',
    };
    return map[role] ?? role.toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, role, actif];
}
