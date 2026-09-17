# friendshipmania — Command Board

*Context anchor for future sessions. Paste this in at the start of any new
session working on this app. Update this at the end of every session that
changes state.*

## What this project is

A no-login, two-friend humorous compatibility quiz Android app, branded
**friendshipmania** (renamed from the working title "The Friendship
Polygraph" used in the original design docs — `friendship-meter-spec.md` and
`friendship-meter-spec-v2.md` — which are kept for historical context but are
superseded by this document where they conflict).

**Biggest change from the original design docs: no Firebase, no backend.**
The original plan used an anonymous Firebase session + Android App Links to
sync a "joint compatibility score" between two devices. That was dropped —
each friend now independently runs the quiz on their own device and shares
their own result via Android's native share sheet, inviting the other to
install the app and generate their own reciprocal report. This removes the
app's only network dependency, its only real technical risk (App Links
domain verification, Firebase config), and its only ongoing cost — at the
cost of not having a single synced "how in sync are you two" number.

## Current state (as of 2026-09-12)

**Full build complete and verified in this session:**
- Package renamed throughout: `com.homilabs.friendship_polygraph` →
  `com.homilabs.friendshipmania`; Dart package `friendship_polygraph` →
  `friendshipmania`. Publishing identity confirmed as Homilabs Solutions.
- Toolchain **realigned to what's actually installed on this machine**:
  Flutter 3.41.9 / AGP 8.11.1 / Kotlin 2.2.20 / Gradle 8.14 (not the
  3.43/8.6.0/2.1.0 combo guessed at in the v2 spec doc, and not the
  3.47.3/9.1.0/2.4.0 combo Stage 1 was actually built with in a cloud
  sandbox — both were wrong for this environment). Verified by generating a
  throwaway `flutter create` probe project and matching its defaults.
  **If Flutter gets upgraded on this machine later, redo that probe check
  rather than assuming these versions still apply.**
- Report/share feature built: `share_plus` for the native share sheet,
  `gal` for saving the scorecard PNG to the device gallery, both captured
  via `RepaintBoundary` on the report card widget. No Firebase, no backend.
- Release signing: a dedicated keystore was generated
  (`android/keystore/friendshipmania-release.jks`, alias `friendshipmania`,
  RSA 2048, ~27-year validity), wired up via `android/key.properties`
  (gitignored). **This keystore is the single most important file in this
  project to back up — losing it means losing the ability to update the
  Play Store listing forever.** A copy sits at
  `../friendshipmania-secrets/` on this machine as a first backup; move it
  somewhere more durable.
