# Play Console upload — step by step (owner does the clicks)

Everything to paste is in `docs/play-store-listing.md`. Files are in `build/` and `graphics/store/`.

## 0. Before you start
- [ ] **Upload the website first** (`site/README.md`): Play checks that the privacy-policy URL is live.
      Open `https://friendshipmania.homilabs.org/privacy.html` and `/delete-account.html` in a browser.
- [ ] Back up `android/keystore/friendshipmania-release.jks` + `android/key.properties` somewhere safe (not git).

## 1. Create the app
Play Console → **Create app**
- App name `friendshipmania` · Default language English · **App** · **Free**
- Tick the declarations (developer programme policies, US export laws).

## 2. Track: Production directly
Homilabs is an organisation account (no 12-tester closed-test rule), and the owner's standing rule is that
every build goes **straight to Production** — no internal/closed/open testing tracks.
Test and release → Production → Countries / regions (all) → Create new release.

## 3. Upload the bundle
- File: `build/app/outputs/bundle/release/app-release.aab` (version **1.0.0 (1)**, package `com.homilabs.friendshipmania`).
- Accept **Play App Signing** (default). Your keystore becomes the *upload* key.
- Release name `1.0.0`, release notes from `docs/play-store-listing.md`.

## 4. Fix Google sign-in for Play-installed copies (important)
Play re-signs the app with its own key, which Firebase doesn't know yet.
- Play Console → **Test and release → App integrity → App signing**: copy the **SHA-1** and **SHA-256**
  of the *App signing key certificate*.
- Add both in Firebase → Project settings → Android app `com.homilabs.friendshipmania` → **Add fingerprint**
  (or send them to Claude to add with the Firebase CLI).
- No rebuild needed for sign-in to work; Google matches package + fingerprint on its side.
- Without this step, **Continue with Google fails** on copies installed from Play (email sign-in still works).

## 5. Store listing (Grow → Store presence → Main store listing)
- Short + full description: from `docs/play-store-listing.md` (the full description ends with
  "Sound effects: Powered by Stability AI." — keep it; it's a licence requirement).
- App icon: `graphics/store/app_icon_512.png`
- Feature graphic: `graphics/store/feature_graphic.png`
- Phone screenshots: `graphics/store/screenshot_1.png` … `screenshot_4.png`
- Category **Entertainment** · contact email `homilabs.smc@gmail.com` · website `https://friendshipmania.homilabs.org`

## 6. App content (Policy → App content)
| Item | Answer |
|---|---|
| Privacy policy | `https://friendshipmania.homilabs.org/privacy.html` |
| Ads | No |
| App access | *All or some functionality is restricted* → instructions: "Sign-in is optional. Tap **Skip** to use the app as a guest, or **Sign in → Sign up** with any email to test saved verdicts and account deletion." |
| Content rating | Fill the IARC questionnaire honestly (cheeky/roast humour, user-typed names, no violence/gambling) — expect **Teen** |
| Target audience | 13–15, 16–17, 18+ (not under 13; not Families) |
| Data safety | Exactly as in `docs/play-store-listing.md` (collects name, email, user ID, user-generated content; encrypted in transit; deletion available) |
| Account deletion | URL `https://friendshipmania.homilabs.org/delete-account.html`; in-app path *My account → Delete account & data* |
| News / health / financial / government | No |

## 7. Review and roll out
Send for review, then roll out when approved. **This final click is yours.**

## After launch
- Update the Play button note in `site/friendshipmania/index.html` and re-upload; add the app to homilabs.org "Live apps".
- `lib/services/report_service.dart` already links to `https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania`.
