import '../models/question.dart';

/// The full question bank for friendshipmania.
///
/// Every quiz run randomly samples 10 of these, mixed across tags, so
/// back-to-back runs rarely feel identical. Within each question the
/// answers are listed best-friendship-first (score 3 down to 0) purely for
/// the author's sanity — the quiz screen shuffles them before showing them,
/// so the top answer is never always the "good" one.
///
/// Keep this list append-only when adding questions; nothing else in the
/// app needs to change to grow the bank.
const List<Question> questionBank = [
  // --- roast ---------------------------------------------------------
  Question(
    id: 'roast_1',
    tag: 'roast',
    prompt: "Your friend picks ONE emoji to describe you. Which one?",
    options: [
      AnswerOption(text: "💖 — followed by a very long, very embarrassing voice note", score: 3),
      AnswerOption(text: "😂 — affectionate, but it's definitely about your face", score: 2),
      AnswerOption(text: "🤡 — not a roast, a lifestyle", score: 1),
      AnswerOption(text: "🚩 — they've been waiting for this exact question", score: 0),
    ],
  ),
  Question(
    id: 'roast_2',
    tag: 'roast',
    prompt: "Your name pops up on their screen. What happens in the first 0.3 seconds?",
    options: [
      AnswerOption(text: "Instant grin. Answers before the first ring ends.", score: 3),
      AnswerOption(text: "Dramatic sigh. Answers anyway.", score: 2),
      AnswerOption(text: "Stares at it like a bomb they must defuse.", score: 1),
      AnswerOption(text: "Phone mysteriously 'breaks' until Thursday.", score: 0),
    ],
  ),
  Question(
    id: 'roast_3',
    tag: 'roast',
    prompt: "If your friendship were a restaurant on Google Maps, what's the rating?",
    options: [
      AnswerOption(text: "4.9 ⭐ \"Would be emotionally loyal here again.\"", score: 3),
      AnswerOption(text: "4.1 ⭐ \"Food is chaos, staff is lovely.\"", score: 2),
      AnswerOption(text: "2.7 ⭐ \"Owner keeps arguing with the reviewers.\"", score: 1),
      AnswerOption(text: "1.0 ⭐ \"Found a hair in my feelings.\"", score: 0),
    ],
  ),
  Question(
    id: 'roast_4',
    tag: 'roast',
    prompt: "A raccoon kidnaps you. Your friend negotiates the ransom. How does it go?",
    options: [
      AnswerOption(text: "Calm speech, snack offering, full rescue. The raccoon cries.", score: 3),
      AnswerOption(text: "They try… then ask the raccoon for a discount.", score: 2),
      AnswerOption(text: "They ask if the raccoon accepts installments.", score: 1),
      AnswerOption(text: "They ask the raccoon to keep you. Joint custody, maybe.", score: 0),
    ],
  ),
  Question(
    id: 'roast_5',
    tag: 'roast',
    prompt: "You announce a terrible idea. What's their reaction?",
    options: [
      AnswerOption(text: "\"Say less. I'll bring snacks and a getaway car.\"", score: 3),
      AnswerOption(text: "Rolls their eyes so hard they see their brain. Joins anyway.", score: 2),
      AnswerOption(text: "Sends a 4-minute voice note titled 'Why no.'", score: 1),
      AnswerOption(text: "Leaves you on read and updates their will.", score: 0),
    ],
  ),
  Question(
    id: 'roast_6',
    tag: 'roast',
    prompt: "Your friend writes your autobiography. What's the title?",
    options: [
      AnswerOption(text: "\"The Legend, Volume 1\"", score: 3),
      AnswerOption(text: "\"Oops, I Did It Again (Daily)\"", score: 2),
      AnswerOption(text: "\"Chaos With Good Intentions\"", score: 1),
      AnswerOption(text: "\"Please Do Not Feed After Midnight\"", score: 0),
    ],
  ),
  Question(
    id: 'roast_7',
    tag: 'roast',
    prompt: "You cancel plans 10 minutes before. What happens?",
    options: [
      AnswerOption(text: "\"Love you, rest, bye\" + a meme.", score: 3),
      AnswerOption(text: "A tiny sassy 'wow.' Then all is forgiven.", score: 2),
      AnswerOption(text: "A passive-aggressive 👍 that echoes through time.", score: 1),
      AnswerOption(text: "Banned from the next three hangouts. No appeal.", score: 0),
    ],
  ),
  Question(
    id: 'roast_8',
    tag: 'roast',
    prompt: "Be honest: how fast do you reply to their texts?",
    options: [
      AnswerOption(text: "Faster than a delivery-app notification.", score: 3),
      AnswerOption(text: "Within the day, like a decent human.", score: 2),
      AnswerOption(text: "'Seen' at 2 AM. Replied three days later with 'lol'.", score: 1),
      AnswerOption(text: "Texts? I only communicate through vibes.", score: 0),
    ],
  ),

  // --- loyalty ---------------------------------------------------------
  Question(
    id: 'loyalty_1',
    tag: 'loyalty',
    prompt: "They're in a feud with a stranger over a parking spot. You…",
    options: [
      AnswerOption(text: "Show up, ask nothing, pick a side, bring a folding chair.", score: 3),
      AnswerOption(text: "Hear them out, then pick their side anyway.", score: 2),
      AnswerOption(text: "Suggest a 'calm, mature conversation' like a coward.", score: 1),
      AnswerOption(text: "Stay neutral like Switzerland (the country, the chocolate).", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_2',
    tag: 'loyalty',
    prompt: "It's 3 AM and they need a ride. What's your status?",
    options: [
      AnswerOption(text: "Already in the car, wearing one slipper.", score: 3),
      AnswerOption(text: "Groans like a haunted door. Shows up anyway.", score: 2),
      AnswerOption(text: "Orders them an Uber and sends a supportive thumbs-up.", score: 1),
      AnswerOption(text: "Airplane mode. Unreachable. Very peaceful.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_3',
    tag: 'loyalty',
    prompt: "They tell you a huge secret. What's its shelf life?",
    options: [
      AnswerOption(text: "Buried deeper than my Wi-Fi password.", score: 3),
      AnswerOption(text: "Safe… unless it's truly spectacular (rare).", score: 2),
      AnswerOption(text: "Might slip out after two bubble teas.", score: 1),
      AnswerOption(text: "The group chat knows by lunch. The group chat has notes.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_4',
    tag: 'loyalty',
    prompt: "A goose chases them through the park. You…",
    options: [
      AnswerOption(text: "Charge in holding a baguette like a shield.", score: 3),
      AnswerOption(text: "Yell encouragement and film from a safe distance.", score: 2),
      AnswerOption(text: "Call animal control and cry.", score: 1),
      AnswerOption(text: "Pretend you don't know them. The goose knows.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_5',
    tag: 'loyalty',
    prompt: "They're moving apartments. What's your role?",
    options: [
      AnswerOption(text: "Truck, snacks, strong opinions about the couch.", score: 3),
      AnswerOption(text: "Show up, then mention it forever after.", score: 2),
      AnswerOption(text: "Offer emotional support via text from afar.", score: 1),
      AnswerOption(text: "Suddenly allergic to cardboard.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_6',
    tag: 'loyalty',
    prompt: "Their birthday is tomorrow. How prepared are you?",
    options: [
      AnswerOption(text: "Surprise planned, balloons inflated, cake hidden in my closet.", score: 3),
      AnswerOption(text: "Panic-buying a gift at 11 PM, with love.", score: 2),
      AnswerOption(text: "A 11:59 PM text: \"hbd!!!\" (no fear of punctuation).", score: 1),
      AnswerOption(text: "Wait — tomorrow? Tomorrow is what now?", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_7',
    tag: 'loyalty',
    prompt: "They need a fake emergency to escape a boring family event (hypothetically). You…",
    options: [
      AnswerOption(text: "Call within 30 seconds with an Oscar-winning crisis.", score: 3),
      AnswerOption(text: "Text \"URGENT!!\" and hope it's believable.", score: 2),
      AnswerOption(text: "Say \"Sorry, ethics.\" and leave them to suffer.", score: 1),
      AnswerOption(text: "Tell the whole family the truth. Loudly.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_8',
    tag: 'loyalty',
    prompt: "They borrow money 'until Friday.' Which Friday?",
    options: [
      AnswerOption(text: "Sent before the 'sorry to ask' text even finishes.", score: 3),
      AnswerOption(text: "Sent, with a gentle 'friendship contract' joke.", score: 2),
      AnswerOption(text: "A detailed repayment plan, with interest, signed.", score: 1),
      AnswerOption(text: "\"Have you tried a bank? Or the moon?\"", score: 0),
    ],
  ),

  // --- chaos ---------------------------------------------------------
  Question(
    id: 'chaos_1',
    tag: 'chaos',
    prompt: "What's the most unhinged thing you've agreed to at 1 AM?",
    options: [
      AnswerOption(text: "Something legendary. We'd do it again tomorrow.", score: 3),
      AnswerOption(text: "A questionable idea, but now it's a great story.", score: 2),
      AnswerOption(text: "We nearly did it but talked each other out of it.", score: 1),
      AnswerOption(text: "We don't do spontaneous. We do spreadsheets.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_2',
    tag: 'chaos',
    prompt: "Road trip together. What's the vibe?",
    options: [
      AnswerOption(text: "Chaos, loud singing, snack debates. Unforgettable.", score: 3),
      AnswerOption(text: "Great, minus one dramatic argument about the playlist.", score: 2),
      AnswerOption(text: "Tense. The GPS is the villain.", score: 1),
      AnswerOption(text: "We've never risked it. We love each other too much.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_3',
    tag: 'chaos',
    prompt: "You're both lost, no signal, 4% battery. Now what?",
    options: [
      AnswerOption(text: "Best part of the trip. We name the sidewalk.", score: 3),
      AnswerOption(text: "Panic, laughter, then a legendary story.", score: 2),
      AnswerOption(text: "\"You had the map!\" \"WE HAVE NO MAP!\"", score: 1),
      AnswerOption(text: "The friendship ends at the nearest tree.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_4',
    tag: 'chaos',
    prompt: "Karaoke night. What actually happens?",
    options: [
      AnswerOption(text: "A concert-level performance. Strangers cry.", score: 3),
      AnswerOption(text: "One song, then we pretend we've never met.", score: 2),
      AnswerOption(text: "We judge everyone from a dark corner.", score: 1),
      AnswerOption(text: "We'd never. We're allergic to microphones.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_5',
    tag: 'chaos',
    prompt: "One of you wants a tattoo at midnight. The other…",
    options: [
      AnswerOption(text: "Is already googling shops and matching designs.", score: 3),
      AnswerOption(text: "Debates it, then Googles it anyway.", score: 2),
      AnswerOption(text: "Talks them out of it (mostly).", score: 1),
      AnswerOption(text: "Calls their mother. On speaker.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_6',
    tag: 'chaos',
    prompt: "Describe your group chat energy.",
    options: [
      AnswerOption(text: "400 messages a day: 390 memes, 10 plans.", score: 3),
      AnswerOption(text: "Mostly logistics, with sudden bursts of chaos.", score: 2),
      AnswerOption(text: "Quiet, except birthday reminders and one cursed meme.", score: 1),
      AnswerOption(text: "What group chat? We use carrier pigeons.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_7',
    tag: 'chaos',
    prompt: "You both try a weird viral food trend. Result?",
    options: [
      AnswerOption(text: "10/10, no regrets, ordering it again with extra sauce.", score: 3),
      AnswerOption(text: "Regretful, but we laughed about it for a week.", score: 2),
      AnswerOption(text: "One of us definitely got a stomachache.", score: 1),
      AnswerOption(text: "We stuck to plain rice like responsible adults.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_8',
    tag: 'chaos',
    prompt: "The zombie apocalypse starts. What's your plan together?",
    options: [
      AnswerOption(text: "Snack-based survival strategy, matching outfits, and a theme song.", score: 3),
      AnswerOption(text: "Split the map, regroup at the nearest Wi-Fi.", score: 2),
      AnswerOption(text: "One of us is bait. We argue about who.", score: 1),
      AnswerOption(text: "Run in opposite directions. Good luck out there!", score: 0),
    ],
  ),

  // --- receipts (honesty) ---------------------------------------------
  Question(
    id: 'receipts_1',
    tag: 'receipts',
    prompt: "Has this friend ever said something that really stung?",
    options: [
      AnswerOption(text: "Once — they apologized before I could say 'ow.'", score: 3),
      AnswerOption(text: "A couple of times. We talked like grown-ups.", score: 2),
      AnswerOption(text: "Yes, and it's still a tiny sore spot.", score: 1),
      AnswerOption(text: "Regularly. We have a 'never speak of it' rule.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_2',
    tag: 'receipts',
    prompt: "Your outfit looks like a laundry accident. They…",
    options: [
      AnswerOption(text: "Tell you lovingly, instantly, with a better idea.", score: 3),
      AnswerOption(text: "Drop a gentle hint and one raised eyebrow.", score: 2),
      AnswerOption(text: "Let you walk out. You find out from your reflection.", score: 1),
      AnswerOption(text: "Tell everyone else first. You find out via group chat.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_3',
    tag: 'receipts',
    prompt: "You're venting about your day. Do they actually listen?",
    options: [
      AnswerOption(text: "Full therapist mode: phone down, eye contact, snacks.", score: 3),
      AnswerOption(text: "Mostly. Occasionally glances at a dog video.", score: 2),
      AnswerOption(text: "Nods a lot, clearly thinking about lunch.", score: 1),
      AnswerOption(text: "Somehow turns it into a story about themselves.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_4',
    tag: 'receipts',
    prompt: "You win at something big. What's their real reaction?",
    options: [
      AnswerOption(text: "Screams, tells strangers, makes a banner.", score: 3),
      AnswerOption(text: "Happy for you, with a tiny hint of competition.", score: 2),
      AnswerOption(text: "Congratulates you, then changes the subject fast.", score: 1),
      AnswerOption(text: "A suspiciously flat \"nice.\" And then, \"anyway.\"", score: 0),
    ],
  ),
  Question(
    id: 'receipts_5',
    tag: 'receipts',
    prompt: "You need brutally honest advice. Would they give it?",
    options: [
      AnswerOption(text: "Immediately. No sugar. A little salt. Pure love.", score: 3),
      AnswerOption(text: "Yes, wrapped in a joke for safety.", score: 2),
      AnswerOption(text: "Eventually, after twelve 'well, maybe…'s.", score: 1),
      AnswerOption(text: "They'd just agree with whatever you already think.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_6',
    tag: 'receipts',
    prompt: "How do apologies work between you two?",
    options: [
      AnswerOption(text: "Quick, sincere, back to normal in minutes.", score: 3),
      AnswerOption(text: "A bit awkward, but it happens.", score: 2),
      AnswerOption(text: "A cold war of silence, then suddenly we're fine.", score: 1),
      AnswerOption(text: "We pretend nothing happened. For years.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_7',
    tag: 'receipts',
    prompt: "Your crush is secretly a walking red flag. Would they tell you?",
    options: [
      AnswerOption(text: "Immediately. With slides. And receipts.", score: 3),
      AnswerOption(text: "Eventually, after trying their best to like them.", score: 2),
      AnswerOption(text: "Drops hints like \"…interesting choice.\"", score: 1),
      AnswerOption(text: "Smiles. Says nothing. Gives the wedding toast.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_8',
    tag: 'receipts',
    prompt: "When you're wrong, they…",
    options: [
      AnswerOption(text: "Say it straight, no drama, then buy you fries.", score: 3),
      AnswerOption(text: "Let you figure it out gently.", score: 2),
      AnswerOption(text: "Bring it up in six months, out of nowhere.", score: 1),
      AnswerOption(text: "Judge silently and write it in their diary.", score: 0),
    ],
  ),

  // --- nostalgia ---------------------------------------------------------
  Question(
    id: 'nostalgia_1',
    tag: 'nostalgia',
    prompt: "How did you two become friends?",
    options: [
      AnswerOption(text: "Instant click. Inseparable since day one.", score: 3),
      AnswerOption(text: "Slow burn, but it stuck like glitter.", score: 2),
      AnswerOption(text: "Random circumstances. The universe was bored.", score: 1),
      AnswerOption(text: "Honestly still not sure how this happened.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_2',
    tag: 'nostalgia',
    prompt: "What's the oldest inside joke you still use?",
    options: [
      AnswerOption(text: "Years old. Still makes us wheeze on the floor.", score: 3),
      AnswerOption(text: "A classic we bring out on special occasions.", score: 2),
      AnswerOption(text: "There's one, but nobody remembers why it's funny.", score: 1),
      AnswerOption(text: "We have no inside jokes. We're very serious people. (We aren't.)", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_3',
    tag: 'nostalgia',
    prompt: "How often do you bring up old memories together?",
    options: [
      AnswerOption(text: "Constantly. We could write a trilogy.", score: 3),
      AnswerOption(text: "Sometimes, when we get nostalgic.", score: 2),
      AnswerOption(text: "Rarely. We're more 'present moment' people.", score: 1),
      AnswerOption(text: "Almost never. Memory: missing.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_4',
    tag: 'nostalgia',
    prompt: "If your friendship had a highlight reel, how long is it?",
    options: [
      AnswerOption(text: "A feature film, with a sequel and a director's cut.", score: 3),
      AnswerOption(text: "A solid short film.", score: 2),
      AnswerOption(text: "A decent trailer.", score: 1),
      AnswerOption(text: "A blooper reel, mostly.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_5',
    tag: 'nostalgia',
    prompt: "How has this friendship changed over time?",
    options: [
      AnswerOption(text: "Deeper and better, like fancy cheese.", score: 3),
      AnswerOption(text: "Evolved, but still solid.", score: 2),
      AnswerOption(text: "Drifted a bit, but keeps coming back.", score: 1),
      AnswerOption(text: "Faded like a screenshot of a screenshot.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_6',
    tag: 'nostalgia',
    prompt: "If your friendship were a museum exhibit, what would the plaque say?",
    options: [
      AnswerOption(text: "\"Priceless. Do not touch. Do not separate.\"", score: 3),
      AnswerOption(text: "\"Surprisingly sturdy. Some assembly required.\"", score: 2),
      AnswerOption(text: "\"Found in an attic. Smells like memories.\"", score: 1),
      AnswerOption(text: "\"Under restoration since 2019.\"", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_7',
    tag: 'nostalgia',
    prompt: "Can you recall small details of their life (pets, family, snack order)?",
    options: [
      AnswerOption(text: "In detail, unprompted, including the cat's middle name.", score: 3),
      AnswerOption(text: "The big stuff, definitely.", score: 2),
      AnswerOption(text: "Vaguely. I'd need hints.", score: 1),
      AnswerOption(text: "I could name zero. Maybe one pet.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_8',
    tag: 'nostalgia',
    prompt: "How do you introduce them to other people?",
    options: [
      AnswerOption(text: "\"This is basically my sibling (chosen edition).\"", score: 3),
      AnswerOption(text: "\"One of my best friends.\"", score: 2),
      AnswerOption(text: "\"This is my friend.\"", score: 1),
      AnswerOption(text: "\"We know each other.\" (said like a hostage)", score: 0),
    ],
  ),
];