- Security hardening: R8 minify + resource shrink on release builds,
  `allowBackup=false`, no `INTERNET` permission anywhere (verified against
  the built APK's merged manifest), storage permissions capped at
  `maxSdkVersion=29`, share-sheet text sanitized before being embedded in
  invite messages.
- Verified: `flutter analyze` (0 issues), `flutter test` (30+ tests across
  5 files — see README's "Test coverage" section), `flutter build apk
  --debug`, `flutter build apk --release`, `flutter build appbundle
  --release` all succeed, and the release build's signature was verified
  against the generated keystore's fingerprint (both match: SHA-256
  `28:15:E9:...:30:53`).
- One real bug found and fixed via deliberate double-tap stress testing:
  a fast double-tap on an answer button could double-advance the quiz or
  fire the last-question navigation twice, since Flutter's `setState`
  rebuild doesn't happen synchronously between two rapid taps. Fixed with a
  `_locked`/`_submitting` guard pattern on both the question and names
  screens.
- Play Store graphics generated programmatically (SVG → Inkscape → PNG, no
  external image-gen dependency): 512×512 app icon, 1024×500 feature
  graphic, and full adaptive/legacy launcher icon set for every Android
  density. Source SVGs in `assets/icon/`, store-ready PNGs in
  `graphics/store/`.
- Privacy policy written (`docs/privacy-policy.html`) and Play Store listing
  copy written (`docs/play-store-listing.md`), both ready to use — see their
  own "fill in" placeholders (contact email; nothing else).
- Project put under git in this session (it wasn't before) for checkpointing.

## Open follow-ups (blocked on you, not on more building)

1. **Device/emulator testing is blocked on KVM access.** This machine's
   Android SDK has the emulator + a system image installed, but the current
   user account isn't in the `kvm` group, so the emulator can't boot with
   hardware acceleration (x86_64 system images require it). You said you'd
   run `sudo gpasswd -a $USER kvm` and log out/in yourself — once that's
   done, tell the next session and it can boot the emulator, run real
   on-device UI/stress tests, and capture genuine screenshots for the store
   listing. Alternative: connect the Tab S9 FE or Xiaomi 12T Pro (both
   already have working udev rules on this machine) over `adb` instead —
   works without touching KVM at all.
2. **Play Store screenshots are the one listing asset not yet produced** —
   directly blocked on #1. Everything else in `docs/play-store-listing.md`
   is ready to paste into Play Console today.
3. **Privacy policy needs a real contact email** filled in before upload —
   currently a placeholder in `docs/privacy-policy.html`.
4. **Actual Play Console submission** (content rating questionnaire, data
   safety form, uploading the `.aab`, hitting publish) needs your Play
   Console login, which no session has had access to.

## Devices (shared across your Flutter apps on this machine)

| Device | ID | Notes |
|---|---|---|
| Samsung Tab S9 FE (SM-X510) | `R52XA0LK97M` | Has crashed on other apps with `ClassNotFoundException: MainActivity` — fix was `multiDexEnabled = true` + `androidx.multidex`, which is already applied in this project's `android/app/build.gradle.kts`. |
| Xiaomi 12T Pro | `dfd794ce` | Needs **"Install via USB" enabled in Developer Options**, or installs get blocked with `INSTALL_FAILED_USER_RESTRICTED`. |

udev rules already exist at `/etc/udev/rules.d/51-android.rules` — no new
device setup needed. Neither device was connected during this session
(`adb devices` returned empty) — connect one to continue on follow-up #1.

## Known gotchas (carried over + newly confirmed this session)

- **Gradle OOM on release builds** — `android/gradle.properties` is already
  set to `-Xmx2g`, `org.gradle.daemon=false`, `org.gradle.parallel=false`.
  This session still hit a `Java heap space` error once, from a **stray
  Gradle daemon left over from before that config was written** (started
  with `-Xmx8G`, consuming ~3GB RSS on an already memory-constrained
  machine). Fix: `cd android && ./gradlew --stop` before retrying a build if
  this happens again. Also removed `android.enableJetifier=true`, which
  isn't needed (none of this app's dependencies use the old support library)
  and was making the OOM worse.
- **This machine runs low on free RAM** when multiple Claude Code sessions
  are active concurrently (~1.6GB free was observed mid-session with 5+
  other sessions running) — worth checking `free -h` before a release build
  if one mysteriously fails.
- `withOpacity()` is deprecated on current Flutter — use
  `withValues(alpha:)`. (Not currently used anywhere in this codebase, but
  still true if it comes up.)
- File edits on this machine: this session used the Edit/Write tools
  directly rather than shell heredocs, and had no issues with Dart's `${}`
  string interpolation — the heredoc-collision gotcha from earlier sessions
  didn't reproduce here, but the caution still seems reasonable to keep.

## File delivery convention

This session worked directly on the project files at
`/mnt/storage/projects/friendshipmania` (this machine, not a cloud sandbox),
so the "deliver as a zip" convention from Stage 1 no longer applies — changes
were made in place and are already on disk here.

## Session discipline

- Step-by-step, one piece at a time — build, verify, then move on.
- State the expected outcome before running anything meaningful; check the
  actual result against it.
- Explain technical terms and commands in plain language as they come up.
- Always critique proposals and decisions rather than defaulting to agreement.
- Code changes and Command Board updates are conceptually separate — this
  doc gets updated at milestones, not mixed silently into a code delivery.

## Next steps

1. You: grant KVM access (or connect a physical device), fill in the privacy
   policy contact email, upload the privacy policy to homilabs.org.
2. Next session: once a device/emulator is available, run real UI stress
   tests and capture the remaining Play Store screenshots.
3. You: log into Play Console and go through the actual submission using
   `docs/play-store-listing.md` as the source of truth for every field.
