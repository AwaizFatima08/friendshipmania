// Endurance/fuzz coverage for the scoring math: run it hundreds of times
// with random samples and random answers, and make sure the numbers it
// produces are never out of range no matter what combination comes up.

import 'package:flutter_test/flutter_test.dart';
import 'dart:math';

import 'package:friendshipmania/data/question_bank.dart';
import 'package:friendshipmania/services/scoring.dart';

void main() {
  test('scoreToPercent and tagBreakdown stay in 0-100 across 500 random runs',
      () {
    final random = Random(42);

    for (var run = 0; run < 500; run++) {
      final questions = pickRandomQuestions(questionsPerRun);
      final chosen = questions
          .map((q) => q.options[random.nextInt(q.options.length)].score)
          .toList();

      final percent = scoreToPercent(questions, chosen);
      expect(percent, inInclusiveRange(0, 100),
          reason: 'run $run produced an out-of-range percent: $percent');

      final breakdown = tagBreakdown(questions, chosen);
      for (final t in breakdown) {
        expect(t.percent, inInclusiveRange(0, 100),
            reason: 'run $run, tag ${t.tag} produced ${t.percent}%');
      }

      // Every question sampled should show up in exactly one tag bucket,
      // and the tag buckets should never invent or drop a question.
      final coveredQuestionCount = breakdown.fold<int>(
        0,
        (sum, t) => sum + questions.where((q) => q.tag == t.tag).length,
      );
      expect(coveredQuestionCount, questions.length);
    }
  });

  test('pickRandomQuestions never repeats a question within one run', () {
    for (var run = 0; run < 200; run++) {
      final questions = pickRandomQuestions(questionsPerRun);
      final ids = questions.map((q) => q.id).toSet();
      expect(ids.length, questions.length,
          reason: 'run $run contained a duplicate question');
    }
  });

  test('pickRandomQuestions with a count larger than the bank still returns '
      'only unique questions, capped at the bank size', () {
    final questions = pickRandomQuestions(questionBank.length + 50);
    expect(questions.length, questionBank.length);
    expect(questions.map((q) => q.id).toSet().length, questionBank.length);
  });

  test('scoreToPercent handles an empty run without dividing by zero', () {
    expect(scoreToPercent([], []), 0);
  });

  test('bandForPercent covers the full 0-100 range with no gaps', () {
    for (var p = 0; p <= 100; p++) {
      final band = bandForPercent(p);
      expect(p, inInclusiveRange(band.minPercent, band.maxPercent));
    }
  });

  test('bandForPercent is defensive about out-of-range input', () {
    // Real scores never go negative or above 100, but bandForPercent
    // shouldn't throw if it's ever handed something unexpected.
    expect(() => bandForPercent(-5), returnsNormally);
    expect(() => bandForPercent(105), returnsNormally);
  });
}
