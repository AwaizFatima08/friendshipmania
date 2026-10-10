import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'services/app_services.dart';
import 'services/audio_service.dart';
import 'services/auth_service.dart';
import 'services/user_data_service.dart';
import 'theme.dart';

/// Debug builds only: `--dart-define=USE_FIREBASE_EMULATOR=true` points the
/// app at Firebase emulators on the dev machine (reached from a phone via
/// `adb reverse`), so sign-up/sign-in/delete flows can be tested end to end
/// with throwaway accounts instead of the real project. `kDebugMode` makes
/// this impossible to switch on in a release build.
const bool _useEmulator = bool.fromEnvironment('USE_FIREBASE_EMULATOR');

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (kDebugMode && _useEmulator) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
    FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  }

  final audio = AppAudioService();
  await audio.init();

  runApp(FriendshipManiaApp(
    auth: FirebaseAuthService(),
    data: FirestoreUserDataService(),
    audio: audio,
  ));
}

class FriendshipManiaApp extends StatefulWidget {
  const FriendshipManiaApp({
    super.key,
    required this.auth,
    required this.data,
    required this.audio,
  });

  final AuthService auth;
  final UserDataService data;
  final AudioService audio;

  @override
  State<FriendshipManiaApp> createState() => _FriendshipManiaAppState();
}

class _FriendshipManiaAppState extends State<FriendshipManiaApp> {
  final AppSession _session = AppSession();

  @override
  Widget build(BuildContext context) {
    return AppServices(
      auth: widget.auth,
      data: widget.data,
      audio: widget.audio,
      session: _session,
      child: MaterialApp(
        title: 'friendshipmania',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const WelcomeScreen(),
      ),
    );
  }
}
