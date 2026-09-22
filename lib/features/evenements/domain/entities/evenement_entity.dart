import 'package:intl/intl.dart';
import '../../../../core/config/app_environment.dart';

class EvenementAuteur {
  const EvenementAuteur({required this.id, required this.nom, this.photoUrl});
  final int id;
  final String nom;
  final String? photoUrl;
}

class EvenementChurch {
  const EvenementChurch({this.id, this.nom});
  final int? id;
  final String? nom;
}

class EvenementEntity {
  const EvenementEntity({
    required this.uuid,
    required this.titre,
    required this.description,
    this.imageUrl,
    required this.statut,
    required this.dateDebut,
    this.dateFin,
    this.publishedAt,
    this.scheduledPublishAt,
    this.termineAt,
    this.archivedAt,
    this.objectifMontant,
    this.montantCollecte = 0,
    this.nombreContributions = 0,
    this.nombreContributeurs,
    this.pourcentageObjectif,
    this.joursAvantArchivage,
    required this.auteur,
    required this.church,
    this.estAuteur = false,
    this.peutContribuer = false,
    this.peutGerer = false,
    required this.createdAt,
    required this.updatedAt,
  });

  final String uuid;
  final String titre;
  final String description;
  final String? imageUrl;
  final String statut; // brouillon | planifie | actif | termine | archive
  final DateTime dateDebut;
  final DateTime? dateFin;
  final DateTime? publishedAt;
  final DateTime? scheduledPublishAt;
  final DateTime? termineAt;
  final DateTime? archivedAt;
  final int? objectifMontant;
  final int montantCollecte;
  final int nombreContributions;
  /// Nombre de contributeurs distincts (uniquement présent sur la vue
  /// "Gérer les événements" — null ailleurs, ne pas confondre avec
  /// [nombreContributions] qui compte les transactions).
  final int? nombreContributeurs;
  final double? pourcentageObjectif;
  final int? joursAvantArchivage;
  final EvenementAuteur auteur;
  final EvenementChurch church;
  final bool estAuteur;
  final bool peutContribuer;
  final bool peutGerer;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBrouillon => statut == 'brouillon';
  bool get isPlanifie => statut == 'planifie';
  bool get isActif => statut == 'actif';
  bool get isTermine => statut == 'termine';
  bool get isArchive => statut == 'archive';
  bool get aUnObjectif => objectifMontant != null && objectifMontant! > 0;

  String get statutLabel {
    switch (statut) {
      case 'brouillon':
        return 'Brouillon';
      case 'planifie':
        return 'Planifié';
      case 'actif':
        return 'Actif';
      case 'termine':
        return 'Terminé';
      case 'archive':
        return 'Archivé';
      default:
        return statut;
    }
  }

  String get formattedDate =>
      DateFormat('dd MMM yyyy', 'fr_FR').format(publishedAt ?? createdAt);

  /// Libellé du bouton de contribution selon l'état.
  String get labelBoutonContribution {
    if (isTermine || isArchive) return 'Événement terminé';
    return 'Ajouter une contribution';
  }

  String? get labelArchivage {
    final jours = joursAvantArchivage;
    if (jours == null) return null;
    if (jours <= 0) return 'Archivage imminent';
    return 'Archivage dans $jours jour${jours > 1 ? 's' : ''}';
  }

  /// Lien public (Android App Links / iOS Universal Links) — voir
  /// routes/web.php côté backend, même chemin qu'AppRoutes.evenementDetailPath.
  String get shareUrl => '${AppEnvironment.webBaseUrl}/evenements/$uuid';

  /// Texte prérempli pour le partage (WhatsApp, SMS, email...).
  String get shareText =>
      'Découvrez cet événement de ${church.nom ?? "notre église"} : $titre\n$shareUrl';
}
