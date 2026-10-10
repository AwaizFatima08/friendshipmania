// Core user-flow tests for friendshipmania, run against in-memory fakes:
// welcome → (sign-in gate) → names → quiz → scorecard, plus the stress and
// robustness checks that caught real bugs earlier.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/data/question_bank.dart';
import 'package:friendshipmania/services/scoring.dart'
    show questionsPerRun, pickRandomQuestions, scoreToPercent;

import 'fakes.dart';

const startButton = 'Start the Interrogation 🕵️';
const quizButton = 'Start the quiz 🚀';

/// Welcome → names screen as a guest (taps through "skip for now").
Future<void> goToNamesAsGuest(WidgetTester tester) async {
  await tester.tap(find.text(startButton));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('Skip'));
  await tester.pumpAndSettle();
}

Future<void> fillNamesAndStart(WidgetTester tester, {String you = 'Homi', String friend = 'Sam'}) async {
  await tester.enterText(find.byType(TextFormField).first, you);
  await tester.enterText(find.byType(TextFormField).last, friend);
  await tester.tap(find.text(quizButton));
  await tester.pumpAndSettle();
}

Future<void> answerAll(WidgetTester tester) async {
  for (var i = 0; i < questionsPerRun; i++) {
    await tester.tap(find.byType(OutlinedButton).first);
    await tester.pumpAndSettle();
  }
}

