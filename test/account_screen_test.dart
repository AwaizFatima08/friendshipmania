import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/screens/account_screen.dart';
import 'package:friendshipmania/services/auth_service.dart';

import 'fakes.dart';

/// Root route "home" -> pushes the account screen, like the real app does.
Widget host({required FakeAuthService auth, required FakeUserDataService data}) {
  return fakeScreen(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AccountScreen()),
            ),
            child: const Text('open account'),
          ),
        ),
      ),
    ),
    auth: auth,
    data: data,
  );
}

Future<void> openAccount(WidgetTester tester, FakeAuthService auth, FakeUserDataService data) async {
  await tester.pumpWidget(host(auth: auth, data: data));
  await tester.tap(find.text('open account'));
  await tester.pumpAndSettle();
}

const googleUser = AppUser(uid: 'uid-g', displayName: 'Gina', email: 'gina@gmail.com');

void main() {
  testPhone('shows the name, email and initial of the signed-in user', (tester) async {
    await openAccount(tester, FakeAuthService(user: kTestUser), FakeUserDataService());

    expect(find.text('Tess Tester'), findsOneWidget);
    expect(find.text('tess@example.com'), findsOneWidget);
    expect(find.text('T'), findsOneWidget);
  });

  testPhone('sign out clears the session and returns to the root screen', (tester) async {
    final auth = FakeAuthService(user: kTestUser);
    await openAccount(tester, auth, FakeUserDataService());

    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();

    expect(auth.currentUser, isNull);
    expect(find.text('open account'), findsOneWidget);
  });

  testPhone('delete asks for a password and refuses an empty one', (tester) async {
    final auth = FakeAuthService(user: kTestUser);
    final data = FakeUserDataService();
    await openAccount(tester, auth, data);

    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();
    expect(find.text('Delete your account? 💀'), findsOneWidget);

    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Enter your password'), findsOneWidget);
    expect(auth.reauthCalls, 0);
    expect(data.deletedAllFor, isEmpty);
  });

  testPhone('a WRONG password never deletes any data (identity is verified first)',
      (tester) async {
    final auth = FakeAuthService(user: kTestUser);
    final data = FakeUserDataService();
    await openAccount(tester, auth, data);

    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'not-my-password');
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(auth.reauthCalls, 1);
    expect(data.deletedAllFor, isEmpty, reason: 'data must survive a failed re-auth');
    expect(auth.deleted, isFalse);
    expect(auth.currentUser, isNotNull);
    expect(find.textContaining("isn't it, chief"), findsOneWidget);
  });

  testPhone('the correct password deletes the data, then the account', (tester) async {
    final auth = FakeAuthService(user: kTestUser);
    final data = FakeUserDataService();
    await openAccount(tester, auth, data);

    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), kFakePassword);
    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(data.deletedAllFor, [kTestUser.uid]);
    expect(auth.deleted, isTrue);
    expect(find.text('open account'), findsOneWidget);
    expect(find.textContaining('Account deleted'), findsOneWidget);
  });

  testPhone('cancelling the delete dialog changes nothing', (tester) async {
    final auth = FakeAuthService(user: kTestUser);
    final data = FakeUserDataService();
    await openAccount(tester, auth, data);

    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keep my account'));
    await tester.pumpAndSettle();

    expect(auth.reauthCalls, 0);
    expect(data.deletedAllFor, isEmpty);
    expect(auth.deleted, isFalse);
  });

  testPhone('Google accounts are not asked for a password', (tester) async {
    final auth = FakeAuthService(user: googleUser);
    final data = FakeUserDataService();
    await openAccount(tester, auth, data);

    await tester.tap(find.text('Delete account & data'));
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
    expect(find.textContaining('confirm with Google'), findsOneWidget);

    await tester.tap(find.text('Delete forever'));
    await tester.pumpAndSettle();

    expect(data.deletedAllFor, [googleUser.uid]);
    expect(auth.deleted, isTrue);
  });
}
