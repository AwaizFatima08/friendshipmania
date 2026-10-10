import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/screens/history_screen.dart';
import 'package:friendshipmania/services/user_data_service.dart';

import 'fakes.dart';

SavedReport report(String id, String friend, int percent) => SavedReport(
      id: id,
      yourName: 'Tess',
      friendName: friend,
      percent: percent,
      bandTitle: 'Actual Real Friends, No Cap',
      bandEmoji: '🔥',
      createdAt: DateTime(2026, 10, 10),
    );

void main() {
  test('formatDate is readable and tolerates a missing timestamp', () {
    expect(HistoryScreen.formatDate(DateTime(2026, 10, 9)), '9 Oct 2026');
    expect(HistoryScreen.formatDate(null), 'just now');
  });

  testPhone('shows a funny empty state when there are no verdicts', (tester) async {
    await tester.pumpWidget(fakeScreen(const HistoryScreen(uid: 'u1')));
    await tester.pumpAndSettle();

    expect(find.textContaining('suspiciously un-judged'), findsOneWidget);
  });

  testPhone('lists saved verdicts with names, percent and date', (tester) async {
    final data = FakeUserDataService()
      ..seed('u1', [report('a', 'Sam', 72), report('b', 'Alex', 35)]);
    await tester.pumpWidget(fakeScreen(const HistoryScreen(uid: 'u1'), data: data));
    await tester.pumpAndSettle();

    expect(find.text('Tess on Sam'), findsOneWidget);
    expect(find.text('Tess on Alex'), findsOneWidget);
    expect(find.textContaining('72%'), findsOneWidget);
    expect(find.textContaining('10 Oct 2026'), findsNWidgets(2));
  });

  testPhone("only shows the signed-in user's own verdicts", (tester) async {
    final data = FakeUserDataService()
      ..seed('u1', [report('a', 'Sam', 72)])
      ..seed('someone-else', [report('z', 'Intruder', 99)]);
    await tester.pumpWidget(fakeScreen(const HistoryScreen(uid: 'u1'), data: data));
    await tester.pumpAndSettle();

    expect(find.text('Tess on Sam'), findsOneWidget);
    expect(find.textContaining('Intruder'), findsNothing);
  });

  testPhone('deleting a verdict asks first, then removes it', (tester) async {
    final data = FakeUserDataService()..seed('u1', [report('a', 'Sam', 72)]);
    await tester.pumpWidget(fakeScreen(const HistoryScreen(uid: 'u1'), data: data));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Delete this verdict'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this verdict?'), findsOneWidget);

    // "Keep it" leaves the verdict alone.
    await tester.tap(find.text('Keep it'));
    await tester.pumpAndSettle();
    expect(data.reportsFor('u1'), hasLength(1));

    await tester.tap(find.byTooltip('Delete this verdict'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(data.reportsFor('u1'), isEmpty);
    expect(find.textContaining('suspiciously un-judged'), findsOneWidget);
  });
}
