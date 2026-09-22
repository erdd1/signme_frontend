import 'package:flutter/widgets.dart';

/// Lightweight visual paginator for long article text.
///
/// It uses `TextPainter` to measure rendered height for a given width,
/// text style and `textScaleFactor`, then splits the string into pages
/// by binary-searching the largest substring that fits into `pageHeight`.
/// Results are memoized by a cache key composed from the text, width,
/// textScaleFactor and style hash to avoid repeated layout work.
class ArticleTextPaginator {
  ArticleTextPaginator._();

  static final Map<String, List<String>> _cache = {};

  static String _cacheKey(String text, double maxWidth, double pageHeight, double textScaleFactor, TextStyle style, TextDirection direction) {
    return '${text.hashCode}::$maxWidth::$pageHeight::${textScaleFactor}::${style.hashCode}::${direction.index}';
  }

  static List<String> paginate(
    String text, {
    required double maxWidth,
    required double pageHeight,
    required TextStyle style,
    required TextDirection textDirection,
    required double textScaleFactor,
  }) {
    if (text.isEmpty) return [''];
    final key = _cacheKey(text, maxWidth, pageHeight, textScaleFactor, style, textDirection);
    final cached = _cache[key];
    if (cached != null) return cached;

    final pages = <String>[];
    final length = text.length;
    int start = 0;

    final textPainter = TextPainter(textDirection: textDirection, textScaleFactor: textScaleFactor);

    while (start < length) {
      int low = start + 1;
      int high = length;
      int best = low;

      while (low <= high) {
        final mid = (low + high) >> 1;
        final span = TextSpan(text: text.substring(start, mid), style: style);
        textPainter.text = span;
        textPainter.layout(minWidth: 0, maxWidth: maxWidth);
        if (textPainter.height <= pageHeight) {
          best = mid;
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }

      if (best <= start) {
        // Fallback: force at least one character to avoid infinite loop.
        best = (start + 1).clamp(0, length);
      }

      // Try to avoid splitting a word: backtrack to last whitespace within range.
      if (best < length && !_isWhitespace(text.codeUnitAt(best))) {
        final lastSpace = text.lastIndexOf(RegExp(r'\s'), best - 1);
        if (lastSpace != -1 && lastSpace > start) {
          best = lastSpace + 1;
        }
      }

      final page = text.substring(start, best).trimRight();
      pages.add(page);
      start = best;
    }

    _cache[key] = pages;
    return pages;
  }

  static bool _isWhitespace(int codeUnit) {
    return codeUnit == 32 || codeUnit == 10 || codeUnit == 13 || codeUnit == 9;
  }
}
