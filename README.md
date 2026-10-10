# friendshipmania

A funny, Gen Z friendship "lie detector" for Android. Two names, ten unhinged
questions, one brutally honest verdict you can download or share.

## What the app does

1. **Welcome** → tap *Start the Interrogation*. Signed-out users see the
   sign-in screen once per launch (they can **Skip**).
2. **Sign in / sign up** (optional): email + password, or Google.
3. **Names** → **10 random questions** from a bank of 40 (answers shuffled).
4. **Verdict** → percentage, roast-y title, per-category breakdown, rendered
   as a shareable scorecard.
5. **Download** (to the phone's gallery) or **Share** (Android share sheet,
   with a funny invite message so the friend can run their own test).
6. **Signed-in extras:** every verdict is auto-saved to *My verdicts*;
   *My account* has sign-out and **Delete account & data**.
7. **Sound:** quiet looping music + short effects, with a mute toggle
   (hidden until audio assets are bundled; see "Audio & graphics").

## Architecture

```
lib/
  main.dart                      Firebase init, wires real services
  config.dart                    site URLs, support email, attribution lines
  data/question_bank.dart        40 questions (best answer listed first; shuffled at runtime)
  services/
    auth_service.dart            AuthService interface + FirebaseAuthService (email + Google)
    user_data_service.dart       UserDataService interface + Firestore implementation
    audio_service.dart           AudioService (+ no-op); mixes with other apps, pauses in background
    app_services.dart            InheritedWidget handing services to screens
    scoring.dart / report_service.dart
  screens/                       welcome, auth, names, question, result, history, account, about
  widgets/                       gradient_page, report_card, mute_button, friendship_meter
firestore.rules                  owner-only rules with field validation
site/friendshipmania/            the friendshipmania.homilabs.org pages + upload zip
```

Screens depend only on the abstract services, so the whole app is tested
against in-memory fakes (`test/fakes.dart`) with no Firebase or network.

## Firebase

| | |
|---|---|
| Project | `friendshipmania-homilabs` (Spark/free plan) |
| Android app | `com.homilabs.friendshipmania` |
| Auth providers | Email/Password, Google |
| Firestore | `(default)`, **asia-south1 (Mumbai)**, production mode + `firestore.rules` |
| Registered SHA fingerprints | debug SHA-1/256 and release SHA-1/256 |

- `android/app/google-services.json` is **gitignored** (public repo). Re-create it with
  `firebase apps:sdkconfig ANDROID 1:257734654157:android:d560ace9ba560acbca9184 --project friendshipmania-homilabs > android/app/google-services.json`
- Data layout: `users/{uid}` (profile) and `users/{uid}/reports/{id}` (saved verdicts).
  Rules let a user touch only their own documents and validate field types/sizes.
  Deploy with `firebase deploy --only firestore:rules`.
- **After the first Play upload:** Google re-signs the app with a *Play App Signing* key.
  Copy its SHA-1 and SHA-256 (Play Console → *App integrity*) into Firebase
  (*Project settings → your Android app → Add fingerprint*), re-download
  `google-services.json`, or **Google sign-in will fail** for Play-installed builds.
- The Google consent screen shows the project support email (currently the account owner's
  address, the only choice Firebase offered). Change it under *Authentication → Sign-in method → Google*.

### Testing sign-in without touching the real project
Debug builds only: `flutter run --dart-define=USE_FIREBASE_EMULATOR=true` points the app at
Firebase emulators on `localhost` (Auth 9099, Firestore 8080; from a phone use
`adb reverse tcp:9099 tcp:9099 tcp:8080 tcp:8080`). The switch is guarded by `kDebugMode`,
so it cannot be enabled in a release build.

## Building & testing

```bash
flutter pub get
flutter analyze            # must show 0 issues
flutter test --concurrency=1
flutter build apk --debug --target-platform android-arm64
flutter build appbundle --release
```

**This machine is shared with other builds.** Before any Gradle build check `free -m`
and that no other project's Gradle build is running. `android/gradle.properties` is tuned
for low memory (`-Xmx2g`, no daemon, Kotlin in-process, 2 workers). If a build is killed
(exit 143) or `Java heap space` appears, a neighbour's idle daemon is usually holding RAM:
wait for it rather than stopping their daemon.

## Release signing

`android/key.properties` and `android/keystore/friendshipmania-release.jks` are generated
locally and **gitignored**. Back them up somewhere durable: losing the keystore means losing
the ability to update the Play listing. A first copy sits in `../friendshipmania-secrets/`.

## Security notes

- Network use is limited to Firebase (HTTPS). `INTERNET` is merged from the Firebase plugins.
- Firestore: owner-only rules with field validation (`firestore.rules`); no public reads.
- Passwords are handled by Firebase Auth only; the app never stores them. Wrong credentials
  all return one generic message (no account probing).
- Account deletion re-verifies the user **first**, then deletes data, then the account.
- Release builds are R8-minified, signed with the release key, `allowBackup=false`.
- Storage permissions are capped at `maxSdkVersion=29`.
- Share text is sanitised (control characters stripped, length capped).

## Known follow-ups
See `docs/friendship-polygraph-command-board.md` ("Open follow-ups").
