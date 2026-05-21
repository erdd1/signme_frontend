import 'package:equatable/equatable.dart';

class AncienEntity extends Equatable {
  const AncienEntity({
    required this.userId,
    required this.nom,
    required this.email,
    required this.photoUrl,
    this.isDesigned = false,
    // Infos de désignation (si designé)
    this.designationId,
    this.mois,
    this.annee,
    this.egliseId,
    this.joursTravail,     // [1,2,3,4,5] = Lun-Ven, null = 24/7
    this.horairesDebut,    // "08:00", null = 00:00
    this.horairesFin,      // "18:00", null = 23:59
    this.dateFinService,   // "2026-06-30 23:59:59"
  });

  // ── Infos utilisateur
  final int userId;
  final String nom;
  final String email;
  final String photoUrl;
  
  // ── Status de désignation
  final bool isDesigned;
  
  // ── Infos de désignation actuelles
  final int? designationId;
  final int? mois;
  final int? annee;
  final int? egliseId;
  final List<int>? joursTravail;
  final String? horairesDebut;
  final String? horairesFin;
  final String? dateFinService;

  /// Disponibilité formatée pour l'affichage
  String get availabilityLabel {
    if (!isDesigned) return 'Non désigné';
    
    final jours = _joursLabel;
    final heures = _heuresLabel;
    
    if (jours.isEmpty && heures.isEmpty) return '24/7';
    if (jours.isEmpty) return 'Tous les jours, $heures';
    if (heures.isEmpty) return jours;
    
    return '$jours, $heures';
  }

  String get _joursLabel {
    if (joursTravail == null || joursTravail!.isEmpty) return '';
    
    final labels = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    final jours = joursTravail!.map((j) => labels[j - 1]).join('-');
    return jours;
  }

  String get _heuresLabel {
    final debut = horairesDebut ?? '00:00';
    final fin = horairesFin ?? '23:59';
    if (debut == '00:00' && fin == '23:59') return '';
    return '$debut-$fin';
  }

  /// Statut pour le mois/année affiché
  String get monthYearLabel => mois != null && annee != null
      ? 'Mois $mois/$annee'
      : '';

  @override
  List<Object?> get props => [
    userId, 
    nom,
    isDesigned,
    designationId,
    mois,
    annee,
    joursTravail,
  ];
}

