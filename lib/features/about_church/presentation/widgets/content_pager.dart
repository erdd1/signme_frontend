import 'package:flutter/material.dart';
import 'article_text_paginator.dart';
import '../../../../core/design_system/index.dart';

/// A reusable horizontal pager that renders long article text as
/// horizontally swipable pages. It measures the available width and
/// computes pages of approximately `linesPerPage` using
/// [ArticleTextPaginator.paginate].
class ContentPager extends StatefulWidget {
  const ContentPager({
    super.key,
    required this.text,
    this.style,
    this.linesPerPage = 10,
    this.textDirection,
  });

  final String text;
  final TextStyle? style;
  final int linesPerPage;
  final TextDirection? textDirection;

  @override
  State<ContentPager> createState() => _ContentPagerState();
}

class _ContentPagerState extends State<ContentPager> {
  final PageController _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? SignmeTypography.bodyMedium.copyWith(height: 1.5);
    final direction = widget.textDirection ?? Directionality.of(context);
    final textScale = MediaQuery.textScaleFactorOf(context);

    return LayoutBuilder(builder: (context, constraints) {
      final maxWidth = constraints.maxWidth;

      // Compute approximate line height using TextPainter for one line.
      final tp = TextPainter(
        text: TextSpan(text: 'A', style: style),
        textDirection: direction,
        textScaleFactor: textScale,
      );
      tp.layout(minWidth: 0, maxWidth: maxWidth);
      final lineHeight = tp.height;

      final pageHeight = lineHeight * widget.linesPerPage;

      final pages = ArticleTextPaginator.paginate(
        widget.text,
        maxWidth: maxWidth,
        pageHeight: pageHeight,
        style: style,
        textDirection: direction,
        textScaleFactor: textScale,
      );

      if (pages.length <= 1) {
        return Text(widget.text, style: style, textDirection: direction, textScaleFactor: textScale);
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: pageHeight,
            child: PageView.builder(
              controller: _controller,
              onPageChanged: (i) => setState(() => _page = i),
              itemCount: pages.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: SignmeSpacing.sm),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Text(
                    pages[i],
                    style: style,
                    textDirection: direction,
                    textScaleFactor: textScale,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: SignmeSpacing.sm),
          _buildIndicator(pages.length),
        ],
      );
    });
  }

  /// Au-delà de ce nombre de pages, les points n'ont plus la place de
  /// tenir sur une ligne quelle que soit la largeur du card (articles très
  /// longs, jusqu'à [AboutArticleEntity.maxMotsContenu] mots) — on bascule
  /// alors sur un indicateur textuel compact "3 / 14".
  static const _maxDots = 8;

  Widget _buildIndicator(int count) {
    if (count > _maxDots) {
      return Align(
        alignment: Alignment.center,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: SignmeColors.lightGrayBorder.withOpacity(0.5),
            borderRadius: BorderRadius.circular(SignmeSpacing.radiusFull),
          ),
          child: Text(
            '${_page + 1} / $count',
            style: SignmeTypography.labelSmall.copyWith(
              color: SignmeColors.primaryDark,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == _page;
        return Container(
          width: active ? 10 : 7,
          height: active ? 10 : 7,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: active ? SignmeColors.primaryDark : SignmeColors.lightGrayBorder,
            borderRadius: BorderRadius.circular(8),
          ),
        );
      }),
    );
  }
}
