// Basic smoke tests for The Friendship Polygraph, stage 1:
// welcome screen loads, names can be entered, and a full 10-question
// run produces a scorecard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendship_polygraph/main.dart';
import 'package:friendship_polygraph/services/scoring.dart' show questionsPerRun, pickRandomQuestions, scoreToPercent;

void main() {
  testWidgets('Welcome screen shows the app name and a start button',
      (tester) async {
    await tester.pumpWidget(const FriendshipPolygraphApp());

    expect(find.textContaining('Friendship'), findsWidgets);
    expect(find.text('Start the interrogation'), findsOneWidget);
  });

  testWidgets('Entering both names moves to the first question',
      (tester) async {
    await tester.pumpWidget(const FriendshipPolygraphApp());

    await tester.tap(find.text('Start the interrogation'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Homi');
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1 of 10'), findsOneWidget);
  });

  testWidgets('Answering all 10 questions reaches a scorecard',
      (tester) async {
    await tester.pumpWidget(const FriendshipPolygraphApp());

    await tester.tap(find.text('Start the interrogation'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Homi');
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz'));
    await tester.pumpAndSettle();

    for (var i = 0; i < questionsPerRun; i++) {
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();
    }

    expect(find.text('Your verdict'), findsOneWidget);
    expect(find.textContaining('Homi on Sam'), findsOneWidget);
  });

  test('scoreToPercent stays within 0-100 for every possible run', () {
    final questions = pickRandomQuestions(questionsPerRun);
    final worst = questions.map((q) => 0).toList();
    final best = questions.map((q) => q.maxScore).toList();

    expect(scoreToPercent(questions, worst), 0);
    expect(scoreToPercent(questions, best), 100);
  });
}
