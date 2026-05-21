import 'package:equatable/equatable.dart';

/// Entité User — couche Domain (aucune dépendance framework)
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
    this.actif       = true,
    this.estDeService = false,
    this.groupe,
    this.profession,
  });

  final int     id;
  final String  nom;
  final String  email;
  final String  role;
  final int?    churchId;
  final String? churchNom;
  final String? photoUrl;
  final String? telephone;
  final bool    actif;
  final bool    estDeService;
  final String? groupe;
  final String? profession;

  bool get isAdmin      => role == 'administrateur';
  bool get isPasteur    => role == 'pasteur';
  bool get isSecretaire => role == 'secretaire';
  bool get isTresorier  => role == 'tresorier';
  bool get isAncien     => role == 'ancien';
  bool get isParoissien => role == 'paroissien';

  /// Peut initier une signature à distance (mobile money)
  bool get canSignDistance => actif;

  /// Peut faire une signature présentielle
  bool get canSignPresentiel =>
      actif && (isAdmin || isPasteur || (isAncien && estDeService));

  @override
  List<Object?> get props => [id, email, role, actif];
}

/// Entité Auth — contient le user + les tokens
class AuthEntity extends Equatable {
  const AuthEntity({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    this.isAuthenticated = true,
  });

  final UserEntity user;
  final String     accessToken;
  final String     refreshToken;
  final bool       isAuthenticated;

  static const AuthEntity unauthenticated = AuthEntity(
    user: UserEntity(id: 0, nom: '', email: '', role: ''),
    accessToken:  '',
    refreshToken: '',
    isAuthenticated: false,
  );

  @override
  List<Object?> get props => [user, accessToken, isAuthenticated];
}
