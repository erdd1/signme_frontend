import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';
import '../../domain/entities/retrait_entity.dart';

/// Badge de statut — le statut d'un retrait doit toujours être exact et sans
/// ambiguïté visuelle (couleur dédiée par statut, jamais de fusion pending/
/// processing).
class RetraitStatusBadge extends StatelessWidget {
  const RetraitStatusBadge({super.key, required this.retrait});

  final RetraitEntity retrait;

  @override
  Widget build(BuildContext context) {
    final (color, icon) = switch (retrait.statut) {
      'completed' => (SignmeColors.success, Icons.check_circle_rounded),
      'failed' => (SignmeColors.error, Icons.cancel_rounded),
      'processing' => (SignmeColors.primaryLight, Icons.sync_rounded),
      _ => (SignmeColors.warning, Icons.schedule_rounded),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            retrait.statutLabel,
            style: SignmeTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
