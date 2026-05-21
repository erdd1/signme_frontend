import 'package:equatable/equatable.dart';

class PublicationEntity extends Equatable {
  const PublicationEntity({
    required this.id,
    required this.titre,
    required this.contenu,
    required this.type,
    required this.auteurNom,
    required this.auteurPhoto,
    required this.createdAt,
    this.reference,
    this.churchNom,
  });

  final int     id;
  final String  titre;
  final String  contenu;
  final String  type;       // MEDITATION, ANNONCE, TEMOIGNAGE, ...
  final String  auteurNom;
  final String? auteurPhoto;
  final DateTime createdAt;
  final String? reference;  // ex: "1 Corin 10 v13"
  final String? churchNom;

  @override
  List<Object?> get props => [id];
}
