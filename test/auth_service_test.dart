import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:friendshipmania/services/auth_service.dart';

AuthFailure map(String code) =>
    friendlyAuthFailure(FirebaseAuthException(code: code));

void main() {
  group('friendlyAuthFailure', () {
    test('wrong credentials all give the same vague message (no account probing)', () {
      final a = map('user-not-found');
      final b = map('wrong-password');
      final c = map('invalid-credential');
      expect(a.kind, AuthFailureKind.input);
      expect(a.message, b.message);
      expect(b.message, c.message);
    });

    test('email-already-in-use points the user at signing in', () {
      final f = map('email-already-in-use');
      expect(f.kind, AuthFailureKind.input);
      expect(f.message.toLowerCase(), contains('sign'));
    });

    test('weak-password mentions the 8 character rule', () {
      expect(map('weak-password').message, contains('8'));
    });

    test('network failures are explained in plain language', () {
      final f = map('network-request-failed');
      expect(f.kind, AuthFailureKind.other);
      expect(f.message.toLowerCase(), contains('internet'));
    });

    test('requires-recent-login gets its own kind', () {
      expect(map('requires-recent-login').kind, AuthFailureKind.needsRecentLogin);
    });

    test('unknown codes get a safe generic message, never the raw code', () {
      final f = map('some-brand-new-firebase-code');
      expect(f.kind, AuthFailureKind.other);
      expect(f.message, isNot(contains('some-brand-new-firebase-code')));
    });

    test('no message ever leaks a raw error code', () {
      for (final code in [
        'invalid-email', 'user-not-found', 'wrong-password', 'invalid-credential',
        'email-already-in-use', 'weak-password', 'user-disabled',
        'too-many-requests', 'network-request-failed', 'requires-recent-login',
        'operation-not-allowed', 'something-else',
      ]) {
        expect(map(code).message, isNot(contains(code)), reason: code);
      }
    });
  });

  group('AppUser.shortName', () {
    test('prefers the display name', () {
      expect(const AppUser(uid: '1', displayName: ' Sam ', email: 'x@y.com').shortName, 'Sam');
    });

    test('falls back to the email local part', () {
      expect(const AppUser(uid: '1', email: 'sam.smith@example.com').shortName, 'sam.smith');
    });

    test('falls back to Friend when there is nothing else', () {
      expect(const AppUser(uid: '1').shortName, 'Friend');
      expect(const AppUser(uid: '1', displayName: '   ').shortName, 'Friend');
    });
  });
}
