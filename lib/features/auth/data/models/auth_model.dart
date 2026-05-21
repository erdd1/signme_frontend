import '../../domain/entities/auth_entity.dart';

/// Modèle User — couche Data (JSON deserialization)
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.nom,
    required super.email,
    required super.role,
    super.churchId,
    super.churchNom,
    super.photoUrl,
    super.telephone,
    super.actif,
    super.estDeService,
    super.groupe,
    super.profession,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:           (json['id'] as num).toInt(),
      nom:          json['nom']?.toString() ?? '',
      email:        json['email']?.toString() ?? '',
      role:         json['role']?.toString() ?? '',
      churchId:     json['churchId'] != null ? (json['churchId'] as num).toInt() : null,
      churchNom:    json['church']?['nom']?.toString() ?? json['churchNom']?.toString(),
      photoUrl:     json['photoUrl']?.toString(),
      telephone:    json['telephone']?.toString(),
      actif:        json['actif'] as bool? ?? true,
      estDeService: json['est_de_service'] as bool? ?? false,
      groupe:       json['groupe']?.toString(),
      profession:   json['profession']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id':             id,
    'nom':            nom,
    'email':          email,
    'role':           role,
    'churchId':       churchId,
    'churchNom':      churchNom,
    'photoUrl':       photoUrl,
    'telephone':      telephone,
    'actif':          actif,
    'est_de_service': estDeService,
    'groupe':         groupe,
    'profession':     profession,
  };

  factory UserModel.fromEntity(UserEntity e) => UserModel(
    id: e.id, nom: e.nom, email: e.email, role: e.role,
    churchId: e.churchId, churchNom: e.churchNom, photoUrl: e.photoUrl,
    telephone: e.telephone, actif: e.actif, estDeService: e.estDeService,
    groupe: e.groupe, profession: e.profession,
  );
}

/// Modèle Auth
class AuthModel extends AuthEntity {
  const AuthModel({
    required super.user,
    required super.accessToken,
    required super.refreshToken,
    super.isAuthenticated,
  });

  factory AuthModel.fromJson(Map<String, dynamic> json) {
    // Backend EEC retourne: { success, message, data: { id, nom, email, ..., access_token, refresh_token } }
    // Les données de l'utilisateur sont directement dans 'data', pas imbriquées sous 'data.user'
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    // Créer l'utilisateur à partir des données complètes
    final user = UserModel.fromJson(data);
    
    return AuthModel(
      user:         user,
      accessToken:  data['access_token']?.toString() ?? '',
      refreshToken: data['refresh_token']?.toString() ?? '',
    );
  }
}
