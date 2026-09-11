# Friendship Polygraph — Command Board

*Context anchor for future sessions. Paste this in at the start of any new session working on this app, same as the Command Board convention on your other projects (Servio, Muhafiz). Update this at the end of every session that changes state.*

## What this project is

A no-login, two-friend humorous compatibility quiz Android app ("The Friendship Polygraph"). Full design context lives in `friendship-meter-spec.md` — this document is the working/technical reference, that one is the product spec.

## Environment & toolchain

- **Recommended (pending your confirmation):** Flutter 3.43, Dart 3.12, AGP 8.6.0, Kotlin 2.1.0, Android SDK 36, Java 17 — matching CalcCanvas / Friend Zone / Hadi's Calculator, all built on `homi-nas` (Debian 12).
- **What Stage 1 was actually built with:** Flutter 3.47.3 / AGP 9.1.0 / Kotlin 2.4.0 / Java 17, since it was built in a temporary cloud sandbox without visibility into your established stack. Needs re-verifying against the recommended stack once you place it on `homi-nas` — see open item in the spec doc, Section 11.
- Build machine: `homi-nas` (Debian 12), headless, no Android Studio — Flutter SDK + Android command-line tools + `adb` only.
- This session (cloud-based) **cannot reach `homi-nas` over the network** — same constraint noted on the Muhafiz project. Every stage is built and verified in the cloud sandbox, then delivered as a complete zip for you to place manually and re-verify locally.

## Devices (shared across your Flutter apps on this machine)

| Device | ID | Notes |
|---|---|---|
| Samsung Tab S9 FE (SM-X510) | `R52XA0LK97M` | Has crashed on other apps with `ClassNotFoundException: MainActivity` — fix was `multiDexEnabled = true` + `androidx.multidex`. Watch for this if Friendship Polygraph ever crashes on launch here. |
| Xiaomi 12T Pro | `dfd794ce` | Needs **"Install via USB" enabled in Developer Options**, or installs get blocked with `INSTALL_FAILED_USER_RESTRICTED`. |

udev rules already exist at `/etc/udev/rules.d/51-android.rules` — no new device setup needed.

## Known gotchas to pre-empt (carried over from sibling Flutter/Firebase apps)

- **Gradle OOM on release builds** — use `-Xmx2g`, disable the Gradle daemon, disable parallel execution. Larger `-Xmx` values have failed before on this machine.
- **Firebase `CONFIGURATION_NOT_FOUND`** on first real-device run — check, in order: Anonymous sign-in enabled in the Firebase console → SHA-1 fingerprint registered → `google-services.json` is current, not stale → package name matches exactly.
- **APK output path** can land in `android/app/build/outputs/flutter-apk/` instead of Flutter's default once Firebase is wired in — use `adb install` directly rather than assuming `flutter run` will find it.
- `withOpacity()` is deprecated on current Flutter — use `withValues(alpha:)`.
- File edits on `homi-nas`: prefer Python `open(path, 'w')` for full-file writes and `sed -i` for targeted edits — shell heredocs have failed silently on this machine before, especially with Dart's `${}` string interpolation colliding with shell syntax.

## File delivery convention

- New file (doesn't exist yet): deliver the complete file.
- Edit to an existing file: deliver the specific change, not a full-file replacement — unless you ask for the complete file.
- Each stage ships as a ready-to-drop-in zip with its own short README, verified with `flutter analyze` (must show 0 issues) and `flutter test` (must pass) *before* it's sent to you.

## Session discipline

- Step-by-step, one piece at a time — build, verify, then move on. No jumping ahead or bundling multiple changes.
- State the expected outcome before running anything meaningful; check the actual result against it.
- Explain technical terms and commands in plain language as they come up — no assumed familiarity.
- Always critique proposals and decisions rather than defaulting to agreement.
- Code changes and Command Board updates are conceptually separate — this doc gets updated at milestones, not mixed silently into a code delivery.

## Current state (as of 2026-09-11)

- Stage 1 complete: names entry → 10-question quiz (bank of 40, sharper/roast tone) → solo scorecard. Delivered as `friendship_polygraph_stage1.zip`.
- Verified in the cloud sandbox only — **not yet placed on `homi-nas` or run on either physical device.**
- Toolchain re-alignment (3.43 vs 3.47.3) is an open decision — see spec doc Section 11.
- Publishing identity (Homilabs Solutions vs. personal) is an open decision — see spec doc Section 9.

## Next steps

1. You place Stage 1 on `homi-nas`, confirm the toolchain call, run `flutter pub get && flutter analyze && flutter test` locally.
2. Install on the Xiaomi and/or Samsung tablet via `adb`, click through it for real.
3. Report back what you see (or any error) — then Stage 2 (scorecard image export) gets built against the confirmed toolchain.
