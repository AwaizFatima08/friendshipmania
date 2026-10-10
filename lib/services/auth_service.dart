import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// The bits of a signed-in account the UI cares about — kept separate from
/// Firebase's `User` so screens and tests never import Firebase directly.
class AppUser {
  final String uid;
  final String? displayName;
  final String? email;

  /// True when this account signs in with an email + password (as opposed to
  /// Google only). Deleting such an account needs the password re-entered.
  final bool usesPassword;

  const AppUser({
    required this.uid,
    this.displayName,
    this.email,
    this.usesPassword = false,
  });

  /// A friendly name for headers: display name, else the email's local part.
  String get shortName {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final mail = email;
    if (mail != null && mail.contains('@')) return mail.split('@').first;
    return 'Friend';
  }
}

enum AuthFailureKind {
  /// Something the user can fix (wrong password, weak password, bad email).
  input,

  /// The user backed out of the Google sheet — not an error worth showing.
  cancelled,

  /// Sensitive action needs a fresh sign-in first (account deletion).
  needsRecentLogin,

  /// Anything else (no internet, provider not switched on, unknown).
  other,
}

/// A failure with a message already written in the app's voice, safe to put
/// straight into a banner or snackbar.
class AuthFailure implements Exception {
  final AuthFailureKind kind;
  final String message;

  const AuthFailure(this.kind, this.message);

  @override
  String toString() => 'AuthFailure($kind): $message';
}

abstract class AuthService {
  /// The current account, or null when signed out.
  AppUser? get currentUser;

  /// Emits the current account immediately, then on every sign-in/out.
  Stream<AppUser?> authChanges();

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> signOut();

  /// Proves the signed-in user is really them, right now. Password accounts
  /// pass [password]; Google accounts are re-verified through the Google
  /// sheet. Call this *before* deleting any data, so a mistyped password
  /// can never leave someone with an account but no data.
  Future<void> reauthenticate({String? password});

  /// Deletes the signed-in account itself (call [reauthenticate] first).
  Future<void> deleteAccount();
}

/// Turns Firebase's error codes into messages that sound like the app.
AuthFailure friendlyAuthFailure(FirebaseAuthException e) {
  switch (e.code) {
    case 'invalid-email':
      return const AuthFailure(
          AuthFailureKind.input, "That email looks fake. Like, aggressively fake.");
    case 'user-not-found':
    case 'wrong-password':
    case 'invalid-credential':
    case 'invalid-login-credentials':
      return const AuthFailure(AuthFailureKind.input,
          "Email or password isn't it, chief. Try again (or hit 'Forgot password').");
    case 'email-already-in-use':
      return const AuthFailure(AuthFailureKind.input,
          'That email already has an account. Try signing in instead? 👀');
    case 'weak-password':
      return const AuthFailure(AuthFailureKind.input,
          'Password too weak — even your Wi-Fi password is tougher. 8+ characters please.');
    case 'user-disabled':
      return const AuthFailure(
          AuthFailureKind.other, 'This account has been put in timeout. Contact support.');
    case 'too-many-requests':
      return const AuthFailure(AuthFailureKind.other,
          'Whoa, slow down speedy. Too many tries — give it a few minutes. ⏳');
    case 'network-request-failed':
      return const AuthFailure(AuthFailureKind.other,
          'No internet. The polygraph needs Wi-Fi to feel things. 📶');
    case 'requires-recent-login':
      return const AuthFailure(AuthFailureKind.needsRecentLogin,
          'For safety, please confirm it is really you first.');
    case 'operation-not-allowed':
      return const AuthFailure(AuthFailureKind.other,
          'This sign-in method is not switched on yet. (That one is on us.)');
    default:
      return const AuthFailure(AuthFailureKind.other,
          'Something broke and it was not you. Try again in a moment.');
  }
}

class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? google})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  Future<void>? _googleInit;

  Future<void> _ensureGoogleInitialised() => _googleInit ??= _google.initialize();

  static AppUser? _toAppUser(User? user) {
    if (user == null) return null;
    return AppUser(
      uid: user.uid,
      displayName: user.displayName,
      email: user.email,
      usesPassword: user.providerData.any((p) => p.providerId == 'password'),
    );
  }

  @override
  AppUser? get currentUser => _toAppUser(_auth.currentUser);

  @override
  Stream<AppUser?> authChanges() => _auth.userChanges().map(_toAppUser);

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseAuthException catch (e) {
      throw friendlyAuthFailure(e);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled ||
          e.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthFailure(AuthFailureKind.cancelled, 'Cancelled');
      }
      throw const AuthFailure(AuthFailureKind.other,
          "Google sign-in didn't work out. Try again, or use email instead.");
    }
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) =>
      _guard(() async {
        final cred = await _auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        await cred.user?.updateDisplayName(name.trim());
        await cred.user?.reload();
      });

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) =>
      _guard(() async {
        await _auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
      });

  Future<AuthCredential> _googleCredential() async {
    await _ensureGoogleInitialised();
    final account = await _google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AuthFailure(AuthFailureKind.other,
          "Google didn't hand over an ID. Try again, or use email instead.");
    }
    return GoogleAuthProvider.credential(idToken: idToken);
  }

  @override
  Future<void> signInWithGoogle() => _guard(() async {
        final credential = await _googleCredential();
        await _auth.signInWithCredential(credential);
      });

  @override
  Future<void> sendPasswordReset(String email) =>
      _guard(() => _auth.sendPasswordResetEmail(email: email.trim()));

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    try {
      await _ensureGoogleInitialised();
      await _google.signOut();
    } catch (_) {
      // Not signed in with Google, or Google isn't reachable — Firebase
      // sign-out above is what actually matters.
    }
  }

  @override
  Future<void> reauthenticate({String? password}) => _guard(() async {
        final user = _auth.currentUser;
        if (user == null) return;
        final usesPassword =
            user.providerData.any((p) => p.providerId == 'password');
        final AuthCredential credential;
        if (usesPassword) {
          if (password == null || password.isEmpty) {
            throw const AuthFailure(
                AuthFailureKind.input, 'Enter your password to confirm.');
          }
          credential = EmailAuthProvider.credential(
            email: user.email ?? '',
            password: password,
          );
        } else {
          credential = await _googleCredential();
        }
        await user.reauthenticateWithCredential(credential);
      });

  @override
  Future<void> deleteAccount() => _guard(() async {
        await _auth.currentUser?.delete();
      });
}
