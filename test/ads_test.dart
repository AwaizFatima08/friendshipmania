import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/data/question_bank.dart';
import 'package:friendshipmania/screens/about_screen.dart';
import 'package:friendshipmania/screens/history_screen.dart';
import 'package:friendshipmania/screens/question_screen.dart';
import 'package:friendshipmania/screens/result_screen.dart';
import 'package:friendshipmania/services/ads_service.dart';
import 'package:friendshipmania/widgets/report_card.dart';

import 'fakes.dart';

void main() {
  group('ad unit IDs', () {
    test('debug builds always use Google\'s test unit', () {
      for (final p in AdPlacement.values) {
        expect(bannerAdUnitId(p, release: false), contains('3940256099942544'));
      }
    });

    test('release builds never fall back to the test unit', () {
      for (final p in AdPlacement.values) {
        expect(bannerAdUnitId(p, release: true), isNot(contains('3940256099942544')));
      }
    });
  });

  testPhone('the verdict screen shows a banner, outside the shareable scorecard',
      (tester) async {
    final ads = RecordingAds();
    final questions = questionBank.take(10).toList();
    await tester.pumpWidget(fakeScreen(
      ResultScreen(
        yourName: 'Tess',
        friendName: 'Sam',
        questions: questions,
        chosenScores: List.filled(questions.length, 2),
      ),
      ads: ads,
    ));
    await tester.pumpAndSettle();

    final banner = find.byKey(const Key('ad-result'));
    expect(banner, findsOneWidget);
    expect(ads.requested, [AdPlacement.result]);
    // The downloaded/shared image is the keyed RepaintBoundary around the card.
    final scorecard = find
        .ancestor(of: find.byType(ReportCard), matching: find.byType(RepaintBoundary))
        .first;
    expect(find.descendant(of: scorecard, matching: banner), findsNothing);
  });

  testPhone('My verdicts shows a banner', (tester) async {
    final ads = RecordingAds();
    await tester.pumpWidget(fakeScreen(const HistoryScreen(uid: 'uid-test'), ads: ads));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('ad-history')), findsOneWidget);
  });

  testPhone('no ads while answering the questions', (tester) async {
    final ads = RecordingAds();
    await tester.pumpWidget(fakeScreen(
      const QuestionScreen(yourName: 'Tess', friendName: 'Sam'),
      ads: ads,
    ));
    await tester.pumpAndSettle();
    expect(ads.requested, isEmpty);
  });

  testPhone('About offers privacy & ad choices only where consent law requires it',
      (tester) async {
    final ads = RecordingAds()..privacyRequired = true;
    await tester.pumpWidget(fakeScreen(const AboutScreen(), ads: ads));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacy & ad choices'));
    expect(ads.privacyFormShown, 1);

    final noConsentNeeded = RecordingAds();
    await tester.pumpWidget(fakeScreen(const AboutScreen(), ads: noConsentNeeded));
    await tester.pumpAndSettle();
    expect(find.text('Privacy & ad choices'), findsNothing);
  });
}
