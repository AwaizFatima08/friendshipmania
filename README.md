# friendshipmania

A funny, no-login friendship-compatibility quiz for two friends. Full design
background is in `docs/friendship-meter-spec-v2.md`; this file documents what
is actually built and how to build/test/release it.

## What the app does

1. **Welcome screen** → **Enter both names** (no login, no email, nothing
   remembered between sessions).
2. **Quiz** → 10 random, illogical-but-hilarious questions about the
   friendship, sampled from a bank of 40 across 5 tags (roast, loyalty,
   chaos, receipts, nostalgia), so runs vary.
3. **Report** → a percentage score, a roast-y verdict title, and a
   per-category breakdown, all rendered as a shareable scorecard.
4. **Download** → saves the scorecard PNG into the device's own Gallery
   (a "friendshipmania" album).
5. **Share** → opens Android's native share sheet with the scorecard image
   and an invite message, so the friend can install the app and generate
   their own reciprocal report about the same friendship.

There is **no backend of any kind** — no Firebase, no login, no server. Each
person's report is generated entirely on their own device. "Reciprocal"
means each friend independently runs the quiz and shares their own result,
not a synced/joint score requiring both devices to be online together. This
was a deliberate simplification from the original design doc's Firebase-based
plan (see `docs/friendship-meter-spec-v2.md` §9 for that superseded
approach) — it removes the app's only real complexity and its only
dependency on an internet connection, at the cost of not having a single
combined "compatibility %" between both friends.

## Project structure

```
lib/
  data/question_bank.dart       — the 40-question bank
  models/question.dart          — Question / AnswerOption data classes
  services/scoring.dart         — sampling, percent scoring, tag breakdown
  services/report_service.dart  — image capture, gallery save, share sheet
  screens/                      — welcome → names → question → result
  widgets/
    friendship_meter.dart       — animated percent/emoji meter
    report_card.dart            — the actual shareable/downloadable card
assets/icon/                    — source SVGs for the launcher icon + feature graphic
graphics/store/                 — generated Play Store graphics (icon, feature graphic)
docs/
  privacy-policy.html           — ready to upload to homilabs.org
  play-store-listing.md         — listing copy, ready to paste into Play Console
  friendship-polygraph-command-board.md — session-to-session working notes
android/
  key.properties, keystore/     — release signing (gitignored, back these up yourself!)
```

## Toolchain

Built and verified against what's actually installed on this machine:
Flutter 3.41.9 / Dart 3.11.5 / AGP 8.11.1 / Kotlin 2.2.20 / Gradle 8.14 /
Java 17 / Android SDK 36 (compile & target), minSdk 24.

If a future session upgrades the local Flutter SDK, re-check these versions
against `flutter create`'s own defaults (see the note in the command board
doc) rather than assuming they still match — that mismatch is exactly what
caused the Stage 1 hand-off from a cloud sandbox to need realignment here.

## Building & testing

```bash
flutter pub get
flutter analyze          # must show 0 issues
flutter test              # unit + widget tests, see test/ below
flutter build apk --debug              # quick sideload build
flutter build appbundle --release      # Play Store upload format (.aab)
```

If a release Gradle build ever fails with `Java heap space` on this machine:
run `cd android && ./gradlew --stop` first to kill any stray Gradle daemon
left over from a previous session, then retry. `android/gradle.properties`
is already tuned to `-Xmx2g`, no daemon, no parallel execution — the same
fix noted in the command board doc for sibling Homilabs apps — but a leaked
daemon from *before* that config existed can still be sitting in memory.

### Test coverage

- `test/widget_test.dart` — core user flow (welcome → names → quiz →
  scorecard), input validation, and a fast-double-tap stress test on the
  question flow (see "Bugs found & fixed" below).
- `test/scoring_test.dart` — 500-iteration fuzz test on the scoring math and
  tag breakdown, plus edge cases (empty run, out-of-range percent input).
- `test/question_bank_test.dart` — data-integrity checks on all 40 questions
  (unique ids, non-empty prompts/options, correct `maxScore`).
- `test/report_service_test.dart` — share-text sanitization (whitespace,
  newlines, length cap) and the Play Store URL constant.
- `test/report_card_test.dart` — layout/overflow checks on the report card at
  0%, 100%, max-length names, and a full 5-tag breakdown.

### Bugs found & fixed during this build

- **Double-tap race in the question flow**: tapping an answer button twice
  in fast succession (before Flutter's rebuild lands) could double-advance
  the quiz or fire the last-question navigation twice. Fixed with a `_locked`
  guard in `question_screen.dart`; covered by a dedicated test.
- **Duplicate quiz screens from a fast double-tap on "Start the quiz"**:
  same class of bug on the names screen; fixed with a `_submitting` guard
  that re-enables once the user returns to that screen.

## Release signing

`android/key.properties` and `android/keystore/friendshipmania-release.jks`
were generated on this machine (RSA 2048, alias `friendshipmania`, valid
~27 years). **Both files are gitignored on purpose — back them up yourself,
somewhere durable, right now.** If you lose this keystore, you permanently
lose the ability to publish updates to this same Play Store listing; Google
cannot recover or reset it for you. A copy was also placed outside this
project's git tree at `../friendshipmania-secrets/` on this machine as a
first backup — move that somewhere more durable (a password manager, an
encrypted drive) rather than leaving it as the only copy.

## Security posture

- **No `INTERNET` permission at all** — verified against the built APK's
  merged manifest. The app cannot make a network request even if compromised.
- Only permissions requested: `WRITE_EXTERNAL_STORAGE` /
  `READ_EXTERNAL_STORAGE`, both capped at `maxSdkVersion="29"` (needed only
  for the gallery-save feature on old Android versions; not requested at all
  on Android 11+).
- `android:allowBackup="false"` — no app data is swept into Android's
  auto-backup.
- Release builds are minified and resource-shrunk (R8), signed with a
  dedicated release keystore (not debug-signed).
- Share-sheet text (names, verdict title) is sanitized before being embedded
  in the invite message — newlines/control characters stripped, length capped.
- No third-party SDKs, analytics, ads, or crash reporting of any kind.

## Known follow-ups (not yet done)

1. **Real on-device screenshots for the Play Store listing** — blocked on
   either KVM access for the local emulator or a physical device connected
   over `adb`. See `docs/play-store-listing.md`.
2. **Fill in the contact email placeholder** in
   `docs/privacy-policy.html` before uploading it to homilabs.org.
3. **Update the Play Store URL placeholder** in
   `lib/services/report_service.dart` (`playStoreUrl`) once the app is
   actually live, if the package name or listing URL ever changes.
4. Play Console submission itself (content rating questionnaire, data safety
   form, actual upload) — this needs your Play Console login, which this
   session doesn't have.
