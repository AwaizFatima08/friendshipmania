# The Friendship Polygraph — Stage 1

This is the first working slice of the app, described in `friendship-meter-spec.md`.
It's a real, runnable Flutter project — not a mockup — but it's deliberately small:
sharing between friends and the online "reciprocal invite" piece aren't built yet.
That's on purpose, so we can check this part is solid before adding the trickier bits.

## What actually works right now

1. A welcome screen for the app.
2. Enter your name and your friend's name (no login, nothing to remember).
3. Answer 10 random, sharper/roast-style questions, pulled from a bank of 40 so
   it varies each time you play.
4. See your own funny scorecard: a percentage, an emoji, and a roast-y verdict
   (like "🔥 Actual Real Friends" or "🧊 Certified Frenemies").
5. Play again with a fresh set of questions.

The "Share" button on the scorecard is there, but it's a placeholder for now —
tapping it just explains that sharing/inviting your friend back is coming in
the next stage.

## How to actually see it running (no coding needed)

1. Install **Android Studio** (free, from developer.android.com) if you don't
   already have it — it includes everything needed to run Flutter apps,
   including a virtual Android phone.
2. Open Android Studio, choose **Open**, and pick this `friendship_polygraph`
   folder.
3. The first time, Android Studio may ask to install the Flutter/Dart plugin —
   accept that.
4. Pick a device to run on at the top (either a plugged-in Android phone with
   USB debugging on, or Android Studio's built-in virtual phone).
5. Click the green ▶ Run button.

The app will build and open on the device — that's the whole process.

## What's verified already (so you're not the first to hit bugs)

Before this was handed to you, I ran:
- `flutter analyze` — no warnings or errors in the code.
- `flutter test` — 4 automated tests, covering: the welcome screen loads, names
  can be entered, a full 10-question run correctly reaches a scorecard, and the
  scoring math always stays between 0% and 100%. All 4 pass.

This doesn't replace you actually tapping through it on a phone once it's
running — that's the real test — but it means the basic logic is sound.

## What's next (once you've tried this and we talk it over)

1. Turning the scorecard into a downloadable image.
2. The Firebase piece that lets you actually send this to your friend and have
   them answer back.
3. The App Links setup on homilabs.org so the shared link opens the app
   directly.
4. The final joint "how in-sync are you two" scorecard.

We'll do these one at a time, same as this stage — build it, verify it, then
move on.
