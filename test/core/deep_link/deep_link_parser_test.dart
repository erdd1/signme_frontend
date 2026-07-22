import 'package:flutter_test/flutter_test.dart';
import 'package:signme/core/deep_link/deep_link_parser.dart';

void main() {
  group('DeepLinkParser', () {
    test('parse reset password with email and token', () {
      final uri = Uri.parse(
        'signme://reset-password?email=user%40test.com&token=abc123',
      );
      expect(
        DeepLinkParser.toGoRouteLocation(uri),
        '/reset-password?email=user%40test.com&token=abc123',
      );
    });

    test('ignores unknown scheme', () {
      final uri = Uri.parse('https://example.com/reset');
      expect(DeepLinkParser.toGoRouteLocation(uri), isNull);
    });

    test('reset without query opens screen', () {
      final uri = Uri.parse('signme://reset-password');
      expect(DeepLinkParser.toGoRouteLocation(uri), '/reset-password');
    });
  });
}
