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

### Verified on 2026-10-10 (afternoon)
- **Full account lifecycle on the real A12 against local emulators:** sign up → profile written → quiz →
  verdict auto-saved (one doc, server timestamp, category scores only) → My verdicts lists it →
  delete with a WRONG password is refused and nothing is deleted → correct password deletes profile,
  verdicts and the account; app returns to signed-out.
- **Firestore rules:** 19 tests pass in `test_rules/`; 4 deliberate weakenings were each caught.
- Bugs found doing this: FlutterFire remapped `127.0.0.1` to 10.0.2.2 (fixed with `automaticHostMapping:false`);
  release-grade cleartext block also blocked the emulators (fixed with a debug-only network config);
  delete-dialog label truncated at large text (shortened).

### Assets integrated (Homi approved 2026-10-10)
- Mascot (job 20261010-1125-…-icon-01) on welcome + About + launcher icon (neon-lime background).
- Verdict stickers (1125-icon-02/03, 1126-icon-01, 1127-icon-01/02) on the scorecard and shared image.
- SFX: tap = 1129-sfx-01, answer = 1129-sfx-03, reveal = 1130-sfx-01 (chosen by Claude on objective grounds;
  other approved candidates remain in `~/ai-inbox/friendshipmania/` — swap = change the path in `audio_service.dart`).
- "Powered by Stability AI" on About (`lib/config.dart`) and in the store description. `release-check.sh`: PASS.
- `lib/widgets/cropped_art.dart` shows only the measured artwork rectangle of each cutout (they have wide
  transparent margins); `test/art_test.dart` enforces a crop entry per art file.
- Note: release-check requires the folder of every registered file in pubspec, so the unused `_raw.png`
  copies are bundled (~3.4 MB). Possible tooling tweak for Homi: integrate only `_cutout.png` for icon-cutout jobs.

### Release
- Final signed `app-release.aab` 1.0.0 (1) and split APKs built; release APK smoke-tested on the A12 (no crashes,
  cold start ~6 s). Store screenshots `graphics/store/screenshot_1..4.png`. Upload guide: `docs/play-console-upload.md`.

### Still NOT verified / not done
1. **Real Google sign-in** (needs the owner's Google account). After the first Play upload, add the
   Play App Signing SHA-1/256 to Firebase or Google sign-in fails for Play installs.
2. **Music blocked:** `music-loop-basic` outputs fail Stage 1 (OGG true peak about -0.4 dBFS vs -1 limit) — Homi's
   to fix on homidev. App runs without music; mute button controls the sfx.
3. Site not deployed (Hostinger login). Play submission is the owner's (guide ready).
4. **Shared phone incident (2026-10-10):** the A12 was also being used by the takhti_grow session; one batch
   of my adb taps/typing landed in TakhtiGrow (navigation only, nothing destructive). Always check the
   foreground package before sending adb input.

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
