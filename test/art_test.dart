import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/config.dart';
import 'package:friendshipmania/services/scoring.dart';
import 'package:friendshipmania/widgets/cropped_art.dart';

void main() {
  final shownArt = [mascotAsset, for (final b in soloScoreBands) b.sticker];

  test('every verdict band has its own sticker', () {
    expect(soloScoreBands.map((b) => b.sticker).toSet().length, soloScoreBands.length);
  });

  test('every piece of art the app shows exists on disk', () {
    for (final a in shownArt) {
      expect(File(a).existsSync(), isTrue, reason: a);
    }
  });

  test('every piece of art has a measured crop (otherwise it renders tiny)', () {
    for (final a in shownArt) {
      expect(artCrops.containsKey(a), isTrue, reason: '$a has no ArtCrop entry');
    }
  });

  test('all crops stay inside the image', () {
    artCrops.forEach((asset, c) {
      expect(c.left, inInclusiveRange(0, 1), reason: asset);
      expect(c.top, inInclusiveRange(0, 1), reason: asset);
      expect(c.width, inExclusiveRange(0, 1.0001), reason: asset);
      expect(c.height, inExclusiveRange(0, 1.0001), reason: asset);
      expect(c.left + c.width, lessThanOrEqualTo(1.0001), reason: asset);
      expect(c.top + c.height, lessThanOrEqualTo(1.0001), reason: asset);
    });
  });
}
