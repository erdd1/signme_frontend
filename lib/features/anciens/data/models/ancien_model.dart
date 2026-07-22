import 'dart:convert';
import '../../domain/entities/ancien_entity.dart';

class AncienModel extends AncienEntity {
  const AncienModel({
    required super.userId,
    required super.nom,
    required super.email,
    required super.photoUrl,
    super.isDesigned = false,
    super.designationId,
    super.mois,
    super.annee,
    super.egliseId,
    super.joursTravail,
    super.horairesDebut,
    super.horairesFin,
    super.dateFinService,
  });

  factory AncienModel.fromJson(Map<String, dynamic> json) {
    return AncienModel(
      userId: (json['id'] as num?)?.toInt() ?? 0,
      nom: json['nom']?.toString() ?? '',
      // Priorité à l'email, sinon téléphone pour éviter les chaînes vides en prod
      email: json['email']?.toString() ?? json['telephone']?.toString() ?? '',
      photoUrl: json['photoUrl']?.toString() ?? '',
      isDesigned: (json['est_designe'] as bool?) ?? false,
      designationId: (json['designation_id'] as num?)?.toInt(),
      mois: (json['mois'] as num?)?.toInt(),
      annee: (json['annee'] as num?)?.toInt(),
      egliseId: (json['eglise_id'] as num?)?.toInt(),
      joursTravail: _parseJours(json['jours_travail']),
      horairesDebut: _convertHoraire(json['horaire_debut']),
      horairesFin: _convertHoraire(json['horaire_fin']),
      dateFinService: json['date_fin_service']?.toString(),
    );
  }

  // Amélioration : Typage plus strict pour le parsing des jours
  // Gère : List<int>, String JSON, ou null
  static List<int>? _parseJours(Object? value) {
    if (value == null) return null;
    
    // Cas 1: Déjà une List
    if (value is List) {
      return value.map((e) => (e as num).toInt()).toList();
    }
    
    // Cas 2: String JSON (ex: "[1,2,3]")
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = json.decode(value) as List?;
        if (decoded != null) {
          return decoded.map((e) => (e as num).toInt()).toList();
        }
      } catch (_) {}
    }
    
    return null;
  }

  // Convertit les horaires du format HH:MM:SS → HH:MM
  static String? _convertHoraire(Object? value) {
    if (value == null) return null;
    final str = value.toString();
    if (str.isEmpty) return null;
    // Si format HH:MM:SS, convertir à HH:MM
    if (str.length > 5) {
      return str.substring(0, 5);
    }
    return str;
  }

  Map<String, dynamic> toJson() => {
    'id': userId,
    'nom': nom,
    'email': email,
    'photoUrl': photoUrl,
    'est_designe': isDesigned,
    if (designationId != null) 'designation_id': designationId,
    'mois': mois,
    'annee': annee,
    'eglise_id': egliseId,
    'jours_travail': joursTravail,
    'horaire_debut': horairesDebut,
    'horaire_fin': horairesFin,
    'date_fin_service': dateFinService,
  };
}
