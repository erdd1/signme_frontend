import '../../../auth/domain/entities/user_lookup_refs.dart';

int _int(dynamic v) => v is num ? v.toInt() : 0;

/// Caisse d'un groupe : trois sources séparées. Le retrait ne porte que sur
/// l'argent en ligne ([soldeEnLigne]) ; le cash n'est pas sur la plateforme.
class GroupeCaisse {
  const GroupeCaisse({
    required this.enLigne,
    required this.retraits,
    required this.soldeEnLigne,
    required this.cash,
    required this.total,
  });

  final int enLigne;
  final int retraits;
  final int soldeEnLigne;
  final int cash;
  final int total;

  factory GroupeCaisse.fromJson(Map<String, dynamic> json) => GroupeCaisse(
        enLigne: _int(json['enLigne']),
        retraits: _int(json['retraits']),
        soldeEnLigne: _int(json['soldeEnLigne']),
        cash: _int(json['cash']),
        total: _int(json['total']),
      );
}

/// Groupe vu par un de ses membres : son poste et, pour l'écran du groupe, la
/// caisse (visible de tous les membres) et les responsables.
class GroupeEntity {
  const GroupeEntity({
    required this.uuid,
    required this.nom,
    required this.postes,
    this.nbMembres,
    this.caisse,
    this.president,
    this.tresorier,
  });

  final String uuid;
  final String nom;
  final List<String> postes;
  final int? nbMembres;
  final GroupeCaisse? caisse;
  final String? president;
  final String? tresorier;

  bool get estPresident => postes.contains(GroupePoste.president);
  bool get estTresorier => postes.contains(GroupePoste.tresorier);

  /// Président ou trésorier : gère la caisse (cash, retraits).
  bool get estResponsable => estPresident || estTresorier;

  /// Libellé court du poste de l'utilisateur dans ce groupe.
  String get posteLabel {
    if (estPresident && estTresorier) return 'Président & trésorier';
    if (estPresident) return 'Président';
    if (estTresorier) return 'Trésorier';
    return 'Membre';
  }

  factory GroupeEntity.fromJson(Map<String, dynamic> json) {
    final caisse = json['caisse'];
    final resp = json['responsables'];
    return GroupeEntity(
      uuid: json['uuid']?.toString() ?? '',
      nom: json['nom']?.toString() ?? '',
      postes: (json['postes'] as List?)?.map((p) => p.toString()).toList() ?? const [],
      nbMembres: json['nbMembres'] is num ? (json['nbMembres'] as num).toInt() : null,
      caisse: caisse is Map<String, dynamic> ? GroupeCaisse.fromJson(caisse) : null,
      president: resp is Map ? resp['president']?.toString() : null,
      tresorier: resp is Map ? resp['tresorier']?.toString() : null,
    );
  }
}

/// Communiqué d'un groupe, avec l'avancement de sa collecte.
class CommuniqueEntity {
  const CommuniqueEntity({
    required this.uuid,
    required this.titre,
    required this.message,
    this.objectifMontant,
    this.dateDebut,
    this.dateFin,
    required this.montantCollecte,
    required this.nombreContributions,
    this.auteur,
    this.createdAt,
  });

  final String uuid;
  final String titre;
  final String message;
  final int? objectifMontant;
  final String? dateDebut;
  final String? dateFin;
  final int montantCollecte;
  final int nombreContributions;
  final String? auteur;
  final String? createdAt;

  /// Avancement vers l'objectif (0..1), ou null sans objectif.
  double? get progression {
    final objectif = objectifMontant;
    if (objectif == null || objectif <= 0) return null;
    return (montantCollecte / objectif).clamp(0.0, 1.0);
  }

  factory CommuniqueEntity.fromJson(Map<String, dynamic> json) => CommuniqueEntity(
        uuid: json['uuid']?.toString() ?? '',
        titre: json['titre']?.toString() ?? '',
        message: json['message']?.toString() ?? '',
        objectifMontant: json['objectifMontant'] is num ? (json['objectifMontant'] as num).toInt() : null,
        dateDebut: json['dateDebut']?.toString(),
        dateFin: json['dateFin']?.toString(),
        montantCollecte: _int(json['montantCollecte']),
        nombreContributions: _int(json['nombreContributions']),
        auteur: json['auteur']?.toString(),
        createdAt: json['createdAt']?.toString(),
      );
}

/// Qui a contribué à un communiqué.
class ContributeurEntity {
  const ContributeurEntity({required this.nom, this.photoUrl, required this.montant, required this.date});

  final String nom;
  final String? photoUrl;
  final int montant;
  final String date;

  factory ContributeurEntity.fromJson(Map<String, dynamic> json) => ContributeurEntity(
        nom: json['nom']?.toString() ?? '',
        photoUrl: json['photoUrl']?.toString(),
        montant: _int(json['montant']),
        date: json['date']?.toString() ?? '',
      );
}

/// Une ligne de l'historique de la caisse (entrée ou sortie d'argent).
class MouvementEntity {
  const MouvementEntity({
    required this.id,
    required this.type,
    required this.sens,
    required this.montant,
    this.acteur,
    this.libelle,
    this.note,
    required this.annule,
    this.statut,
    required this.date,
  });

  final String id;

  /// contribution | don | cash | retrait
  final String type;

  /// entree | sortie
  final String sens;
  final int montant;
  final String? acteur;
  final String? libelle;
  final String? note;
  final bool annule;
  final String? statut;
  final String date;

  bool get estEntree => sens == 'entree';
  bool get estCash => type == 'cash';

  factory MouvementEntity.fromJson(Map<String, dynamic> json) => MouvementEntity(
        id: json['id']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
        sens: json['sens']?.toString() ?? 'entree',
        montant: _int(json['montant']),
        acteur: json['acteur']?.toString(),
        libelle: json['libelle']?.toString(),
        note: json['note']?.toString(),
        annule: json['annule'] == true,
        statut: json['statut']?.toString(),
        date: json['date']?.toString() ?? '',
      );
}
