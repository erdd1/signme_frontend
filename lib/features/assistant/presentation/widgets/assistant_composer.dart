import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';

/// Zone de saisie : champ multiligne + bouton d'envoi rond (dégradé de marque).
class AssistantComposer extends StatefulWidget {
  const AssistantComposer({super.key, required this.onSend, required this.enabled});

  final ValueChanged<String> onSend;

  /// false pendant qu'une réponse est attendue.
  final bool enabled;

  static const int maxLength = 2000;

  @override
  State<AssistantComposer> createState() => _AssistantComposerState();
}

class _AssistantComposerState extends State<AssistantComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty || !widget.enabled) return;
    widget.onSend(text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        SignmeSpacing.lg,
        SignmeSpacing.sm,
        SignmeSpacing.md,
        SignmeSpacing.sm,
      ),
      decoration: const BoxDecoration(
        color: SignmeColors.white,
        border: Border(top: BorderSide(color: SignmeColors.lightGrayBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                maxLength: AssistantComposer.maxLength,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.multiline,
                style: SignmeTypography.bodyMedium,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Posez votre question…',
                  counterText: '',
                  filled: true,
                  fillColor: SignmeColors.accentSky.withValues(alpha: 0.3),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: SignmeSpacing.lg,
                    vertical: SignmeSpacing.md,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(SignmeSpacing.radiusXl),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: SignmeSpacing.sm),
            _SendButton(
              active: widget.enabled && _controller.text.trim().isNotEmpty,
              onTap: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: GestureDetector(
        onTap: active ? onTap : null,
        child: AnimatedContainer(
          duration: SignmeSpacing.animationFast,
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: active
                ? const LinearGradient(
                    colors: SignmeColors.primaryGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: active ? null : SignmeColors.lightGrayBorder,
          ),
          child: Icon(
            Icons.arrow_upward_rounded,
            color: active ? Colors.white : SignmeColors.mediumGray,
            size: 24,
          ),
        ),
      ),
    );
  }
}
