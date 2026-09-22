import '../../../auth/domain/entities/user_entity.dart';
import '../../../auth/domain/entities/user_lookup_refs.dart';
import '../../../../core/utils/photo_url_utils.dart';

/// Modèle User — couche Data (JSON deserialization)
/// IMPORTANT: Ce modèle est utilisé pour la persistance locale et l'authentification
/// TOUS les champs de UserEntity doivent être inclus
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
    super.profession,
    super.originaireDe,
    super.dateConfirmation,
    super.lieuConfirmation,
    super.sexe,
    super.matricule,
    super.estCommuniant,
    super.communiantDepuis,
    super.dateNaissance,
    super.quartier,
    super.ville,
    super.groupePrincipal,
    super.groupes,
  });

  /// Créer depuis JSON (réponse API — UserResource backend)
  /// Supporte les formats snake_case (API) et camelCase (stockage local)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final church = json['church'];
    String? churchNom;
    if (church is Map<String, dynamic>) {
      churchNom = church['nom']?.toString();
    }
    churchNom ??= json['church_nom']?.toString() ?? json['churchNom']?.toString();

    final quartierJson = json['quartier'];
    final villeJson = json['ville'];
    final groupePrincipalJson = json['groupePrincipal'];
    final groupesJson = json['groupes'];

    return UserModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      churchId: json['church_id'] != null
          ? (json['church_id'] as num).toInt()
          : json['churchId'] != null
              ? (json['churchId'] as num).toInt()
              : null,
      churchNom: churchNom,
      photoUrl: normalizePhotoUrl(json['photo_url'] ?? json['photoUrl']),
      telephone: json['telephone']?.toString(),
      actif: json['actif'] as bool? ?? true,
      estDeService: json['est_de_service'] as bool? ??
          json['estDeService'] as bool? ??
          false,
      profession: json['profession']?.toString(),
      originaireDe: json['originaire_de']?.toString() ??
          json['originaireDe']?.toString(),
      dateConfirmation: json['date_confirmation']?.toString() ??
          json['dateConfirmation']?.toString(),
      lieuConfirmation: json['lieu_confirmation']?.toString() ??
          json['lieuConfirmation']?.toString(),
      sexe: json['sexe']?.toString(),
      matricule: json['matricule']?.toString(),
      estCommuniant: json['estCommuniant'] as bool? ?? true,
      communiantDepuis: json['communiantDepuis']?.toString(),
      dateNaissance: json['dateNaissance']?.toString() ??
          json['date_naissance']?.toString(),
      quartier: quartierJson is Map<String, dynamic>
          ? QuartierRef.fromJson(quartierJson)
          : null,
      ville: villeJson is Map<String, dynamic>
          ? VilleRef.fromJson(villeJson)
          : null,
      groupePrincipal: groupePrincipalJson is Map<String, dynamic>
          ? GroupeRef.fromJson(groupePrincipalJson)
          : null,
      groupes: groupesJson is List
          ? groupesJson
              .whereType<Map<String, dynamic>>()
              .map(GroupeRef.fromJson)
              .toList()
          : const [],
    );
  }

  /// Convertir en JSON pour stockage/envoi
  Map<String, dynamic> toJson() => {
        'id': id,
        'nom': nom,
        'email': email,
        'role': role,
        'church_id': churchId,
        'church_nom': churchNom,
        'photo_url': photoUrl,
        'telephone': telephone,
        'actif': actif,
        'est_de_service': estDeService,
        'profession': profession,
        'originaire_de': originaireDe,
        'date_confirmation': dateConfirmation,
        'lieu_confirmation': lieuConfirmation,
        'sexe': sexe,
        'matricule': matricule,
        'estCommuniant': estCommuniant,
        'communiantDepuis': communiantDepuis,
        'dateNaissance': dateNaissance,
        'quartier': quartier != null
            ? {'id': quartier!.id, 'nom': quartier!.nom}
            : null,
        'ville': ville != null
            ? {
                'id': ville!.id,
                'nom': ville!.nom,
                'estDiaspora': ville!.estDiaspora,
              }
            : null,
        'groupePrincipal': groupePrincipal != null
            ? {'id': groupePrincipal!.id, 'nom': groupePrincipal!.nom}
            : null,
        'groupes': groupes.map((g) => {'id': g.id, 'nom': g.nom}).toList(),
      };

  factory UserModel.fromEntity(UserEntity entity) {
    if (entity is UserModel) return entity;
    return UserModel(
      id: entity.id,
      nom: entity.nom,
      email: entity.email,
      role: entity.role,
      churchId: entity.churchId,
      churchNom: entity.churchNom,
      photoUrl: entity.photoUrl,
      telephone: entity.telephone,
      actif: entity.actif,
      estDeService: entity.estDeService,
      profession: entity.profession,
      originaireDe: entity.originaireDe,
      dateConfirmation: entity.dateConfirmation,
      lieuConfirmation: entity.lieuConfirmation,
      sexe: entity.sexe,
      matricule: entity.matricule,
      estCommuniant: entity.estCommuniant,
      communiantDepuis: entity.communiantDepuis,
      dateNaissance: entity.dateNaissance,
      quartier: entity.quartier,
      ville: entity.ville,
      groupePrincipal: entity.groupePrincipal,
      groupes: entity.groupes,
    );
  }
}
