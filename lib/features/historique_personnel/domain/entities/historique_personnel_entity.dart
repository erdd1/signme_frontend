/// Historique Personnel Entity
/// Historique des signatures à distance ET présentiel de l'utilisateur connecté

class HistoriquePersonnelEntity {
  final String id;
  final String userId;
  final String nomUtilisateur;
  final String month; // Format: 2026-01
  final int year;
  final String status; // 'completed' | 'pending' | 'failed'
  final int amount; // Montant payé
  final int? fees; // Frais
  final String signatureType; // 'distance' | 'presentiel'
  final String? paymentMethod; // 'ORANGE MONEY' | 'MTN' | 'CASH' (null pour présentiel)
  final String? paymentPhoneNumber;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? errorMessage; // Si failed
  
  // Champs spécifiques aux signatures présentiel
  final String? signataireName; // Nom de celui qui a signé (pour présentiel)
  final String? signatairerole; // Rôle de celui qui a signé (Pasteur, Ancien de service)

  HistoriquePersonnelEntity({
    required this.id,
    required this.userId,
    required this.nomUtilisateur,
    required this.month,
    required this.year,
    required this.status,
    required this.amount,
    this.fees,
    required this.signatureType,
    this.paymentMethod,
    this.paymentPhoneNumber,
    required this.createdAt,
    this.completedAt,
    this.errorMessage,
    this.signataireName,
    this.signatairerole,
  });

  // Getters utiles
  bool get isCompleted => status == 'completed';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isDistance => signatureType == 'distance';
  bool get isPresentiel => signatureType == 'presentiel';

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
        return 'Payé';
      case 'pending':
        return 'En cours de traitement';
      case 'failed':
        return 'Paiement échoué';
      default:
        return status;
    }
  }

  /// Description du mode de signature
  String get signatureTypeFr {
    if (isPresentiel) {
      return 'Signé par $signataireName, $signatairerole';
    }
    return 'À distance';
  }
}
