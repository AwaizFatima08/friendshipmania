# friendshipmania — Command Board

*Context anchor for future sessions. Paste this in at the start of any new session.
Update it at the end of every session that changes state.*

## What this is
Android app "friendshipmania" (package `com.homilabs.friendshipmania`, Homilabs identity): a Gen Z
friendship lie-detector quiz. Original docs (`friendship-meter-spec*.md`) are historical.

## Decision history (important — it changed)
1. Sep 2026: "no login, no Firebase" — the app was fully local (no INTERNET permission).
2. **Oct 2026: reversed by the owner.** Added sign in / sign up (email+password and Google),
   Firestore for per-user verdict history, a funnier tone, music/sfx, a docs site, and Play publishing.
   Consequence: the old "no data collected" privacy policy, README claims and listing copy were wrong and
   have been **replaced** (privacy lives in `site/friendshipmania/privacy.html`).
   Sign-in is **optional** (Skip → guest mode; nothing stored server-side for guests).

## State as of 2026-10-10

### Done and verified
- **Funnier tone:** all 40 questions rewritten (absurd Gen Z scenarios), answers now **shuffled** per question,
  funnier bands/labels/share text/microcopy, rotating quips on the quiz.
- **Auth:** `lib/services/auth_service.dart` (interface + Firebase impl, friendly error mapping that doesn't
  reveal whether an account exists), sign-in/up screen (Google first, Skip in the app bar), account screen with
  sign-out and **delete account** (re-verify identity → delete data → delete account).
- **Firestore:** `lib/services/user_data_service.dart`; `users/{uid}` + `users/{uid}/reports/{id}`; owner-only
  rules with field validation in `firestore.rules` (**deployed**). Verdicts auto-save for signed-in users.
- **Firebase project `friendshipmania-homilabs`** (Spark): Android app registered with debug+release SHA-1/256,
  Email/Password + Google enabled, Firestore `(default)` in **asia-south1**. `google-services.json` is
  gitignored (public repo) — regenerate per README.
- **Audio service** (`audio_service.dart`): mixes with other apps, pauses in background, mute remembered.
  Mute button is hidden until audio assets are bundled. **No audio assets exist yet.**
- **Site** `site/friendshipmania/` + `friendshipmania-site.zip`: index, privacy, terms, delete-account.
  **Not deployed yet** (needs Hostinger login — see `site/README.md`).
- **Tests:** 74 passing (`flutter test --concurrency=1`), `flutter analyze` clean. Fakes in `test/fakes.dart`;
  `testPhone()` runs on a phone-width tall viewport. `emoji_safety_test.dart` blocks emoji newer than Android 7.
- **On-device (Samsung A12, Android 12, 339x753 dp, font scale 1.3):** welcome → skip → names → 10 questions →
  verdict verified. Real-device testing found and fixed: welcome overflow + title wrap, names screen not
  scrollable, gradient stopping short (Stack shrink-wrapped by a SingleChildScrollView — gradient now sits
  *outside* the Scaffold in `GradientPage`), quiz answers squeezed, verdict buttons breaking words, breakdown
  labels breaking words, and **tofu emoji** (🫶 🫡 🧊 🧾 🤨 replaced).
- Share image now has a branded gradient frame + footer.

### NOT verified / not done (be honest about these)
1. **Real sign-up, sign-in, Google sign-in and account deletion have not been run on a device.** Creating accounts
   in the real project is not something an assistant should do; the plan was local emulators.
   The debug-only hook exists: `--dart-define=USE_FIREBASE_EMULATOR=true` (+ `adb reverse tcp:9099 tcp:8080`).
   **Blocked:** firebase-tools needs **Java 21**; this machine has 17. Needs a ~190 MB JDK download (asked, awaiting OK).
2. **Firestore rules have not been unit-tested** (same JDK blocker; they compile and are deployed).
3. **No release build since the Firebase/auth change.** Run one (with the memory checks below) and verify R8 didn't
   break Firebase/Google sign-in before uploading.
4. **Graphics and audio** (homidev) not requested yet — waiting for approval of the asset list (see below).
5. **Play Console:** nothing submitted. After first upload add the Play App Signing SHA-1/256 to Firebase.
6. Local work is **not committed/pushed** since the Gen Z + auth work (public repo AwaizFatima08/friendshipmania).

### Proposed homidev assets (awaiting owner's OK — workflow in ~/.claude/homidev.md)
Images (`icon-cutout-basic`, no people, so no audience issue): 1 detective-bean **mascot** x3 seeds (welcome hero +
icon), 5 verdict-band **stickers** (ice cube, skeptic, popcorn, flame heart, crown). Audio: 1 looping **music**
(`music-loop-basic`, bpm ~100) x3 seeds; sfx `tap`, `answer`, `reveal` x3 seeds each. Needs "Powered by Stability AI"
on About + store description. Files are expected at `assets/audio/music/loop.ogg` and
`assets/audio/sfx/{tap,answer,reveal}.ogg`; declare them in pubspec when they exist.
**homidev reported GPU 100% / 11 GB in use with no job running — jobs will fail "GPU busy" until that clears.**

## Machine rules (this PC is shared with other Claude sessions/projects)
- Before any Gradle build: `free -m` and check no other project's Gradle build is running.
  On 2026-10-10 another project's idle Gradle daemon held ~4.8 GB and a second build started mid-run.
- My build settings are lean: `-Xmx2g`, no daemon, Kotlin in-process, 2 workers (`android/gradle.properties`).
- Run builds under a watchdog that kills **only this project's** build if available RAM < 700 MB (it did, once,
  and the neighbour was unharmed). Never stop another project's daemon.
- Prefer a single `flutter run -d <phone>` session + hot reload (`kill -USR1 <pid>` from `--pid-file`) over repeated
  full builds. A debug first launch on the A12 takes ~16 s.
- Don't `pkill -f <name>` where `<name>` appears in your own command line (it kills your shell).
- A12 phone adb id: `R58R61F3FDK`. Older Homilabs test devices: Tab S9 FE `R52XA0LK97M`, Xiaomi 12T Pro `dfd794ce`.

## Play / Firebase gotchas
- Google sign-in `DEVELOPER_ERROR` → missing SHA. After Play upload add *App signing* SHA-1/256 and re-download
  `google-services.json`.
- The Google consent screen shows the project support email (currently the owner's own address — Firebase offered
  no other choice). Change in Auth → Sign-in method → Google.
- Data Safety form + account-deletion URL: see `docs/play-store-listing.md`.
- New personal Play accounts may need a 12-tester / 14-day closed test before production (check account type).

## Signing
`android/key.properties` + `android/keystore/friendshipmania-release.jks` (gitignored). Back up off-machine;
first copy in `../friendshipmania-secrets/`.
