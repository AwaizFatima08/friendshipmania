import '../models/question.dart';

/// The full question bank for The Friendship Polygraph.
///
/// Every quiz run randomly samples 10 of these, mixed across tags, so
/// back-to-back runs rarely feel identical. Keep this list append-only
/// when adding more questions later — nothing else in the app needs to
/// change to grow the bank.
const List<Question> questionBank = [
  // --- roast ---------------------------------------------------------
  Question(
    id: 'roast_1',
    tag: 'roast',
    prompt: "How would they describe you to a stranger?",
    options: [
      AnswerOption(text: "Honestly? Kind of a legend.", score: 3),
      AnswerOption(text: "Complicated, but in a good way.", score: 2),
      AnswerOption(text: "Let's just say... memorable.", score: 1),
      AnswerOption(text: "They'd probably just show a screenshot.", score: 0),
    ],
  ),
  Question(
    id: 'roast_2',
    tag: 'roast',
    prompt: "What's their honest reaction when your name pops up on their phone?",
    options: [
      AnswerOption(text: "Instant smile, answers on the first ring.", score: 3),
      AnswerOption(text: "Sighs, then answers anyway.", score: 2),
      AnswerOption(text: "Lets it go to voicemail first, on principle.", score: 1),
      AnswerOption(text: "Declines and texts 'can't talk, driving.'", score: 0),
    ],
  ),
  Question(
    id: 'roast_3',
    tag: 'roast',
    prompt: "If your friendship were a Yelp review, how many stars?",
    options: [
      AnswerOption(text: "5 stars, would recommend to everyone.", score: 3),
      AnswerOption(text: "4 stars, minus one for the group chat spam.", score: 2),
      AnswerOption(text: "2 stars, chaotic but occasionally charming.", score: 1),
      AnswerOption(text: "1 star, this friendship needs a manager.", score: 0),
    ],
  ),
  Question(
    id: 'roast_4',
    tag: 'roast',
    prompt: "Pick the most accurate loving insult they've thrown at you.",
    options: [
      AnswerOption(text: "\"You're an idiot, but you're MY idiot.\"", score: 3),
      AnswerOption(text: "\"I can't believe I still hang out with you.\"", score: 2),
      AnswerOption(text: "\"You're a lot.\"", score: 1),
      AnswerOption(text: "\"I'm calling my lawyer.\"", score: 0),
    ],
  ),
  Question(
    id: 'roast_5',
    tag: 'roast',
    prompt: "How does your friend react to your terrible ideas?",
    options: [
      AnswerOption(text: "Says 'let's do it' before you finish talking.", score: 3),
      AnswerOption(text: "Rolls their eyes, then helps anyway.", score: 2),
      AnswerOption(text: "Sends a long voice note about your life choices.", score: 1),
      AnswerOption(text: "Leaves you on read.", score: 0),
    ],
  ),
  Question(
    id: 'roast_6',
    tag: 'roast',
    prompt: "What would they say is your most annoying habit?",
    options: [
      AnswerOption(text: "Nothing, I'm perfect and they know it.", score: 3),
      AnswerOption(text: "Something small, said with a laugh.", score: 2),
      AnswerOption(text: "They have a whole PowerPoint about it.", score: 1),
      AnswerOption(text: "They've brought it up in therapy. Theirs.", score: 0),
    ],
  ),
  Question(
    id: 'roast_7',
    tag: 'roast',
    prompt: "If you canceled plans last minute, what actually happens?",
    options: [
      AnswerOption(text: "\"No worries, love you, bye.\"", score: 3),
      AnswerOption(text: "A little sass, then it's fine.", score: 2),
      AnswerOption(text: "A passive-aggressive thumbs up emoji.", score: 1),
      AnswerOption(text: "You get uninvited from the next 3 things.", score: 0),
    ],
  ),
  Question(
    id: 'roast_8',
    tag: 'roast',
    prompt: "Be honest: how fast do you actually reply to their texts?",
    options: [
      AnswerOption(text: "Basically instantly, always.", score: 3),
      AnswerOption(text: "Within a day, respectable.", score: 2),
      AnswerOption(text: "'Seen' at 2am, replied three days later.", score: 1),
      AnswerOption(text: "What texts?", score: 0),
    ],
  ),

  // --- loyalty ---------------------------------------------------------
  Question(
    id: 'loyalty_1',
    tag: 'loyalty',
    prompt: "Your friend is in a fight with someone. What do you do?",
    options: [
      AnswerOption(text: "Show up, ask zero questions, pick a side.", score: 3),
      AnswerOption(text: "Hear them out, then pick their side anyway.", score: 2),
      AnswerOption(text: "Suggest they 'talk it out' like a coward.", score: 1),
      AnswerOption(text: "Ask if you can stay neutral for the group chat.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_2',
    tag: 'loyalty',
    prompt: "It's 3am and they need a ride. What happens?",
    options: [
      AnswerOption(text: "Already in the car, keys in hand.", score: 3),
      AnswerOption(text: "Groan, then show up anyway.", score: 2),
      AnswerOption(text: "Send them an Uber code instead.", score: 1),
      AnswerOption(text: "Turn phone to airplane mode.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_3',
    tag: 'loyalty',
    prompt: "They tell you a huge secret. What's the shelf life?",
    options: [
      AnswerOption(text: "Goes to the grave with me.", score: 3),
      AnswerOption(text: "Safe, unless truly necessary (rare).", score: 2),
      AnswerOption(text: "Might slip out after two drinks.", score: 1),
      AnswerOption(text: "Already told three people by dinner.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_4',
    tag: 'loyalty',
    prompt: "You see their ex/rival talking trash about them. Your move?",
    options: [
      AnswerOption(text: "Defend them without even checking the facts.", score: 3),
      AnswerOption(text: "Get the facts, then defend them.", score: 2),
      AnswerOption(text: "Watch it happen and report back later.", score: 1),
      AnswerOption(text: "Add a comment of your own, honestly.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_5',
    tag: 'loyalty',
    prompt: "They need help moving apartments. You...?",
    options: [
      AnswerOption(text: "Show up with snacks and a truck, no questions.", score: 3),
      AnswerOption(text: "Show up, but mention it every time after.", score: 2),
      AnswerOption(text: "Offer moral support via text.", score: 1),
      AnswerOption(text: "Suddenly very busy that weekend.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_6',
    tag: 'loyalty',
    prompt: "If they forgot your birthday, what would actually happen?",
    options: [
      AnswerOption(text: "Wouldn't happen, they've never forgotten.", score: 3),
      AnswerOption(text: "They'd feel awful and make it up big time.", score: 2),
      AnswerOption(text: "Mild chaos, quickly forgiven.", score: 1),
      AnswerOption(text: "This has happened. More than once.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_7',
    tag: 'loyalty',
    prompt: "Would they lie to the police for you (nothing illegal, just dramatic effect)?",
    options: [
      AnswerOption(text: "Without blinking.", score: 3),
      AnswerOption(text: "After a long pause and a sigh.", score: 2),
      AnswerOption(text: "\"I plead the fifth.\"", score: 1),
      AnswerOption(text: "They'd probably testify against you.", score: 0),
    ],
  ),
  Question(
    id: 'loyalty_8',
    tag: 'loyalty',
    prompt: "If you needed money in an emergency, what happens?",
    options: [
      AnswerOption(text: "Sent before you finish asking.", score: 3),
      AnswerOption(text: "Sent, with a gentle joke about paying it back.", score: 2),
      AnswerOption(text: "A very detailed repayment plan first.", score: 1),
      AnswerOption(text: "\"Have you tried a bank?\"", score: 0),
    ],
  ),

  // --- chaos ---------------------------------------------------------
  Question(
    id: 'chaos_1',
    tag: 'chaos',
    prompt: "Worst idea you've both agreed to at 1am?",
    options: [
      AnswerOption(text: "Something unhinged, and we'd do it again.", score: 3),
      AnswerOption(text: "Mildly regrettable, but a great story now.", score: 2),
      AnswerOption(text: "We talked ourselves out of it, thankfully.", score: 1),
      AnswerOption(text: "We don't do spontaneous. We do spreadsheets.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_2',
    tag: 'chaos',
    prompt: "How does a road trip with this friend usually go?",
    options: [
      AnswerOption(text: "Chaotic, hilarious, unforgettable.", score: 3),
      AnswerOption(text: "Good, with one dramatic argument over snacks.", score: 2),
      AnswerOption(text: "Tense, someone always messes up navigation.", score: 1),
      AnswerOption(text: "We've never risked it, honestly.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_3',
    tag: 'chaos',
    prompt: "You both get lost somewhere with no signal. Vibe check?",
    options: [
      AnswerOption(text: "Turns into the best part of the trip.", score: 3),
      AnswerOption(text: "Panic, then laughter, then a great story.", score: 2),
      AnswerOption(text: "One of us blames the other immediately.", score: 1),
      AnswerOption(text: "Complete meltdown, friendship-ending levels.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_4',
    tag: 'chaos',
    prompt: "Karaoke night. What actually happens?",
    options: [
      AnswerOption(text: "We own that stage like it's a concert.", score: 3),
      AnswerOption(text: "One song, then we chicken out.", score: 2),
      AnswerOption(text: "We watch from the bar, judging everyone.", score: 1),
      AnswerOption(text: "We'd never be caught near a karaoke bar.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_5',
    tag: 'chaos',
    prompt: "If one of you got a terrible tattoo idea at midnight...?",
    options: [
      AnswerOption(text: "The other is already looking up shops.", score: 3),
      AnswerOption(text: "Talks it over, still ends up happening.", score: 2),
      AnswerOption(text: "Successfully talks them out of it.", score: 1),
      AnswerOption(text: "Immediately calls their mother.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_6',
    tag: 'chaos',
    prompt: "Describe your group chat energy.",
    options: [
      AnswerOption(text: "Unhinged, 400 messages a day, mostly memes.", score: 3),
      AnswerOption(text: "Active, mostly logistics with chaos bursts.", score: 2),
      AnswerOption(text: "Quiet, mostly birthday reminders.", score: 1),
      AnswerOption(text: "What group chat?", score: 0),
    ],
  ),
  Question(
    id: 'chaos_7',
    tag: 'chaos',
    prompt: "You both try a questionable food trend together. Outcome?",
    options: [
      AnswerOption(text: "10/10 no regrets, doing it again.", score: 3),
      AnswerOption(text: "Regret it slightly, still laugh about it.", score: 2),
      AnswerOption(text: "One of us definitely got sick.", score: 1),
      AnswerOption(text: "We stuck to menus we already knew, like adults.", score: 0),
    ],
  ),
  Question(
    id: 'chaos_8',
    tag: 'chaos',
    prompt: "Pick the sentence that starts your typical adventures.",
    options: [
      AnswerOption(text: "\"Okay hear me out...\"", score: 3),
      AnswerOption(text: "\"This is probably a bad idea, but...\"", score: 2),
      AnswerOption(text: "\"Are you sure about this?\"", score: 1),
      AnswerOption(text: "\"Let's just stay in.\"", score: 0),
    ],
  ),

  // --- receipts (honesty) ---------------------------------------------
  Question(
    id: 'receipts_1',
    tag: 'receipts',
    prompt: "Have they ever said something that genuinely hurt your feelings?",
    options: [
      AnswerOption(text: "Once, and they apologized before I even said anything.", score: 3),
      AnswerOption(text: "A couple times, we talked it out like adults.", score: 2),
      AnswerOption(text: "Yeah, and it's still a little sore.", score: 1),
      AnswerOption(text: "Regularly, and we just don't talk about it.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_2',
    tag: 'receipts',
    prompt: "How honest are they when your outfit/idea/plan is bad?",
    options: [
      AnswerOption(text: "Brutally, lovingly, immediately.", score: 3),
      AnswerOption(text: "Gently hints at it.", score: 2),
      AnswerOption(text: "Lets you find out the hard way.", score: 1),
      AnswerOption(text: "Tells everyone else first.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_3',
    tag: 'receipts',
    prompt: "Do they actually listen when you're venting, or just wait to talk?",
    options: [
      AnswerOption(text: "Full therapist mode, phone away, eye contact.", score: 3),
      AnswerOption(text: "Mostly listens, occasionally distracted.", score: 2),
      AnswerOption(text: "Nods a lot, clearly thinking about lunch.", score: 1),
      AnswerOption(text: "Turns every story into one about them.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_4',
    tag: 'receipts',
    prompt: "When you succeed at something, what's their real reaction?",
    options: [
      AnswerOption(text: "Genuinely thrilled, tells everyone they know.", score: 3),
      AnswerOption(text: "Happy for you, a little competitive underneath.", score: 2),
      AnswerOption(text: "Congratulates you, changes the subject fast.", score: 1),
      AnswerOption(text: "A suspiciously quiet \"nice.\"", score: 0),
    ],
  ),
  Question(
    id: 'receipts_5',
    tag: 'receipts',
    prompt: "If you needed brutal, unfiltered advice, would they give it?",
    options: [
      AnswerOption(text: "Immediately, no sugarcoating.", score: 3),
      AnswerOption(text: "Yes, wrapped in at least one joke.", score: 2),
      AnswerOption(text: "Eventually, after a lot of 'well, maybe...'", score: 1),
      AnswerOption(text: "They'd just agree with whatever you already think.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_6',
    tag: 'receipts',
    prompt: "How do apologies go between you two?",
    options: [
      AnswerOption(text: "Quick, sincere, back to normal in minutes.", score: 3),
      AnswerOption(text: "A little awkward, but it happens.", score: 2),
      AnswerOption(text: "Long silence first, then eventually fine.", score: 1),
      AnswerOption(text: "Apologies? We just pretend it didn't happen.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_7',
    tag: 'receipts',
    prompt: "Would they tell you if your partner was bad news?",
    options: [
      AnswerOption(text: "Immediately, receipts included.", score: 3),
      AnswerOption(text: "Eventually, after trying to like them first.", score: 2),
      AnswerOption(text: "Drops hints and hopes you notice.", score: 1),
      AnswerOption(text: "Smiles and says nothing, forever.", score: 0),
    ],
  ),
  Question(
    id: 'receipts_8',
    tag: 'receipts',
    prompt: "How do they handle it when you're wrong about something?",
    options: [
      AnswerOption(text: "Tells you straight, no drama.", score: 3),
      AnswerOption(text: "Lets you figure it out gently.", score: 2),
      AnswerOption(text: "Brings it up again in six months.", score: 1),
      AnswerOption(text: "Never says anything, just judges quietly.", score: 0),
    ],
  ),

  // --- nostalgia ---------------------------------------------------------
  Question(
    id: 'nostalgia_1',
    tag: 'nostalgia',
    prompt: "How did you two actually become friends?",
    options: [
      AnswerOption(text: "Instant connection, inseparable since day one.", score: 3),
      AnswerOption(text: "Slow burn, but it stuck.", score: 2),
      AnswerOption(text: "Random circumstance, somehow it worked.", score: 1),
      AnswerOption(text: "Honestly still not sure how this happened.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_2',
    tag: 'nostalgia',
    prompt: "What's the oldest inside joke you still use?",
    options: [
      AnswerOption(text: "One from years ago, still gets us crying-laughing.", score: 3),
      AnswerOption(text: "A solid classic, brought out occasionally.", score: 2),
      AnswerOption(text: "There's one, but neither of us remembers the origin.", score: 1),
      AnswerOption(text: "We don't really have inside jokes.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_3',
    tag: 'nostalgia',
    prompt: "How often do you bring up old memories together?",
    options: [
      AnswerOption(text: "All the time, we could write a book.", score: 3),
      AnswerOption(text: "Sometimes, usually when reminiscing.", score: 2),
      AnswerOption(text: "Rarely, we're more present-focused.", score: 1),
      AnswerOption(text: "Almost never, weirdly.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_4',
    tag: 'nostalgia',
    prompt: "If your friendship had a highlight reel, how long would it be?",
    options: [
      AnswerOption(text: "Feature film length, easily.", score: 3),
      AnswerOption(text: "A solid, satisfying short film.", score: 2),
      AnswerOption(text: "A decent trailer.", score: 1),
      AnswerOption(text: "A blooper reel, mostly.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_5',
    tag: 'nostalgia',
    prompt: "How has this friendship changed over the years?",
    options: [
      AnswerOption(text: "Gotten deeper and better with time.", score: 3),
      AnswerOption(text: "Evolved, still solid.", score: 2),
      AnswerOption(text: "Drifted a bit, but comes back around.", score: 1),
      AnswerOption(text: "Honestly kind of faded.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_6',
    tag: 'nostalgia',
    prompt: "Would past-you be surprised you're still friends now?",
    options: [
      AnswerOption(text: "Not at all, this was always inevitable.", score: 3),
      AnswerOption(text: "A little, in a good way.", score: 2),
      AnswerOption(text: "Very surprised, it's been a wild ride.", score: 1),
      AnswerOption(text: "Past me would ask what happened.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_7',
    tag: 'nostalgia',
    prompt: "Do you remember small details of their life (family, pets, etc.)?",
    options: [
      AnswerOption(text: "In detail, unprompted.", score: 3),
      AnswerOption(text: "The big ones, for sure.", score: 2),
      AnswerOption(text: "Vaguely, I'd need reminders.", score: 1),
      AnswerOption(text: "I could not name a single one.", score: 0),
    ],
  ),
  Question(
    id: 'nostalgia_8',
    tag: 'nostalgia',
    prompt: "How do you introduce this person to others?",
    options: [
      AnswerOption(text: "\"This is basically my sibling.\"", score: 3),
      AnswerOption(text: "\"This is one of my best friends.\"", score: 2),
      AnswerOption(text: "\"This is my friend [name].\"", score: 1),
      AnswerOption(text: "\"We know each other.\"", score: 0),
    ],
  ),
];
