// Core user-flow tests for friendshipmania: welcome screen loads, names can
// be entered, and a full 10-question run produces a scorecard.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/main.dart';
import 'package:friendshipmania/services/scoring.dart'
    show questionsPerRun, pickRandomQuestions, scoreToPercent;

void main() {
  testWidgets('Welcome screen shows the app name and a start button',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    expect(find.textContaining('friendshipmania'), findsWidgets);
    expect(find.text('Start the Interrogation 🕵️'), findsOneWidget);
  });

  testWidgets('Entering both names moves to the first question',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    await tester.tap(find.text('Start the Interrogation 🕵️'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'Homi');
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz 🚀'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Question 1 of 10'), findsOneWidget);
  });

  testWidgets('Blank names are rejected before the quiz starts',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    await tester.tap(find.text('Start the Interrogation 🕵️'));
    await tester.pumpAndSettle();

    // Leave both fields empty and try to submit anyway.
    await tester.tap(find.text('Start the quiz 🚀'));
    await tester.pumpAndSettle();

    expect(find.text('Kind of need a name here.'), findsNWidgets(2));
    // Still on the names screen, never reached a question.
    expect(find.textContaining('Question 1 of'), findsNothing);
  });

  testWidgets('A very long name does not crash the names screen',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    await tester.tap(find.text('Start the Interrogation 🕵️'));
    await tester.pumpAndSettle();

    final longName = 'A' * 500;
    await tester.enterText(find.byType(TextFormField).first, longName);
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz 🚀'));
    await tester.pumpAndSettle();

    // maxLength: 30 on the field means only the first 30 chars are kept.
    expect(find.textContaining('Question 1 of 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Answering all 10 questions reaches a scorecard',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    await tester.tap(find.text('Start the Interrogation 🕵️'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Homi');
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz 🚀'));
    await tester.pumpAndSettle();

    for (var i = 0; i < questionsPerRun; i++) {
      await tester.tap(find.byType(OutlinedButton).first);
      await tester.pumpAndSettle();
    }

    expect(find.textContaining('Your verdict'), findsOneWidget);
    expect(find.textContaining('Homi on Sam'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets(
      'Rapidly double-tapping an answer does not skip or crash the quiz',
      (tester) async {
    await tester.pumpWidget(const FriendshipManiaApp());

    await tester.tap(find.text('Start the Interrogation 🕵️'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).first, 'Homi');
    await tester.enterText(find.byType(TextFormField).last, 'Sam');
    await tester.tap(find.text('Start the quiz 🚀'));
    await tester.pumpAndSettle();

    for (var i = 0; i < questionsPerRun; i++) {
      final option = find.byType(OutlinedButton).first;
      // Fire two taps back-to-back with no pump in between, simulating a
      // real fast double-tap that lands before setState's rebuild.
      await tester.tap(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

    // If the double-tap guard didn't work, this would either throw a
    // RangeError (index past the question list) or land on a second
    // ResultScreen pushed on top of the first.
    expect(tester.takeException(), isNull);
    expect(find.textContaining('Your verdict'), findsOneWidget);
  });

  test('scoreToPercent stays within 0-100 for every possible run', () {
    final questions = pickRandomQuestions(questionsPerRun);
    final worst = questions.map((q) => 0).toList();
    final best = questions.map((q) => q.maxScore).toList();

    expect(scoreToPercent(questions, worst), 0);
    expect(scoreToPercent(questions, best), 100);
  });
}
