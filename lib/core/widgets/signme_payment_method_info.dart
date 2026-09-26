import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// Couleur de l'opérateur mobile money — même palette que le sélecteur du
/// formulaire de signature (voir `_operatorRow` dans signer_screen.dart).
/// `null` si le paiement n'est pas passé par mobile money.
Color? paymentOperatorColor(String? operator) {
  return switch (operator) {
    'ORANGE MONEY' => const Color(0xFFFF6600),
    'MTN MOBILE MONEY' => const Color(0xFFFFCC00),
    _ => null,
  };
}

/// Libellé court de l'opérateur, même wording que le formulaire de signature.
String? paymentOperatorLabel(String? operator) {
  return switch (operator) {
    'ORANGE MONEY' => 'Orange Money',
    'MTN MOBILE MONEY' => 'MTN Money',
    _ => null,
  };
}

/// Bloc "pastille de couleur + opérateur + numéro" réutilisé partout où un
/// historique affiche le moyen de paiement mobile money (timeline des
/// signatures, cartes "Mes dépenses"...).
class SignmePaymentMethodInfo extends StatelessWidget {
  const SignmePaymentMethodInfo({
    super.key,
    required this.color,
    this.label,
    this.phoneNumber,
  });

  final Color color;
  final String? label;
  final String? phoneNumber;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Icon(Icons.circle, size: 11, color: color),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label != null)
                Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelSmall.copyWith(
                    color: SignmeColors.darkGray,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              if (phoneNumber != null)
                Text(
                  phoneNumber!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: SignmeTypography.labelSmall.copyWith(
                    color: SignmeColors.mediumGray,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
