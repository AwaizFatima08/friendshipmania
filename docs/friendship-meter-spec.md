# Friendship Meter — App Specification v1 (draft for review)

*Prepared 2026-09-10. Nothing gets built until you've reviewed and adjusted this — same as we did for the Ludo app.*

## 1. The idea, in one paragraph

Two friends, no accounts. Friend A opens the app, types both names, and answers ~15 funny/insightful questions about the friendship. The app spits out a goofy scorecard (a score + a funny title, like "87% — Ride or Die"). Friend A shares that scorecard as a link with Friend B. Friend B opens it, answers the same kind of questions about the same friendship, and the app then reveals a **joint** scorecard showing how "in sync" the two of them really are — which is funnier and more true to "depth of friendship" than just averaging two separate self-ratings. Both can download the final scorecard as an image.

## 2. Step-by-step user flow

1. **Friend A opens the app** → enters their name and Friend A's friend's name (no login, no email, nothing to remember).
2. **Question round 1** → app randomly pulls ~15 questions from a larger question bank spread across a few humor categories, so no two runs feel identical.
3. **A's solo result** → a lighthearted "here's your read on this friendship" card, so A gets something fun immediately, without waiting on B.
4. **Share** → A taps Share, gets a link (via WhatsApp, SMS, whatever) to send to the friend. If the friend already has the app, the link opens it directly to a "Your friend rated you — your turn!" screen. If not, it opens a simple web page with an install button.
5. **Friend B answers** the same style of question set about the same friendship.
6. **Joint scorecard** → the app compares both sets of answers and produces one combined, funny "Friendship Score" with commentary (e.g. "92% — Telepathic Twins" vs. "45% — It's Complicated, But We Vibe"). Both people can download this as an image.

## 3. How it works without any login (the technical bit, in plain terms)

- The app itself never asks anyone to sign up or sign in.
- Behind the scenes, it quietly creates an anonymous, invisible session in Firebase (Google's app backend service) the moment Friend A starts — this is what lets Friend B's phone find Friend A's answers later. You never see this as a "login," it just works.
- The shareable link points at your own domain (**homilabs.org**, which you already own) and is set up as an "Android App Link" — Google's current, supported way to make a link open straight into an app if it's installed, or a fallback web page if it isn't.
- One thing worth flagging: **Firebase's old "Dynamic Links" service (the thing most tutorials still mention for this) was shut down for good in August 2025.** So we're using the current, supported replacement (App Links + a small fallback page on your domain) rather than a discontinued tool — just didn't want you to run into outdated advice on this later.

## 4. What's in the question bank

- A bundled set of questions (100+ to start), tagged by humor style — e.g. *silly*, *nostalgic*, *sentimental*, *"tell on yourselves"* — so each run samples across tags instead of repeating the same 15 every time.
- **Open question for you:** how "cheeky" should the humor go? I'd recommend keeping it affectionate and silly rather than roast-style/insulting — a joke that's hilarious to one friend can land as genuinely hurtful to the other, and this app has no way to know their relationship well enough to judge that line. Happy to do a "spicy mode" toggle later, but I'd start gentle.

## 5. Screens (the actual list of things I'll be building)

1. Splash / welcome
2. Enter both names
3. Question flow (progress bar, one question at a time)
4. Solo result card (Friend A's immediate payoff)
5. Share screen
6. Friend B's landing screen (arrives via the link)
7. Friend B's question flow
8. Joint scorecard (the final, shareable result)

No accounts screen, no settings screen, no history list — keeping this lean for v1.

## 6. Publishing requirements (so nothing surprises us later)

- Google Play now requires new apps to target **Android 16 (API level 36)** as of the August 31, 2026 deadline — already in effect. I'll build against that from day one so there's no scramble before submission.
- Since the app handles two people's names and (indirectly) their answers about each other, Play's listing will need a short, simple privacy policy page — standard for any quiz/compatibility-style app, easy to write, just flagging it's a required step, not optional.
- Will publish to your existing paid Play Console account, same as the other apps.

## 7. Cost

- Firebase's free tier (Spark plan) should comfortably cover normal usage — a handful of reads/writes per session, a tiny hosting page. If the app ever goes properly viral, Firebase would need to switch to its pay-as-you-go tier, but that's a "good problem to have" and costs pennies at moderate scale.

## 8. My honest concerns with this plan (per your standing request to critique, not just agree)

- **No login + reciprocal linking still needs *some* backend.** You picked Firebase for this, which is the right call, but it does mean the app needs an internet connection to work — there's no fully-offline mode. Worth knowing going in.
- **Anyone who has the link can open it and "become" that friend.** Since there's no account tied to a real identity, if a link gets forwarded or leaked, a stranger could technically open it and answer as if they were your friend. For a fun app like this, that's an acceptable risk and not worth over-engineering against — but I didn't want to design around it silently.
- **Drop-off risk:** plenty of invited friends will never click the link. That's why step 3 (Friend A's solo result) exists — A gets a payoff immediately rather than the whole thing feeling pointless if B never responds.
- **Setting up App Links on homilabs.org is a real, slightly technical one-time step** (verifying domain ownership via a small file hosted on your site). I'll handle the technical side, but I'll need you to have access to your Hostinger/domain settings when we get there.

## 9. How I'd sequence the actual build (even though you've chosen full scope up front)

You asked for the full app scoped now, which this document does — but I'd still build it in verified stages rather than all at once, per how we've worked before:

1. Names entry + question flow + solo scorecard, running and testable on its own.
2. Firebase session creation/retrieval, verified working between two test devices.
3. Scorecard image generation and download.
4. Sharing + App Links + the fallback web page (the trickiest, most fiddly part — saved for once everything else is solid).
5. Joint scorecard logic and polish.

## 10. Decisions I need from you before I start building

1. **Humor tone:** gentle/affectionate (recommended) or okay with sharper/roast-style jokes?
2. **App name:** "Friendship Meter" as a working title — good to lock in, or did you have another name in mind? (I'll also do a quick Play Store name-collision check once confirmed.)
3. **Scoring approach:** confirm the "how in-sync are your two answers" compatibility scoring (recommended, described in Section 1) rather than a simple average of two separate self-ratings.
4. **Question count per run:** 15 as a starting point, or a different number?

Once you confirm these four, I'll start on stage 1 from Section 9.
