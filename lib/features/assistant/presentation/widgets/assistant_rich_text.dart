import 'package:flutter/material.dart';

import '../../../../core/design_system/index.dart';

/// Affiche la réponse de l'assistant avec la mise en forme légère qu'il
/// produit : paragraphes, listes (- ou 1.), titres (#) et **gras** / *italique*.
/// Le texte est sélectionnable (appui long pour copier un passage).
class AssistantRichText extends StatelessWidget {
  const AssistantRichText({super.key, required this.text});

  final String text;

  static final _bullet = RegExp(r'^\s*[-*•]\s+(.*)$');
  static final _numbered = RegExp(r'^\s*(\d+)[.)]\s+(.*)$');
  static final _heading = RegExp(r'^\s*#{1,6}\s+(.*)$');
  static final _inline = RegExp(r'\*\*(.+?)\*\*|\*(.+?)\*');

  @override
  Widget build(BuildContext context) {
    final base = SignmeTypography.bodyMedium.copyWith(
      color: SignmeColors.onSurface,
      height: 1.5,
    );

    final blocks = <Widget>[];
    for (final line in text.split('\n')) {
      if (line.trim().isEmpty) continue;

      final bullet = _bullet.firstMatch(line);
      final numbered = _numbered.firstMatch(line);
      final heading = _heading.firstMatch(line);

      if (heading != null) {
        blocks.add(_line(_spans(heading.group(1)!, base.copyWith(fontWeight: FontWeight.w700)), top: 8));
      } else if (bullet != null) {
        blocks.add(_listItem('•', _spans(bullet.group(1)!, base)));
      } else if (numbered != null) {
        blocks.add(_listItem('${numbered.group(1)}.', _spans(numbered.group(2)!, base)));
      } else {
        blocks.add(_line(_spans(line.trim(), base)));
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: blocks);
  }

  Widget _line(List<InlineSpan> spans, {double top = 4}) => Padding(
        padding: EdgeInsets.only(top: top),
        child: SelectableText.rich(TextSpan(children: spans)),
      );

  Widget _listItem(String marker, List<InlineSpan> spans) => Padding(
        padding: const EdgeInsets.only(top: 4, left: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 22,
              child: Text(
                marker,
                style: SignmeTypography.bodyMedium.copyWith(
                  color: SignmeColors.primaryLight,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Expanded(child: SelectableText.rich(TextSpan(children: spans))),
          ],
        ),
      );

  List<InlineSpan> _spans(String source, TextStyle style) {
    final spans = <InlineSpan>[];
    var cursor = 0;
    for (final m in _inline.allMatches(source)) {
      if (m.start > cursor) {
        spans.add(TextSpan(text: source.substring(cursor, m.start), style: style));
      }
      final bold = m.group(1);
      spans.add(TextSpan(
        text: bold ?? m.group(2),
        style: bold != null
            ? style.copyWith(fontWeight: FontWeight.w700)
            : style.copyWith(fontStyle: FontStyle.italic),
      ));
      cursor = m.end;
    }
    if (cursor < source.length) {
      spans.add(TextSpan(text: source.substring(cursor), style: style));
    }
    return spans;
  }
}
