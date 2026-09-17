// Layout/overflow checks for the ReportCard at the edges of its input
// range — this is the exact widget that gets rasterized into the shared
// PNG, so a silent RenderFlex overflow here would end up baked into every
// screenshot a user sends their friend.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/services/scoring.dart';
import 'package:friendshipmania/widgets/report_card.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  testWidgets('renders cleanly at 0%', (tester) async {
    await tester.pumpWidget(_wrap(ReportCard(
      yourName: 'Homi',
      friendName: 'Sam',
      percent: 0,
      band: bandForPercent(0),
      breakdown: const [],
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cleanly at 100%', (tester) async {
    await tester.pumpWidget(_wrap(ReportCard(
      yourName: 'Homi',
      friendName: 'Sam',
      percent: 100,
      band: bandForPercent(100),
      breakdown: const [],
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cleanly with the maximum-length names allowed by the '
      'names screen (30 chars each)', (tester) async {
    await tester.pumpWidget(_wrap(ReportCard(
      yourName: 'A very long name indeed here!',
      friendName: 'Another quite lengthy name!!!',
      percent: 63,
      band: bandForPercent(63),
      breakdown: const [],
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('renders cleanly with a full 5-tag breakdown', (tester) async {
    await tester.pumpWidget(_wrap(ReportCard(
      yourName: 'Homi',
      friendName: 'Sam',
      percent: 72,
      band: bandForPercent(72),
      breakdown: const [
        TagScore(tag: 'roast', label: '🔥 Roast Resilience', percent: 80),
        TagScore(tag: 'loyalty', label: '🛡️ Loyalty', percent: 90),
        TagScore(tag: 'chaos', label: '🎢 Chaos Compatibility', percent: 40),
        TagScore(tag: 'receipts', label: '🧾 Brutal Honesty', percent: 60),
        TagScore(tag: 'nostalgia', label: '📼 History Together', percent: 100),
      ],
    )));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
