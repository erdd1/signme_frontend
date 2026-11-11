import 'package:equatable/equatable.dart';

/// Référence légère vers un groupe (ministère) de l'église.
/// Utilisée à la fois pour l'affichage embarqué dans [UserEntity] et pour
/// les listes gérées (dropdowns, gestion des groupes/quartiers/villes).
///
/// [postes] : poste du membre dans ce groupe — vide = simple membre, sinon
/// [GroupePoste.president] et/ou [GroupePoste.tresorier]. Sans rapport avec
/// le rôle de l'utilisateur (`role`).
class GroupeRef extends Equatable {
  const GroupeRef({required this.id, required this.nom, this.uuid, this.postes = const []});

  final int id;
  final String nom;
  final String? uuid;
  final List<String> postes;

  bool get estPresident => postes.contains(GroupePoste.president);
  bool get estTresorier => postes.contains(GroupePoste.tresorier);

  factory GroupeRef.fromJson(Map<String, dynamic> json) => GroupeRef(
        id: (json['id'] as num).toInt(),
        nom: json['nom']?.toString() ?? '',
        uuid: json['uuid']?.toString(),
        postes: (json['postes'] as List?)?.map((p) => p.toString()).toList() ?? const [],
      );

  Map<String, dynamic> toJson() => {'id': id, 'uuid': uuid, 'nom': nom, 'postes': postes};

  @override
  List<Object?> get props => [id, nom, uuid, postes];
}

/// Postes possibles dans un groupe (valeurs échangées avec l'API).
abstract final class GroupePoste {
  static const president = 'president';
  static const tresorier = 'tresorier';
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
