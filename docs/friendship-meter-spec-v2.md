# The Friendship Polygraph — Design Document v2

*Updated 2026-09-11. Supersedes the v1 draft from 2026-09-10. Locked decisions are marked; open items need your call before the next build stage.*

## 1. The idea, in one paragraph

Two friends, no accounts. Friend A opens the app, types both names, and answers 10 sharper/roast-style questions about the friendship, randomly pulled from a bank of 40. The app spits out a funny scorecard (a percentage + a roast-y title, like "🔥 Actual Real Friends"). Friend A shares that scorecard as a link with Friend B. Friend B opens it, answers the same style of questions about the same friendship, and the app then reveals a **joint** scorecard showing how "in sync" the two of them really are.

## 2. Locked decisions

| Decision | Choice |
|---|---|
| App name | **The Friendship Polygraph** |
| Humor tone | Sharper / roast-style (not gentle) |
| Questions per run | **10**, sampled from a bank of 40 across 5 tags (roast, loyalty, chaos, receipts, nostalgia) |
| Scoring model | Compatibility-style: how in-sync the two friends' answers are, not a simple average of two self-ratings |
| No-login sharing mechanism | Firebase-backed anonymous session (invisible to the user) + Android App Links on `homilabs.org` — not Firebase Dynamic Links, which was permanently shut down in August 2025 |
| Graphics style | Emoji + simple shapes/color — no custom illustration pass needed |
| Build scope | Full app scoped upfront (like the Ludo app), built in verified stages |
| Local dev path | Building directly on your Debian 12 dev machine, command-line only — no Android Studio |

## 3. Step-by-step user flow

1. Friend A opens the app → enters both names (no login).
2. Answers 10 randomly-sampled questions.
3. Sees a solo result immediately — a payoff even if Friend B never responds.
4. Shares a link (WhatsApp, SMS, etc.). If Friend B has the app, it opens straight to "your turn." If not, a small fallback web page on homilabs.org offers the Play Store install.
5. Friend B answers the same style of questions about the same friendship.
6. Both see a joint, compatibility-style scorecard, downloadable as an image.

## 4. Build status

**Stage 1 — done and verified (2026-09-10).** Names entry, 10-question quiz, solo scorecard. Built as a real Flutter/Android project, not a mockup. Verified with `flutter analyze` (clean) and 4 automated tests (including one that caught and fixed a real crash-on-last-question bug). Delivered as a zip for you to place on your own dev machine.

**Stages 2–4 — not started**, in this order: scorecard image export → Firebase session sync between two devices → sharing + Android App Links (the fiddliest part, saved for last) → joint/compatibility scorecard.

## 5. Environment — important discrepancy to resolve

Stage 1 was built in a temporary cloud sandbox, not on your dev machine, since that's all this session had access to at the time. I used **Flutter 3.47.3** (the current stable release as of this week), which pulled in **AGP 9.1.0 / Kotlin 2.4.0 / Java 17**.

Your other Flutter apps on `homi-nas` (CalcCanvas, Friend Zone, Hadi's Calculator) all run on a different, already-proven stack: **Flutter 3.43 / AGP 8.6.0 / Kotlin 2.1.0 / Java 17**. Both stacks satisfy Google Play's current requirement (Android 16 / API 36), so there's no functional reason to be on the newer one.

**My recommendation: re-align this project to your established 3.43/8.6.0/2.1.0 stack**, not the other way around. You already know that combination works on your machine, you've already hit and solved its rough edges (the Gradle memory settings below, for instance), and running five apps on five different toolchains is more for you to keep straight than running five apps on one. I'd rather match your proven setup than introduce a second one for no real benefit. Flag it back to me if you'd rather stay on the newer version for a specific reason — but absent one, I'd downgrade before this goes further.

## 6. Devices — already solved

You already have two working test devices on `homi-nas`, with udev rules already configured for `adb`:
- Samsung Tab S9 FE (`SM-X510`, ID `R52XA0LK97M`)
- Xiaomi 12T Pro (ID `dfd794ce`) — note this device has needed **"Install via USB" enabled in Developer Options** before on other apps; worth checking that's still on.

No emulator needed, and no need to buy or borrow a phone — this resolves the open question from our last session.

## 7. Known gotchas from your other Flutter/Firebase apps, worth watching for here

These bit you on sibling projects and are likely to recur since this app uses the same tools:
- **Gradle OOM during release builds** — fix that worked before: `-Xmx2g`, Gradle daemon disabled, parallel execution disabled.
- **Firebase `CONFIGURATION_NOT_FOUND`** on first real-device test — usually means Anonymous sign-in isn't enabled yet in the Firebase console for this project; secondary causes are a missing SHA-1 fingerprint, a stale `google-services.json`, or a package name mismatch.
- **APK lands in `android/app/build/outputs/flutter-apk/`** instead of Flutter's usual default path once Firebase is wired in — install directly with `adb install` rather than expecting `flutter run` to always find it automatically.
- `withOpacity()` is deprecated on current Flutter — use `withValues(alpha:)` if this comes up.

## 8. How this gets delivered going forward

Consistent with how Muhafiz and your other NAS projects work: this session cannot reach `homi-nas` over the network directly. So each stage will keep following the pattern we already used for stage 1 — built and verified here, delivered as a complete, ready-to-drop-in zip, with you placing it into your own project folder and running `flutter analyze` / `flutter test` there to confirm before moving on.

## 9. Publishing — open question

Your other Homilabs apps (Ludo, Sports Olympiad) use your existing paid Play Console account. Separately, your personal/family apps (CalcCanvas, Friend Zone) are published under a different identity — GitHub account `AwaizFatima08`, credited to Awaiz. **Which does The Friendship Polygraph belong under** — the Homilabs Solutions company account, or a personal one? This affects the package name, signing identity, and where the privacy policy gets hosted, so worth locking in before Stage 4 (publishing) rather than after.

## 10. Cost

Firebase's free Spark tier should comfortably cover normal usage. If it ever goes properly viral, it's a pay-as-you-go upgrade at that point, not a cost you'd carry upfront.

## 11. Open decisions needed from you

1. Re-align to Flutter 3.43/AGP 8.6.0/Kotlin 2.1.0 (recommended), or stay on 3.47.3?
2. Which publishing identity — Homilabs Solutions or personal/`AwaizFatima08`-style?
3. Confirm you still want to proceed stage-by-stage in the order in Section 4.

Once these are settled, next up is Stage 2 (scorecard image export), rebuilt against whichever toolchain you confirm.
