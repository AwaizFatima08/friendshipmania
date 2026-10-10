// Guards against "tofu": emoji newer than the phone's emoji font render as an
// empty box. The app supports Android 7+, and Flutter uses the *system*
// emoji font, so every emoji shipped must exist on old phones too (roughly
// Unicode 9). Anything newer (e.g. 🫡 🫶 🧊 🧾) shows as ▯ on most devices.
//
// To use a new emoji, check it exists on Android 7 (Unicode 9 or older),
// then add it to `approved` below on purpose.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Every emoji/symbol the app uses, all supported back to Android 7.
const approved = <String>{
  '😂', '🤡', '🚩', '⭐', '👍', '✨', '🕵', '😎', '💀', '📬', '🎉', '👋',
  '🐺', '🚀', '🔓', '📋', '📡', '🔍', '🍿', '🔥', '🌡', '🔁', '💾', '✅',
  '😬', '👀', '💅', '⏳', '📶', '💪', '👉', '❄', '🤔', '👑', '🛡', '🎢',
  '📼', '💖', '🙏', '📜', '📝', '→',
};

final _symbolPattern = RegExp(
  '[\u{1F000}-\u{1FAFF}\u{2600}-\u{27BF}\u{2B00}-\u{2BFF}\u{2300}-\u{23FF}\u{2190}-\u{21FF}]',
  unicode: true,
);

void main() {
  test('every emoji in lib/ is on the approved, old-phone-safe list', () {
    final offenders = <String>[];
    for (final file in Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('.dart'))) {
      final lines = file.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        for (final m in _symbolPattern.allMatches(lines[i])) {
          final ch = m.group(0)!;
          if (!approved.contains(ch)) {
            offenders.add('${file.path}:${i + 1} U+${ch.runes.first.toRadixString(16).toUpperCase()} $ch');
          }
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'These emoji may show as empty boxes on older Android phones:\n${offenders.join('\n')}');
  });

  test('the five known-bad emoji are really gone', () {
    for (final bad in ['🫶', '🫡', '🧊', '🧾', '🤨']) {
      expect(approved.contains(bad), isFalse, reason: bad);
    }
  });
}
