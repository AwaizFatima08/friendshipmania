# friendshipmania launch posts

Files are in `out/`. Rebuild everything with `python3 build.py` (see the top of that file).

Every QR code and link carries its own `utm_source`, so Play Console →
**Grow users → Store performance → Acquisition** shows which channel brought installs.

| Channel | File | QR / link tag |
|---|---|---|
| Print poster (A3, also fine at A4) | `poster_A3.pdf` (print) · `poster_A3.png` (3508×4962, 300 dpi) | `poster` |
| Facebook feed | `facebook_post_1080x1350.png` | `facebook` |
| Instagram feed | `instagram_post_1080x1350.png` | `instagram` |
| Instagram / Facebook story | `instagram_story_1080x1920.png` | `instagram` |
| TikTok photo post | `tiktok_photo_1080x1920.png` | `tiktok` |
| TikTok video / Instagram Reels / Facebook Reels | `tiktok_reels_video_1080x1920.mp4` (14 s, silent) | `tiktok` |

Links to paste:

- Facebook: `https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania&referrer=utm_source%3Dfacebook`
- Instagram (bio + story link sticker): `https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania&referrer=utm_source%3Dinstagram`
- TikTok (bio): `https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania&referrer=utm_source%3Dtiktok`

---

## Facebook (feed post)

```
Is your bestie lying to you? 🕵️

friendshipmania is OUT NOW on Google Play 🎉
Type two names, answer 10 unhinged questions (raccoon kidnappings, goose attacks, zombie plans…) and get one brutally honest verdict on your friendship. Then send it to them and watch the drama unfold. 🍿

✅ Free · ✅ No ads · ✅ Takes 2 minutes · Ages 13+

👉 Scan the QR or tap here: https://play.google.com/store/apps/details?id=com.homilabs.friendshipmania&referrer=utm_source%3Dfacebook

Tag the friend who's about to get exposed 👇
#friendshipmania #bestfriends #friendshipgoals #bff #friendshiptest #newapp
```

## Instagram (feed post)

```
Is your bestie lying to you? 🕵️ The polygraph never lies.

friendshipmania just dropped 🎉 10 unhinged questions → 1 brutal verdict → send it to your bestie → chaos. 🍿

Free on Google Play, no ads. Link in bio 🔗 (or scan the QR!)

Tag the bestie who needs to take this test 👇

#friendshipmania #bestie #bestfriends #bff #friendshipgoals #friendshiptest #besties #genz #newapp #androidapp
```

Alt text: *Purple cartoon detective mascot with a magnifying glass next to a phone showing a "27% – Friendship, Allegedly" verdict. Text: "Is your bestie lying to you?" and a QR code to friendshipmania on Google Play.*

## Instagram / Facebook story

Post `instagram_story_1080x1920.png`, then add a **Link sticker** with the Instagram link above,
and a **poll sticker** in the empty space under the QR card: "Would your bestie pass? 😇 / 💀".

## TikTok

Video caption (`tiktok_reels_video_1080x1920.mp4`):

```
POV: you finally ask the polygraph about your bestie 🕵️💀 friendshipmania is out now — free on Google Play, link in bio 🔗 #friendshipmania #bestie #bestfriends #friendshiptest #bff #fyp #foryou #newapp
```

Photo-post caption (`tiktok_photo_1080x1920.png`):

```
10 unhinged questions. 1 brutal verdict. Is your bestie actually your bestie? 🤨 Free on Google Play — link in bio #friendshipmania #bestie #friendshiptest #fyp
```

Tips:
- The video is **silent on purpose** — add a trending sound in TikTok/Instagram before posting (licensed in-app sounds only).
- Keep the cover frame on the first slide ("POV: you ask the polygraph…").
- TikTok bio links need a Business account (or 1,000+ followers on a personal account); until then point people to "search friendshipmania on Google Play".

## Instagram / Facebook Reels

Same video and the TikTok caption, with `#reels` instead of `#fyp #foryou`.

---

Notes:
- The verdict screenshot shows two first names ("Humayun on Sumaira") from a real test run — the same image is already in the Play listing. Swap the screenshot in `graphics/store/` and rebuild if you'd rather not show them.
- Art: the mascot and stickers are the approved homidev images (AI-generated, already labelled as AI in Play). No sound effects are used, so no extra attribution is needed in these posts.
