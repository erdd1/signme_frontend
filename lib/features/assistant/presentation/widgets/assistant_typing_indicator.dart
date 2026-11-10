import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import 'assistant_avatar.dart';

/// Trois points animés : l'assistant « écrit sa réponse ».
class AssistantTypingIndicator extends StatefulWidget {
  const AssistantTypingIndicator({super.key});

  @override
  State<AssistantTypingIndicator> createState() => _AssistantTypingIndicatorState();
}

class _AssistantTypingIndicatorState extends State<AssistantTypingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AssistantAvatar(size: 32),
        const SizedBox(width: SignmeSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SignmeSpacing.lg,
            vertical: SignmeSpacing.lg,
          ),
          decoration: BoxDecoration(
            color: SignmeColors.white,
            border: Border.all(color: SignmeColors.lightGrayBorder),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [for (var i = 0; i < 3; i++) _dot(i)],
            ),
          ),
        ),
      ],
    );
  }

  Widget _dot(int index) {
    // Chaque point est décalé d'un tiers de cycle : effet de vague.
    final phase = (_controller.value - index / 3) % 1.0;
    final lift = phase < 0.5 ? Curves.easeInOut.transform(phase * 2) : 0.0;

    return Container(
      width: 8,
      height: 8,
      margin: EdgeInsets.only(right: index < 2 ? 5 : 0, bottom: lift * 5),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Color.lerp(SignmeColors.mediumGray, SignmeColors.primaryLight, lift),
      ),
    );
  }
}
