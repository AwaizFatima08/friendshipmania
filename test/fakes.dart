// In-memory stand-ins for Firebase Auth / Firestore / audio, so the widget
// tests exercise the real screens end to end without any network or
// platform channels.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:friendshipmania/main.dart';
import 'package:friendshipmania/services/app_services.dart';
import 'package:friendshipmania/services/audio_service.dart';
import 'package:friendshipmania/services/auth_service.dart';
import 'package:friendshipmania/services/user_data_service.dart';
import 'package:friendshipmania/theme.dart';

const String kFakePassword = 'correct-horse-9';

class FakeAuthService implements AuthService {
  FakeAuthService({AppUser? user}) : _user = user;

  AppUser? _user;
  final StreamController<AppUser?> _changes = StreamController<AppUser?>.broadcast();

  /// Thrown (once) by the next auth call, to simulate a Firebase error.
  AuthFailure? nextFailure;

  /// When set, sign-up/in waits on this before finishing (to test busy state).
  Completer<void>? gate;

  int signUpCalls = 0;
  int signInCalls = 0;
  int googleCalls = 0;
  int resetCalls = 0;
  String? lastResetEmail;
  bool deleted = false;
  int reauthCalls = 0;

  void _maybeFail() {
    final f = nextFailure;
    if (f != null) {
      nextFailure = null;
      throw f;
    }
  }

  void _set(AppUser? u) {
    _user = u;
    _changes.add(u);
  }

  @override
  AppUser? get currentUser => _user;

  @override
  Stream<AppUser?> authChanges() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    signUpCalls++;
    if (gate != null) await gate!.future;
    _maybeFail();
    _set(AppUser(uid: 'uid-$email', displayName: name, email: email, usesPassword: true));
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (gate != null) await gate!.future;
    _maybeFail();
    if (password != kFakePassword) {
      throw const AuthFailure(AuthFailureKind.input, 'Email or password isn\'t it, chief.');
    }
    _set(AppUser(uid: 'uid-$email', displayName: 'Existing User', email: email, usesPassword: true));
  }

  @override
  Future<void> signInWithGoogle() async {
    googleCalls++;
    _maybeFail();
    _set(const AppUser(uid: 'uid-google', displayName: 'Gina Google', email: 'gina@gmail.com'));
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    resetCalls++;
    lastResetEmail = email;
    _maybeFail();
  }

  @override
  Future<void> signOut() async => _set(null);

  @override
  Future<void> reauthenticate({String? password}) async {
    reauthCalls++;
    _maybeFail();
    final u = _user;
    if (u != null && u.usesPassword && password != kFakePassword) {
      throw const AuthFailure(AuthFailureKind.input, 'Email or password isn\'t it, chief.');
    }
  }

  @override
  Future<void> deleteAccount() async {
    deleted = true;
    _set(null);
  }
}

class FakeUserDataService implements UserDataService {
  final Map<String, List<SavedReport>> _reports = {};
  final Map<String, StreamController<List<SavedReport>>> _streams = {};

  int saveCalls = 0;
  int ensureProfileCalls = 0;
  final List<String> deletedAllFor = [];
  Object? saveError;

  /// Every `saveReport` call's percent, in order.
  final List<int> savedPercents = [];

  List<SavedReport> reportsFor(String uid) => List.unmodifiable(_reports[uid] ?? const []);

  void seed(String uid, List<SavedReport> reports) {
    _reports[uid] = [...reports];
    _streams[uid]?.add(reportsFor(uid));
  }

  @override
  Future<void> ensureProfile(AppUser user) async => ensureProfileCalls++;

  @override
  Future<void> saveReport({
    required String uid,
    required String yourName,
    required String friendName,
    required int percent,
    required String bandTitle,
    required String bandEmoji,
    required Map<String, int> tagPercents,
  }) async {
    saveCalls++;
    savedPercents.add(percent);
    if (saveError != null) throw saveError!;
    seed(uid, [
      SavedReport(
        id: 'r$saveCalls',
        yourName: yourName,
        friendName: friendName,
        percent: percent,
        bandTitle: bandTitle,
        bandEmoji: bandEmoji,
        createdAt: DateTime(2026, 10, 10),
      ),
      ...reportsFor(uid),
    ]);
  }

  @override
  Stream<List<SavedReport>> watchReports(String uid) async* {
    yield reportsFor(uid);
    final c = _streams.putIfAbsent(uid, () => StreamController<List<SavedReport>>.broadcast());
    yield* c.stream;
  }

  @override
  Future<void> deleteReport(String uid, String reportId) async {
    seed(uid, reportsFor(uid).where((r) => r.id != reportId).toList());
  }

  @override
  Future<void> deleteAllUserData(String uid) async {
    deletedAllFor.add(uid);
    seed(uid, const []);
  }
}

const AppUser kTestUser = AppUser(
  uid: 'uid-test',
  displayName: 'Tess Tester',
  email: 'tess@example.com',
  usesPassword: true,
);

/// The whole real app, wired to fakes.
Widget fakeApp({Key? key, FakeAuthService? auth, FakeUserDataService? data, AudioService? audio}) {
  return FriendshipManiaApp(
    key: key,
    auth: auth ?? FakeAuthService(),
    data: data ?? FakeUserDataService(),
    audio: audio ?? NoopAudioService(),
  );
}

/// A single screen inside the app's theme + services, for focused tests.
Widget fakeScreen(
  Widget screen, {
  FakeAuthService? auth,
  FakeUserDataService? data,
  AudioService? audio,
  AppSession? session,
}) {
  return AppServices(
    auth: auth ?? FakeAuthService(),
    data: data ?? FakeUserDataService(),
    audio: audio ?? NoopAudioService(),
    session: session ?? AppSession(),
    child: MaterialApp(theme: buildAppTheme(), home: screen),
  );
}

/// An audio fake that records what it was asked to play.
class RecordingAudio extends NoopAudioService {
  final List<Sfx> played = [];
  int musicStarts = 0;

  @override
  bool get hasAudio => true;

  @override
  Future<void> startMusic() async => musicStarts++;

  @override
  Future<void> playSfx(Sfx sfx) async => played.add(sfx);
}

/// Like `testWidgets`, but on a phone-width (390 dp), very tall screen instead
/// of the default 800 x 600. The flutter test font is much wider than real
/// text, which makes pages far taller than on a phone, and lazy lists do not
/// build off-screen items, so a tall viewport keeps every button findable
/// while still exercising the narrow, phone-width layouts.
void testPhone(String description, Future<void> Function(WidgetTester tester) body) {
  testWidgets(description, (tester) async {
    tester.view.physicalSize = const Size(1170, 6000); // 390 x 2000 dp
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await body(tester);
  });
}
