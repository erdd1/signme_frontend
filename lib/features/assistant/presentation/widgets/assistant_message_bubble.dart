import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../domain/entities/assistant_message_entity.dart';
import 'assistant_avatar.dart';
import 'assistant_rich_text.dart';

/// Bulle de message : question de l'utilisateur à droite (dégradé de marque),
/// réponse de l'assistant à gauche (carte blanche, copiable).
class AssistantMessageBubble extends StatelessWidget {
  const AssistantMessageBubble({super.key, required this.message});

  final AssistantMessageEntity message;

  @override
  Widget build(BuildContext context) {
    return message.isUser ? _userBubble(context) : _assistantBubble(context);
  }

  Widget _userBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _maxBubbleWidth(context)),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SignmeSpacing.lg,
            vertical: SignmeSpacing.md,
          ),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: SignmeColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SignmeSpacing.radiusXl),
              topRight: Radius.circular(SignmeSpacing.radiusXl),
              bottomLeft: Radius.circular(SignmeSpacing.radiusXl),
              bottomRight: Radius.circular(SignmeSpacing.radiusXs),
            ),
          ),
          child: SelectableText(
            message.content,
            style: SignmeTypography.bodyMedium.copyWith(color: Colors.white, height: 1.45),
          ),
        ),
      ),
    );
  }

  Widget _assistantBubble(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AssistantAvatar(size: 32),
        const SizedBox(width: SignmeSpacing.sm),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: _maxBubbleWidth(context)),
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                SignmeSpacing.lg,
                SignmeSpacing.md,
                SignmeSpacing.lg,
                SignmeSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: SignmeColors.white,
                border: Border.all(color: SignmeColors.lightGrayBorder),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(SignmeSpacing.radiusXs),
                  topRight: Radius.circular(SignmeSpacing.radiusXl),
                  bottomLeft: Radius.circular(SignmeSpacing.radiusXl),
                  bottomRight: Radius.circular(SignmeSpacing.radiusXl),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AssistantRichText(text: message.content),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: 'Copier la réponse',
                      icon: const Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: SignmeColors.mediumGray,
                      ),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: message.content));
                        if (context.mounted) AppSnackbar.success(context, 'Réponse copiée');
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Les bulles ne dépassent jamais 80 % de l'écran, comme une vraie messagerie.
  static double _maxBubbleWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width * 0.8;
}
