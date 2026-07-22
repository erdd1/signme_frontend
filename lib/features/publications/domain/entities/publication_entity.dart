import 'package:intl/intl.dart';


class PublicationEntity {
  final int id;
  final String titre;
  final String contenu;
  final String type; // 'annonce' ou 'meditation'
  final String? referenceBiblique; // Obligatoire pour méditations
  final int auteurId;
  final String auteurNom;
  final String? auteurPhotoUrl;
  final int churchId;
  final String? churchName;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;

  PublicationEntity({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    this.referenceBiblique,
    required this.auteurId,
    required this.auteurNom,
    this.auteurPhotoUrl,
    required this.churchId,
    this.churchName,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Getters pour le type
  bool get isAnnonce => type == 'annonce';
  bool get isMeditation => type == 'meditation';

  /// Formate la date pour affichage
  String get formattedDate {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }

  /// Formate la date avec l'heure
  String get formattedDateTime {
    return DateFormat('dd MMM yyyy à HH:mm', 'fr_FR').format(date);
  }

  /// Label du type pour l'affichage
  String get typeLabel {
    switch (type) {
      case 'annonce':
        return 'Annonce';
      case 'meditation':
        return 'Méditation';
      default:
        return type;
    }
  }

  /// Couleur associée au type
  int get typeColor {
    switch (type) {
      case 'annonce':
        return 0xFF2196F3; // Bleu
      case 'meditation':
        return 0xFF9C27B0; // Violet
      default:
        return 0xFF757575; // Gris
    }
  }

  /// Icône associée au type
  String get typeIcon {
    switch (type) {
      case 'annonce':
        return '📢';
      case 'meditation':
        return '📖';
      default:
        return '📝';
    }
  }
}