void main() {
  testPhone('Welcome screen shows the app name, start button and Sign in',
      (tester) async {
    await tester.pumpWidget(fakeApp());

    expect(find.textContaining('friendshipmania'), findsWidgets);
    expect(find.text(startButton), findsOneWidget);
    expect(find.text('Sign in'), findsOneWidget);
  });

  testPhone('Signed-out start shows the auth screen; skipping reaches names',
      (tester) async {
    await tester.pumpWidget(fakeApp());

    await tester.tap(find.text(startButton));
    await tester.pumpAndSettle();
    expect(find.textContaining('Hop in'), findsOneWidget);

    await tester.tap(find.textContaining('Skip'));
    await tester.pumpAndSettle();
    expect(find.textContaining("Who's on trial"), findsOneWidget);
  });

  testPhone('After skipping once, starting again goes straight to names',
      (tester) async {
    await tester.pumpWidget(fakeApp());
    await goToNamesAsGuest(tester);

    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text(startButton));
    await tester.pumpAndSettle();

    expect(find.textContaining("Who's on trial"), findsOneWidget);
    expect(find.textContaining('Hop in'), findsNothing);
  });

  testPhone('Signed-in start skips auth and prefills your name',
      (tester) async {
    await tester.pumpWidget(fakeApp(auth: FakeAuthService(user: kTestUser)));

    expect(find.text('Sign in'), findsNothing);
    await tester.tap(find.text(startButton));
    await tester.pumpAndSettle();

    expect(find.textContaining("Who's on trial"), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Tess Tester'), findsOneWidget);
  });

  testPhone('Welcome starts the background music once', (tester) async {
    final audio = RecordingAudio();
    await tester.pumpWidget(fakeApp(audio: audio));
    await tester.pump();

    expect(audio.musicStarts, 1);
  });

  testPhone('Entering both names moves to the first question', (tester) async {
    await tester.pumpWidget(fakeApp());
    await goToNamesAsGuest(tester);
    await fillNamesAndStart(tester);

    expect(find.textContaining('Question 1 of 10'), findsOneWidget);
  });

  testPhone('Blank names are rejected before the quiz starts', (tester) async {
    await tester.pumpWidget(fakeApp());
    await goToNamesAsGuest(tester);

    await tester.tap(find.text(quizButton));
    await tester.pumpAndSettle();

    expect(find.textContaining('Kind of need a name here'), findsNWidgets(2));
    expect(find.textContaining('Question 1 of'), findsNothing);
  });

  testPhone('A very long name does not crash the names screen', (tester) async {
    await tester.pumpWidget(fakeApp());
    await goToNamesAsGuest(tester);
    await fillNamesAndStart(tester, you: 'A' * 500);

    // maxLength: 30 on the field means only the first 30 chars are kept.
    expect(find.textContaining('Question 1 of 10'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testPhone('Guest finishing the quiz sees the scorecard and a sign-in nudge',
      (tester) async {
    final data = FakeUserDataService();
    await tester.pumpWidget(fakeApp(data: data));
    await goToNamesAsGuest(tester);
    await fillNamesAndStart(tester);
    await answerAll(tester);

    expect(find.textContaining('Your verdict'), findsOneWidget);
    expect(find.textContaining('Homi on Sam'), findsOneWidget);
    expect(find.text('Download'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
    expect(find.textContaining('Sign in to save this verdict'), findsOneWidget);
    expect(data.saveCalls, 0);
  });

  testPhone('Signed-in finishing the quiz saves exactly one report',
      (tester) async {
    final data = FakeUserDataService();
    await tester.pumpWidget(fakeApp(
      auth: FakeAuthService(user: kTestUser),
      data: data,
    ));
    await tester.tap(find.text(startButton));
    await tester.pumpAndSettle();
    await fillNamesAndStart(tester, you: 'Tess', friend: 'Sam');
    await answerAll(tester);

    expect(find.textContaining('Saved to your history'), findsOneWidget);
    expect(data.saveCalls, 1);
    expect(data.savedPercents.single, inInclusiveRange(0, 100));
    expect(data.reportsFor(kTestUser.uid).single.friendName, 'Sam');
  });

  testPhone('A failed save shows a retry prompt instead of crashing',
      (tester) async {
    final data = FakeUserDataService()..saveError = Exception('permission-denied');
    await tester.pumpWidget(fakeApp(
      auth: FakeAuthService(user: kTestUser),
      data: data,
    ));
    await tester.tap(find.text(startButton));
    await tester.pumpAndSettle();
    await fillNamesAndStart(tester);
    await answerAll(tester);

    expect(find.textContaining("Couldn't save to your history"), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testPhone('Answering plays the answer sound, and the reveal plays at the end',
      (tester) async {
    final audio = RecordingAudio();
    await tester.pumpWidget(fakeApp(audio: audio));
    await goToNamesAsGuest(tester);
    await fillNamesAndStart(tester);
    await answerAll(tester);

    expect(audio.played.where((s) => s.name == 'answer').length, questionsPerRun);
    expect(audio.played.where((s) => s.name == 'reveal').length, 1);
  });

  testPhone('Answers are shuffled: the top option is not always the best one',
      (tester) async {
    var firstWasBest = 0;
    const runs = 12;

    for (var i = 0; i < runs; i++) {
      // A fresh key forces a brand-new app (and navigation stack) each run.
      await tester.pumpWidget(fakeApp(key: UniqueKey()));
      await goToNamesAsGuest(tester);
      await fillNamesAndStart(tester);

      final prompt = questionBank
          .map((q) => q.prompt)
          .firstWhere((p) => find.text(p).evaluate().isNotEmpty);
      final question = questionBank.firstWhere((q) => q.prompt == prompt);
      final bestText = question.options.firstWhere((o) => o.score == question.maxScore).text;

      final firstButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton).first);
      final firstText = ((firstButton.child) as Text).data;
      if (firstText == bestText) firstWasBest++;
    }

    // If answers weren't shuffled this would be `runs` every single time.
    expect(firstWasBest, lessThan(runs));
  });

  testPhone('Rapidly double-tapping an answer does not skip or crash the quiz',
      (tester) async {
    await tester.pumpWidget(fakeApp());
    await goToNamesAsGuest(tester);
    await fillNamesAndStart(tester);

    for (var i = 0; i < questionsPerRun; i++) {
      final option = find.byType(OutlinedButton).first;
      // Two taps back-to-back with no pump in between, simulating a real
      // fast double-tap that lands before setState's rebuild.
      await tester.tap(option);
      await tester.tap(option);
      await tester.pumpAndSettle();
    }

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
