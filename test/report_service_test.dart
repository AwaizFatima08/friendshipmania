import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/services/report_service.dart';

void main() {
  group('sanitizeForShareText', () {
    test('trims surrounding whitespace', () {
      expect(sanitizeForShareText('  Homi  '), 'Homi');
    });

    test('collapses newlines and tabs into single spaces', () {
      expect(sanitizeForShareText('Ho\nmi\t\tSam'), 'Ho mi Sam');
    });

    test('caps length at 60 characters so a pasted essay cannot bloat the '
        'share text', () {
      final huge = 'x' * 500;
      final result = sanitizeForShareText(huge);
      expect(result.length, 60);
    });

    test('leaves a normal name untouched', () {
      expect(sanitizeForShareText('Sam'), 'Sam');
    });

    test('handles an already-empty string without throwing', () {
      expect(sanitizeForShareText(''), '');
    });
  });

  test('playStoreUrl is a well-formed https link', () {
    final uri = Uri.parse(playStoreUrl);
    expect(uri.scheme, 'https');
    expect(uri.host, 'play.google.com');
  });
}
