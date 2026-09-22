import 'package:equatable/equatable.dart';
import 'user_lookup_refs.dart';

/// Entité User — couche Domain (aucune dépendance framework)
/// Représente les données de l'utilisateur authentifié
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
    this.profession,
    this.originaireDe,
    this.dateConfirmation,
    this.lieuConfirmation,
    this.sexe,
    this.matricule,
    this.estCommuniant = true,
    this.communiantDepuis,
    this.dateNaissance,
    this.quartier,
    this.ville,
    this.groupePrincipal,
    this.groupes = const [],
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
  final String? profession;
  final String? originaireDe;
  final String? dateConfirmation;
  final String? lieuConfirmation;

  /// 'homme' | 'femme'
  final String? sexe;

  /// Identifiant propre à l'église (H001-H999 / F001-F999), distinct de [id].
  final String? matricule;

  /// false uniquement possible pour le rôle paroissien — les autres rôles
  /// sont et seront toujours communiants.
  final bool estCommuniant;

  /// Posée par le pasteur/la secrétaire au passage non-communiant → communiant
  /// (format ISO YYYY-MM-DD) — plancher pour signer, jamais de rattrapage
  /// sur les mois précédents.
  final String? communiantDepuis;

  /// Date de naissance au format ISO (YYYY-MM-DD)
  final String? dateNaissance;
  final QuartierRef? quartier;
  final VilleRef? ville;
  final GroupeRef? groupePrincipal;
  final List<GroupeRef> groupes;

  bool get isPasteur => role == 'pasteur';
  bool get isSecretaire => role == 'secretaire';
  bool get isTresorier => role == 'tresorier';
  bool get isAncien => role == 'ancien';
  bool get isParoissien => role == 'paroissien';

  String get roleLabel {
    const map = {
      'pasteur': 'PASTEUR',
      'secretaire': 'SECRÉTAIRE',
      'tresorier': 'TRÉSORIER',
      'ancien': 'ANCIEN',
      'paroissien': 'PAROISSIEN',
    };
    return map[role] ?? role.toUpperCase();
  }

  /// Peut initier une signature à distance (mobile money)
  bool get canSignDistance => actif;

  /// Peut faire une signature présentielle
  bool get canSignPresentiel =>
      actif && (isPasteur || (isAncien && estDeService));

  @override
  List<Object?> get props => [
    id,
    nom,
    email,
    role,
    churchId,
    churchNom,
    photoUrl,
    telephone,
    actif,
    estDeService,
    profession,
    originaireDe,
    dateConfirmation,
    lieuConfirmation,
    sexe,
    matricule,
    estCommuniant,
    communiantDepuis,
    dateNaissance,
    quartier,
    ville,
    groupePrincipal,
    groupes,
  ];
}
