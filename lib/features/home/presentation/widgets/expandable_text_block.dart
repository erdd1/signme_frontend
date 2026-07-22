import 'package:flutter/material.dart';
import '../../../../core/design_system/index.dart';

/// Texte repliable avec liens « Voir plus » / « Voir moins ».
class ExpandableTextBlock extends StatefulWidget {
  const ExpandableTextBlock({
    super.key,
    required this.text,
    this.maxLines = 5,
    this.style,
  });

  final String text;
  final int maxLines;
  final TextStyle? style;

  @override
  State<ExpandableTextBlock> createState() => _ExpandableTextBlockState();
}

class _ExpandableTextBlockState extends State<ExpandableTextBlock> {
  bool _expanded = false;

  TextStyle get _textStyle =>
      widget.style ??
      SignmeTypography.bodySmall.copyWith(
        color: SignmeColors.black,
        height: 2,
      );

  TextStyle get _toggleStyle => SignmeTypography.labelSmall.copyWith(
        color: SignmeColors.primaryLight,
        fontWeight: FontWeight.w800,
      );

  bool _exceedsMaxLines(double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: widget.text, style: _textStyle),
      maxLines: widget.maxLines,
      textDirection: Directionality.of(context),
    );
    painter.layout(maxWidth: maxWidth);
    return painter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.text.trim().isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasOverflow = _exceedsMaxLines(constraints.maxWidth);
        final showVoirPlus = hasOverflow && !_expanded;
        final showVoirMoins = hasOverflow && _expanded;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              maxLines: _expanded ? null : widget.maxLines,
              overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: _textStyle,
            ),
            if (showVoirPlus || showVoirMoins) ...[
              const SizedBox(height: SignmeSpacing.xs),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    foregroundColor: SignmeColors.primaryLight,
                  ),
                  child: Text(
                    _expanded ? 'Voir moins' : 'Voir plus',
                    style: _toggleStyle,
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
