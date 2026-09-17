# Play Store listing — copy & submission notes

Everything below is ready to paste into Play Console. Nothing here requires
guesswork except the two `<fill in>` spots.

## App details

| Field | Value |
|---|---|
| App name | `friendshipmania` |
| Package name | `com.homilabs.friendshipmania` |
| Category | Entertainment (or Lifestyle — either fits; Entertainment is the closer match) |
| Content rating | Expect **Teen** — the humor is sharper/roast-style, not aimed at young children. Run Play Console's rating questionnaire; answer honestly about "mild profanity/insults" in the humor. |
| Contains ads | No |
| In-app purchases | No |
| Target audience | Not designed for children |

## Short description (max 80 characters)

```
The hilarious no-login friendship quiz. Answer, laugh, send it, get roasted.
```
(76 characters)

## Full description (max 4000 characters)

```
friendshipmania puts your friendship on trial — in the funniest way possible.

No login. No email. No account to remember. Just type in your name and your
friend's name, and you're in.

HOW IT WORKS
1. Enter your name and your friend's name.
2. Answer 10 random, ridiculous, brutally honest questions about your
   everyday friendship — pulled from a bank of 40, so it's different every
   time.
3. Get your instant, funny verdict: a percentage score, a roast-y title (like
   "🔥 Actual Real Friends" or "🧊 Certified Frenemies"), and a breakdown of
   exactly where your friendship scores highest.
4. Download the scorecard or share it straight to WhatsApp, Instagram, or
   whatever's already on your phone — and challenge your friend to take the
   quiz themselves and see if their answers match.

WHY YOU'LL LIKE IT
• Genuinely funny, not generic — every question is written to get a real
  laugh out of a real friendship.
• Takes under 2 minutes.
• No account, no email, no data collection — see below.
• A fresh mix of questions nearly every time you play.

YOUR PRIVACY
friendshipmania has no internet permission at all — it cannot send your
information anywhere, because it has no server and makes no network
requests. The names you enter stay on your device for that one session and
are never saved or transmitted. Full privacy policy in the link below.

Got a friend who thinks they're "ride or die"? Prove it — or roast them for
it.
```
(1,283 characters — well under the 4000 limit)

## Graphics checklist

All generated and ready in `graphics/store/`:

| Asset | File | Spec | Status |
|---|---|---|---|
| App icon | `graphics/store/app_icon_512.png` | 512×512 PNG | ✅ ready |
| Feature graphic | `graphics/store/feature_graphic.png` | 1024×500 PNG | ✅ ready |
| Phone screenshots (2–8 required) | `graphics/store/screenshot_*.png` | 16:9–9:16, min 320px side | ⏳ pending a real device/emulator run — see note below |

**Screenshots note:** Play requires real, representative screenshots — not
mockups. These need to come from actually running the app on a device or
emulator, which needs either a physical Android phone connected over `adb`,
or KVM access on this dev machine for the emulator. That step is queued and
will be finished once one of those is available (see the command board doc's
"Open follow-ups" section).

## Privacy policy

Hosted page source is at `docs/privacy-policy.html` — upload it to
`homilabs.org` (matching your other Homilabs apps) and paste that live URL
into Play Console's "Privacy policy" field. Before uploading, fill in the
`<fill in your contact email...>` placeholder near the bottom of the page.

## Data safety form (Play Console)

Since the app collects and transmits nothing, answer Play Console's Data
Safety questionnaire as:
- "Does your app collect or share any of the required user data types?" → **No**
- No data types to declare, no data shared with third parties, no data
  encrypted-in-transit question applies (nothing is transmitted).

This is one of the few genuinely honest "no data collected" apps you'll ever
submit — worth double-checking the questionnaire reflects that instead of
Play's usual defaults.

## Release notes (first version)

```
🎉 friendshipmania is here! Enter your name and your friend's name, answer
10 hilarious questions about your friendship, and get your verdict. No
login, no data collection — just laughs.
```
