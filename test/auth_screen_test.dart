import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/screens/auth_screen.dart';
import 'package:friendshipmania/services/app_services.dart';
import 'package:friendshipmania/services/auth_service.dart';

import 'fakes.dart';

/// Hosts the auth screen behind a button so we can observe what it pops with.
class _Host extends StatefulWidget {
  const _Host({required this.allowGuest});
  final bool allowGuest;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  bool? result;
  bool returned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              final r = await Navigator.of(context).push<bool>(MaterialPageRoute(
                builder: (_) => AuthScreen(allowGuest: widget.allowGuest),
              ));
              setState(() {
                result = r;
                returned = true;
              });
            },
            child: const Text('open'),
          ),
          Text(returned ? 'popped:$result' : 'waiting'),
        ],
      ),
    );
  }
}

Future<void> openAuth(WidgetTester tester, {
  FakeAuthService? auth,
  FakeUserDataService? data,
  AppSession? session,
  bool allowGuest = true,
}) async {
  await tester.pumpWidget(fakeScreen(
    _Host(allowGuest: allowGuest),
    auth: auth,
    data: data,
    session: session,
  ));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testPhone('sign-up form validates every field', (tester) async {
    await openAuth(tester);

    await tester.tap(find.text('Create my account 🚀'));
    await tester.pumpAndSettle();

    expect(find.textContaining('What do we call you'), findsOneWidget);
    expect(find.textContaining("doesn't look like an email"), findsOneWidget);
    expect(find.textContaining('Password needed'), findsOneWidget);
  });

  testPhone('sign-up rejects a password under 8 characters', (tester) async {
    final auth = FakeAuthService();
    await openAuth(tester, auth: auth);

    await tester.enterText(find.widgetWithText(TextFormField, 'Your name or nickname'), 'Sam');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'short');
    await tester.tap(find.text('Create my account 🚀'));
    await tester.pumpAndSettle();

    expect(find.textContaining('At least 8 characters'), findsOneWidget);
    expect(auth.signUpCalls, 0);
  });

  testPhone('successful sign-up creates the account, saves a profile and pops true',
      (tester) async {
    final auth = FakeAuthService();
    final data = FakeUserDataService();
    await openAuth(tester, auth: auth, data: data);

    await tester.enterText(find.widgetWithText(TextFormField, 'Your name or nickname'), 'Sam');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), kFakePassword);
    await tester.tap(find.text('Create my account 🚀'));
    await tester.pumpAndSettle();

    expect(auth.currentUser?.email, 'sam@example.com');
    expect(auth.currentUser?.displayName, 'Sam');
    expect(data.ensureProfileCalls, 1);
    expect(find.text('popped:true'), findsOneWidget);
  });

  testPhone('a double tap on submit only signs up once', (tester) async {
    final auth = FakeAuthService()..gate = Completer<void>();
    await openAuth(tester, auth: auth);

    await tester.enterText(find.widgetWithText(TextFormField, 'Your name or nickname'), 'Sam');
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), kFakePassword);

    final button = find.text('Create my account 🚀');
    await tester.tap(button);
    await tester.tap(button, warnIfMissed: false);
    await tester.pump();

    expect(auth.signUpCalls, 1);

    auth.gate!.complete();
    await tester.pumpAndSettle();
    expect(find.text('popped:true'), findsOneWidget);
  });

  testPhone('sign-in with a wrong password shows the friendly error and stays put',
      (tester) async {
    final auth = FakeAuthService();
    await openAuth(tester, auth: auth);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    // Name field disappears in sign-in mode.
    expect(find.widgetWithText(TextFormField, 'Your name or nickname'), findsNothing);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'wrong-password');
    await tester.tap(find.text('Let me in 🔓'));
    await tester.pumpAndSettle();

    expect(find.textContaining("isn't it, chief"), findsOneWidget);
    expect(find.text('waiting'), findsNothing); // still on the auth screen
    expect(auth.currentUser, isNull);
  });

  testPhone('sign-in with the right password signs in and pops true', (tester) async {
    final auth = FakeAuthService();
    await openAuth(tester, auth: auth);

    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), kFakePassword);
    await tester.tap(find.text('Let me in 🔓'));
    await tester.pumpAndSettle();

    expect(auth.signInCalls, 1);
    expect(find.text('popped:true'), findsOneWidget);
  });

  testPhone('forgot password asks for an email first, then sends the reset',
      (tester) async {
    final auth = FakeAuthService();
    await openAuth(tester, auth: auth);
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Type your email above first'), findsOneWidget);
    expect(auth.resetCalls, 0);

    await tester.enterText(find.widgetWithText(TextFormField, 'Email'), 'sam@example.com');
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();

    expect(auth.resetCalls, 1);
    expect(auth.lastResetEmail, 'sam@example.com');
    expect(find.textContaining('Reset link sent'), findsOneWidget);
  });

  testPhone('Continue with Google signs in and pops true', (tester) async {
    final auth = FakeAuthService();
    await openAuth(tester, auth: auth);

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(auth.googleCalls, 1);
    expect(auth.currentUser?.email, 'gina@gmail.com');
    expect(find.text('popped:true'), findsOneWidget);
  });

  testPhone('cancelling the Google sheet shows no error and stays on the screen',
      (tester) async {
    final auth = FakeAuthService()
      ..nextFailure = const AuthFailure(AuthFailureKind.cancelled, 'Cancelled');
    await openAuth(tester, auth: auth);

    await tester.ensureVisible(find.text('Continue with Google'));
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(find.text('Cancelled'), findsNothing);
    expect(find.textContaining('Hop in'), findsOneWidget);
    expect(auth.currentUser, isNull);
  });

  testPhone('skip for now remembers the guest choice and pops true', (tester) async {
    final session = AppSession();
    await openAuth(tester, session: session);

    await tester.ensureVisible(find.textContaining('Skip'));
    await tester.tap(find.textContaining('Skip'));
    await tester.pumpAndSettle();

    expect(session.guestChosen, isTrue);
    expect(find.text('popped:true'), findsOneWidget);
  });

  testPhone('guest option is hidden when guests are not allowed', (tester) async {
    await openAuth(tester, allowGuest: false);
    expect(find.textContaining('Skip'), findsNothing);
  });

  testPhone('the password field can be revealed and hidden again', (tester) async {
    await openAuth(tester);

    TextField field() => tester.widget<TextField>(
        find.descendant(of: find.widgetWithText(TextFormField, 'Password'), matching: find.byType(TextField)));

    expect(field().obscureText, isTrue);
    await tester.tap(find.byTooltip('Show password'));
    await tester.pump();
    expect(field().obscureText, isFalse);
    await tester.tap(find.byTooltip('Hide password'));
    await tester.pump();
    expect(field().obscureText, isTrue);
  });
}
