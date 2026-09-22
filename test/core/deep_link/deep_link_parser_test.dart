import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/deep_link/deep_link_parser.dart';

void main() {
  group('DeepLinkParser — signme://reset-password', () {
    test('parse reset password with email and token', () {
      final uri = Uri.parse(
        'signme://reset-password?email=user%40test.com&token=abc123',
      );
      final target = DeepLinkParser.resolve(uri);
      expect(target?.location, '/reset-password?email=user%40test.com&token=abc123');
      expect(target?.requiresAuth, isFalse);
    });

    test('ignores unknown scheme', () {
      final uri = Uri.parse('signme://something-else');
      expect(DeepLinkParser.resolve(uri), isNull);
    });

    test('reset without query opens screen', () {
      final uri = Uri.parse('signme://reset-password');
      final target = DeepLinkParser.resolve(uri);
      expect(target?.location, '/reset-password');
      expect(target?.requiresAuth, isFalse);
    });
  });

  group('DeepLinkParser — https://signmecy.org (partage événement)', () {
    test('parse event share link', () {
      final uri = Uri.parse('https://signmecy.org/evenements/abc-123-uuid');
      final target = DeepLinkParser.resolve(uri);
      expect(target?.location, '/evenements/abc-123-uuid');
      expect(target?.requiresAuth, isTrue);
    });

    test('ignores unrelated https host', () {
      final uri = Uri.parse('https://example.com/evenements/abc-123-uuid');
      expect(DeepLinkParser.resolve(uri), isNull);
    });

    test('ignores unknown path on the right host', () {
      final uri = Uri.parse('https://signmecy.org/autre-chose/xyz');
      expect(DeepLinkParser.resolve(uri), isNull);
    });

    test('ignores event path with empty uuid', () {
      final uri = Uri.parse('https://signmecy.org/evenements/');
      expect(DeepLinkParser.resolve(uri), isNull);
    });
  });
}
