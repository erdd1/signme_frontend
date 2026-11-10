import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';

/// Pastille d'identité de l'assistant : dégradé de la marque + icône d'IA.
class AssistantAvatar extends StatelessWidget {
  const AssistantAvatar({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: SignmeColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Icon(Icons.auto_awesome_rounded, color: Colors.white, size: size * 0.5),
    );
  }
}
