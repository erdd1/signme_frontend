/// Paramètres du paiement par carte renvoyés par le serveur : option
/// disponible ou non (interrupteur serveur) et taux de frais.
class CardPaymentConfigEntity {
  const CardPaymentConfigEntity({required this.enabled, this.feePercent = 0});

  /// Option carte indisponible — valeur par défaut tant que le serveur n'a pas
  /// répondu ou en cas d'erreur : l'app se comporte alors comme avant.
  static const disabled = CardPaymentConfigEntity(enabled: false);

  final bool enabled;
  final double feePercent;

  factory CardPaymentConfigEntity.fromJson(Map<String, dynamic> json) {
    return CardPaymentConfigEntity(
      enabled: json['enabled'] == true,
      feePercent: (json['feePercent'] as num?)?.toDouble() ?? 0,
    );
  }
}
