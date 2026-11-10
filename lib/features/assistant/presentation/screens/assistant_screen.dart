import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/design_system/index.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/widgets/index.dart';
import '../providers/assistant_provider.dart';
import '../widgets/assistant_avatar.dart';
import '../widgets/assistant_composer.dart';
import '../widgets/assistant_message_bubble.dart';
import '../widgets/assistant_typing_indicator.dart';
import '../widgets/assistant_welcome_view.dart';

/// Discussion avec l'Assistant religieux. Plein écran, hors coquille (ni
/// appbar ni navbar du shell) : le champ de saisie suit le clavier, comme
/// dans une vraie messagerie.
class AssistantScreen extends ConsumerStatefulWidget {
  const AssistantScreen({super.key});

  @override
  ConsumerState<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends ConsumerState<AssistantScreen> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: SignmeSpacing.animationMedium,
        curve: Curves.easeOutCubic,
      );
    });
  }

  Future<void> _confirmReset() async {
    final confirmed = await showSignmeConfirm(
      context,
      title: 'Nouvelle conversation',
      message: 'La conversation actuelle sera effacée.',
      confirmLabel: 'Effacer',
      cancelLabel: 'Annuler',
      icon: Icons.add_comment_rounded,
      onConfirm: () => Navigator.of(context).pop(true),
      onCancel: () => Navigator.of(context).pop(false),
    );
    if (confirmed == true) ref.read(assistantChatProvider.notifier).reset();
  }

  @override
  Widget build(BuildContext context) {
    final chat = ref.watch(assistantChatProvider);
    final notifier = ref.read(assistantChatProvider.notifier);

    ref.listen<AssistantChatState>(assistantChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isSending != next.isSending ||
          previous?.error != next.error) {
        _scrollToEnd();
      }
    });

    return Scaffold(
      backgroundColor: SignmeColors.background,
      appBar: AppBar(
        backgroundColor: SignmeColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: SignmeColors.black),
          onPressed: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const AssistantAvatar(size: 36),
            const SizedBox(width: SignmeSpacing.md),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assistant religieux',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.labelLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'IA · vérifiez toujours avec la Bible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: SignmeTypography.labelSmall.copyWith(color: SignmeColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!chat.isEmpty)
            IconButton(
              icon: const Icon(Icons.add_comment_rounded, color: SignmeColors.primaryLight),
              tooltip: 'Nouvelle conversation',
              onPressed: chat.isSending ? null : _confirmReset,
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: chat.isEmpty
                ? AssistantWelcomeView(onSuggestion: notifier.send)
                : ListView(
                    controller: _scroll,
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.all(SignmeSpacing.lg),
                    children: [
                      for (final message in chat.messages) ...[
                        AssistantMessageBubble(message: message),
                        const SizedBox(height: SignmeSpacing.md),
                      ],
                      if (chat.isSending) const AssistantTypingIndicator(),
                      if (chat.error != null) _ErrorCard(message: chat.error!, onRetry: notifier.retry),
                    ],
                  ),
          ),
          AssistantComposer(onSend: notifier.send, enabled: !chat.isSending),
        ],
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SignmeSpacing.lg),
      decoration: BoxDecoration(
        color: SignmeColors.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(SignmeSpacing.radiusLg),
        border: Border.all(color: SignmeColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.error_outline_rounded, color: SignmeColors.error, size: 20),
              const SizedBox(width: SignmeSpacing.sm),
              Expanded(child: Text(message, style: SignmeTypography.bodyMedium)),
            ],
          ),
          const SizedBox(height: SignmeSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: SignmeTextButton(label: 'Réessayer', icon: Icons.refresh_rounded, onPressed: onRetry),
          ),
        ],
      ),
    );
  }
}
