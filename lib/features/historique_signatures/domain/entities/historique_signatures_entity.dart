/// Historique Signatures Entity
/// C'est l'historique des SIGNATURES EN PRÉSENTIEL effectuées par les anciens/pasteurs
/// Traçabilité des signatures effectuées PAR l'utilisateur connecté (ancien/pasteur)

class HistoriqueSignaturesEntity {
  final String id;
  final String userId; // ID de l'utilisateur signé (paroissien)
  final String nomParoissien; // Nom du paroissien signé
  final String emailParoissien;
  final String ancienId; // ID de l'ancien/pasteur qui a signé
  final String nomAncien; // Nom de l'ancien/pasteur qui a signé
  final String month; // Format: 2026-01
  final int year;
  final String status; // 'completed' | 'pending' | 'failed'
  final int? amount;
  final int? fees;
  final String signatureType; // 'presentiel'
  final String? location; // Lieu de signature
  final String churchId;
  final String churchName;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? notes; // Notes du signeur

  HistoriqueSignaturesEntity({
    required this.id,
    required this.userId,
    required this.nomParoissien,
    required this.emailParoissien,
    required this.ancienId,
    required this.nomAncien,
    required this.month,
    required this.year,
    required this.status,
    this.amount,
    this.fees,
    required this.signatureType,
    this.location,
    required this.churchId,
    required this.churchName,
    required this.createdAt,
    this.completedAt,
    this.notes,
  });

  // Getters utiles
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';

  /// Format de la date pour affichage: "20 mai 2026 à 14:30"
  String get formattedDate {
    return createdAt.toLocal().toString().split('.')[0];
  }

  /// Date courte pour affichage en tête de carte : "09-09-2026"
  String get shortDateLabel {
    final d = createdAt.toLocal();
    return '${d.day.toString().padLeft(2, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.year}';
  }

  /// Statut lisible en français
  String get statusFr {
    switch (status) {
      case 'completed':
        return 'Validée';
      case 'pending':
        return 'En attente';
      case 'failed':
        return 'Échouée';
      default:
        return status;
    }
  }

  /// Résumé pour affichage: "Jean Nkuo - Février 2026"
  String get summaryText => '$nomParoissien - $month';
}
