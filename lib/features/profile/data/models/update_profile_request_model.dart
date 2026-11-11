/// Modèle de requête pour la mise à jour du profil (clés camelCase = API Laravel)
class UpdateProfileRequestModel {
  final String? nom;
  final String? telephone;
  final String? profession;
  final String? originaireDe;
  final String? sexe;
  final String? dateNaissance;
  final int? quartierId;
  final int? villeId;
  final List<int>? groupeIds;

  /// Groupes avec poste : [{id, postes: ['president', 'tresorier']}].
  final List<Map<String, dynamic>>? groupes;

  UpdateProfileRequestModel({
    this.nom,
    this.telephone,
    this.profession,
    this.originaireDe,
    this.sexe,
    this.dateNaissance,
    this.quartierId,
    this.villeId,
    this.groupeIds,
    this.groupes,
  });

  Map<String, dynamic> toJson() => {
        if (nom != null) 'nom': nom,
        if (telephone != null) 'telephone': telephone,
        if (profession != null) 'profession': profession,
        if (originaireDe != null) 'originaireDe': originaireDe,
        if (sexe != null) 'sexe': sexe,
        if (dateNaissance != null) 'dateNaissance': dateNaissance,
        if (quartierId != null) 'quartierId': quartierId,
        if (villeId != null) 'villeId': villeId,
        if (groupeIds != null) 'groupeIds': groupeIds,
        if (groupes != null) 'groupes': groupes,
      };

  factory UpdateProfileRequestModel.fromMap(Map<String, dynamic> data) {
    return UpdateProfileRequestModel(
      nom: data['nom']?.toString(),
      telephone: data['telephone']?.toString(),
      profession: data['profession']?.toString(),
      originaireDe: data['originaireDe']?.toString() ??
          data['originaire_de']?.toString(),
      sexe: data['sexe']?.toString(),
      dateNaissance: data['dateNaissance']?.toString(),
      quartierId: (data['quartierId'] as num?)?.toInt(),
      villeId: (data['villeId'] as num?)?.toInt(),
      groupeIds: (data['groupeIds'] as List?)?.map((e) => (e as num).toInt()).toList(),
      groupes: (data['groupes'] as List?)?.whereType<Map<String, dynamic>>().toList(),
    );
  }
}
