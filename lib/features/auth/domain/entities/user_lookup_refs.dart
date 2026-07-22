import 'package:equatable/equatable.dart';

/// Référence légère vers un groupe (ministère) de l'église.
/// Utilisée à la fois pour l'affichage embarqué dans [UserEntity] et pour
/// les listes gérées (dropdowns, gestion des groupes/quartiers/villes).
class GroupeRef extends Equatable {
  const GroupeRef({required this.id, required this.nom});

  final int id;
  final String nom;

  factory GroupeRef.fromJson(Map<String, dynamic> json) => GroupeRef(
        id: (json['id'] as num).toInt(),
        nom: json['nom']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [id, nom];
}

/// Référence légère vers un quartier de résidence.
class QuartierRef extends Equatable {
  const QuartierRef({required this.id, required this.nom});

  final int id;
  final String nom;

  factory QuartierRef.fromJson(Map<String, dynamic> json) => QuartierRef(
        id: (json['id'] as num).toInt(),
        nom: json['nom']?.toString() ?? '',
      );

  @override
  List<Object?> get props => [id, nom];
}

/// Référence légère vers une ville de résidence (Au Cameroun / Diaspora).
class VilleRef extends Equatable {
  const VilleRef({
    required this.id,
    required this.nom,
    required this.estDiaspora,
  });

  final int id;
  final String nom;
  final bool estDiaspora;

  factory VilleRef.fromJson(Map<String, dynamic> json) => VilleRef(
        id: (json['id'] as num).toInt(),
        nom: json['nom']?.toString() ?? '',
        estDiaspora: json['estDiaspora'] as bool? ?? false,
      );

  @override
  List<Object?> get props => [id, nom, estDiaspora];
}
