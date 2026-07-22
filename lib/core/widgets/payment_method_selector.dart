import 'package:flutter/material.dart';
import '../design_system/index.dart';

/// Sélecteur de méthode de paiement — Mobile Money ou Carte bancaire.
///
/// Widget de présentation pur (aucune logique métier) partagé entre le
/// module Signature (paiement à distance) et le module Evenement
/// (contribution) : les deux flux de paiement passent par NotchPay et
/// offrent exactement les deux mêmes choix.
class PaymentMethodSelector extends StatelessWidget {
  const PaymentMethodSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  /// 'mobile_money' | 'card'
  final String selected;
  final ValueChanged<String> onChanged;

  static const _options = [
    (value: 'mobile_money', label: 'Mobile Money', icon: Icons.phone_android_rounded),
    (value: 'card', label: 'Carte bancaire', icon: Icons.credit_card_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _options.map((option) {
        final isSel = selected == option.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: option.value == 'mobile_money' ? SignmeSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(option.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSel ? SignmeColors.primaryLight : SignmeColors.white,
                  borderRadius: BorderRadius.circular(SignmeSpacing.radiusMd),
                  border: Border.all(
                    color: isSel ? SignmeColors.primaryLight : SignmeColors.lightGrayBorder,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      color: isSel ? Colors.white : SignmeColors.mediumGray,
                      size: 22,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      option.label,
                      style: SignmeTypography.labelSmall.copyWith(
                        fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        color: isSel ? Colors.white : SignmeColors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
