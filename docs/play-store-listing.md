# Play Store listing — copy & Play Console answers

Everything here matches what the app **actually** does now (accounts + Firestore).
The live legal pages are on the subdomain (source: `site/friendshipmania/`).

## URLs to paste into Play Console

| Field | Value |
|---|---|
| Privacy policy | `https://friendshipmania.homilabs.org/privacy.html` |
| Account deletion URL (App content → Data safety) | `https://friendshipmania.homilabs.org/delete-account.html` |
| Website | `https://friendshipmania.homilabs.org` |
| Support email | `homilabs.smc@gmail.com` (already public on homilabs.org) |

## App details

| Field | Value |
|---|---|
| App name | `friendshipmania` |
| Package name | `com.homilabs.friendshipmania` |
| Category | Entertainment |
| Free / paid | Free |
| Contains ads | **Yes** — AdMob banners on the verdict + My verdicts screens (from 1.0.1) |
| In-app purchases | **No** |
| Target age | **13+** only (not "designed for children"; do NOT opt into Families) |
| Content rating | Expect **Teen** (cheeky/roast humor, mild crude humor, user-generated names). Answer the IARC questionnaire honestly. |

## Short description (max 80 characters)

```
Put your friendship on trial. 10 unhinged questions, one brutal verdict. 🕵️
```
(75 characters)

## Full description (max 4000 characters)

```
Nobody lies to a polygraph. 🕵️

friendshipmania puts your friendship on trial. Answer 10 unhinged questions, get a brutally honest verdict, and send it to the friend in question. Then dare them to take the test and tell you you're wrong.

HOW IT WORKS
1. Type two names — yours and your friend's. A nickname is fine.
2. Answer 10 random, ridiculous questions: raccoon kidnappings, goose attacks, zombie plans, museum plaques for your friendship.
3. Get your verdict: a percentage, a roast-y title (like "Frenemies With Wi-Fi" or "Ride-or-Die Main Characters"), and a breakdown of where your friendship shines or crashes.
4. Download the scorecard or share it straight to WhatsApp, Instagram or whatever's on your phone.

WHY YOU'LL LIKE IT
• Actually funny. Every question is written to get a real laugh out of a real friendship.
• Different every time — a fresh mix of questions and shuffled answers.
• Takes about two minutes.
• Free, kept that way by a few small banner ads. No in-app purchases.
• Sign in is optional: use email, Google, or skip it and stay a lone wolf.

YOUR DATA
If you sign in, your name, email and saved verdicts are stored with Google Firebase so they follow you across phones. You can delete any verdict — or your whole account — from inside the app at any time. We never sell your data. Guests don't have anything stored on our servers. Full details: https://friendshipmania.homilabs.org/privacy.html

For ages 13+. Totally unscientific, deeply accurate, legally unqualified.

Sound effects: Powered by Stability AI.
```

## Data safety form (Play Console → App content)

**Does the app collect or share any user data?** Yes — collects. Shares: **No** (Firebase acts as our service provider/processor, which Play does not count as "sharing").

| Data type | Collected | Purpose | Optional? | Processed ephemerally? |
|---|---|---|---|---|
| Personal info → **Name** | Yes | App functionality, account management | Yes (sign-in is optional) | No |
| Personal info → **Email address** | Yes | App functionality, account management | Yes | No |
| Personal info → **User IDs** (Firebase UID) | Yes | App functionality, account management | Yes | No |
| App activity → **Other user-generated content** (friend names typed, saved verdicts) | Yes | App functionality | Yes | No |

**Added in 1.0.1 for AdMob** (collected by the Google Mobile Ads SDK; Google's own AdMob
data-disclosure guidance lists these — re-check it before submitting):

| Data type | Collected | Shared | Purpose | Optional? |
|---|---|---|---|---|
| Location → **Approximate location** (from IP address) | Yes | Yes | Advertising or marketing, Analytics, Fraud prevention | No |
| App activity → **App interactions** (ad views/taps) | Yes | Yes | Advertising or marketing, Analytics | No |
| App info and performance → **Crash logs**, **Diagnostics** | Yes | Yes | Analytics, Fraud prevention | No |
| Device or other IDs → **Device or other IDs** (advertising ID) | Yes | Yes | Advertising or marketing, Analytics, Fraud prevention | No |

So the top answer changes to **collects AND shares** (the four AdMob rows are shared with Google
for advertising; the original four rows stay "collected, not shared").

- **Encrypted in transit:** Yes (HTTPS).
- **Users can request deletion:** Yes — in-app, plus the deletion URL above.
- **Not collected:** precise location, contacts, photos/files, audio, financial info, our own analytics.
- **If this changes** (analytics, crash reporting, more ad formats): update this form AND the privacy page *before* that release.

## Other App content declarations

- **Ads:** Yes (from 1.0.1). The "Contains ads" label then shows on the listing.
- **Government/financial/health/news app:** No.
- **Account deletion:** has accounts → enter the deletion URL (above). The in-app path is *My account → Delete account & data*.
- **Target audience:** 13–15, 16–17, 18+. Not under 13.

## Graphics checklist

| Asset | File | Status |
|---|---|---|
| App icon 512×512 | `graphics/store/app_icon_512.png` | ✅ mascot on neon lime (rebuild: `assets/icon/build_store_graphics.sh`) |
| Feature graphic 1024×500 | `graphics/store/feature_graphic.png` | ✅ mascot + verdict stickers |
| Phone screenshots (2–8) | `graphics/store/screenshot_1..4.png` (720×1440) | ✅ real captures from a Samsung A12: welcome, question, verdict, share/download |

## Required attribution
The app ships homidev sound effects (Stable Audio, Stability AI Community Licence), so **"Powered by Stability AI"**
is shown on the About screen (`attributionLines` in `lib/config.dart`) and is in the full description above.
Keep both if the sounds stay; `release-check.sh` fails the build if the About screen loses it.

## Release notes (first version)

```
🎉 friendshipmania is here! Put your friendship on trial with 10 unhinged questions, get your verdict, and send it to your friend. Sign in with email or Google (or skip it).
```
