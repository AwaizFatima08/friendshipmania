// Data-integrity checks on the question bank itself. These exist so a
// future typo or copy-paste mistake when adding question #41 gets caught
// by `flutter test` instead of surfacing as a broken run in someone's hands.

import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/data/question_bank.dart';
import 'package:friendshipmania/services/scoring.dart' show questionsPerRun;

void main() {
  test('the bank has at least questionsPerRun entries', () {
    expect(questionBank.length, greaterThanOrEqualTo(questionsPerRun));
  });

  test('every question id is unique', () {
    final ids = questionBank.map((q) => q.id).toList();
    expect(ids.toSet().length, ids.length);
  });

  test('every question has a non-empty prompt', () {
    for (final q in questionBank) {
      expect(q.prompt.trim(), isNotEmpty, reason: 'question ${q.id}');
    }
  });

  test('every question has at least 2 answer options', () {
    for (final q in questionBank) {
      expect(q.options.length, greaterThanOrEqualTo(2), reason: 'question ${q.id}');
    }
  });

  test('every answer option has non-empty text and a non-negative score', () {
    for (final q in questionBank) {
      for (final o in q.options) {
        expect(o.text.trim(), isNotEmpty, reason: 'question ${q.id}');
        expect(o.score, greaterThanOrEqualTo(0), reason: 'question ${q.id}');
      }
    }
  });

  test('every question has a non-empty tag', () {
    for (final q in questionBank) {
      expect(q.tag.trim(), isNotEmpty, reason: 'question ${q.id}');
    }
  });

  test('maxScore reflects the actual highest option score', () {
    for (final q in questionBank) {
      final expected = q.options.map((o) => o.score).reduce((a, b) => a > b ? a : b);
      expect(q.maxScore, expected, reason: 'question ${q.id}');
    }
  });
}
