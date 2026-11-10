import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';
import 'assistant_avatar.dart';

/// Écran d'accueil de l'assistant, avant la première question.
class AssistantWelcomeView extends StatelessWidget {
  const AssistantWelcomeView({super.key, required this.onSuggestion});

  final ValueChanged<String> onSuggestion;

  static const List<String> suggestions = [
    'Quels versets parlent du pardon ?',
    'Explique-moi la parabole du fils prodigue',
    'Comment prier quand on est découragé ?',
    'Que signifie être sauvé par la grâce ?',
    'Un verset pour me fortifier aujourd\'hui',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.all(SignmeSpacing.xl),
      child: Column(
        children: [
          const SizedBox(height: SignmeSpacing.lg),
          const AssistantAvatar(size: 88),
          const SizedBox(height: SignmeSpacing.xl),
          Text(
            'Assistant religieux',
            style: SignmeTypography.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Text(
            'Posez vos questions sur la Bible et la foi chrétienne. '
            'Vos échanges ne sont pas enregistrés.',
            style: SignmeTypography.bodyMedium.copyWith(color: SignmeColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: SignmeSpacing.xxl),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'POUR COMMENCER',
              style: SignmeTypography.labelSmall.copyWith(
                color: SignmeColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.md),
          for (final s in suggestions) ...[
            _SuggestionTile(text: s, onTap: () => onSuggestion(s)),
            const SizedBox(height: SignmeSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _SuggestionTile extends StatelessWidget {
  const _SuggestionTile({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: SignmeSpacing.lg,
          vertical: SignmeSpacing.md,
        ),
        decoration: BoxDecoration(
          color: SignmeColors.white,
          borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
          border: Border.all(color: SignmeColors.lightGrayBorder),
        ),
        child: Row(
          children: [
            Expanded(child: Text(text, style: SignmeTypography.bodyMedium)),
            const Icon(Icons.north_east_rounded, size: 18, color: SignmeColors.primaryLight),
          ],
        ),
      ),
    );
  }
}
