import 'dart:math';

import '../data/question_bank.dart';
import '../models/question.dart';

/// How many questions make up one quiz run. Change this in one place if
/// that ever needs to move.
const int questionsPerRun = 10;

/// Picks [count] random questions from the full bank, mixed across tags,
/// so back-to-back runs feel different. Call this once per quiz run and
/// keep the result — don't re-roll mid-quiz.
List<Question> pickRandomQuestions(int count) {
  final pool = List<Question>.from(questionBank)..shuffle(Random());
  return pool.take(count).toList();
}

/// One funny result band for the solo scorecard.
class ScoreBand {
  final int minPercent;
  final int maxPercent;
  final String emoji;

  /// Sticker art for the scorecard (asset path). [emoji] stays as the
  /// lightweight fallback and is what gets saved in a user's history.
  final String sticker;
  final String title;
  final String subtitle;

  const ScoreBand({
    required this.minPercent,
    required this.maxPercent,
    required this.emoji,
    required this.sticker,
    required this.title,
    required this.subtitle,
  });

  bool matches(int percent) => percent >= minPercent && percent <= maxPercent;
}

/// Bands for a *solo* result — this is one person's own read on the
/// friendship, before the other friend has answered anything. Sharper,
/// roast-y tone, on purpose.
const List<ScoreBand> soloScoreBands = [
  ScoreBand(
    minPercent: 0,
    maxPercent: 20,
    emoji: '❄️',
    sticker: 'assets/images/20261010-1125-friendshipmania-icon-02_cutout.png',
    title: 'Frenemies With Wi-Fi',
    subtitle:
        "Your answers read like a hostage note. Someone's contacts list needs a glow-up.",
  ),
  ScoreBand(
    minPercent: 21,
    maxPercent: 40,
    emoji: '🤔',
    sticker: 'assets/images/20261010-1125-friendshipmania-icon-03_cutout.png',
    title: 'Friendship, Allegedly',
    subtitle:
        "It's giving 'we follow each other and that's it.' Lawyers are still checking.",
  ),
  ScoreBand(
    minPercent: 41,
    maxPercent: 60,
    emoji: '🍿',
    sticker: 'assets/images/20261010-1126-friendshipmania-icon-01_cutout.png',
    title: 'Side-Quest Besties',
    subtitle:
        "Fun, mostly drama-free, invited to the hangout but not the group trip.",
  ),
  ScoreBand(
    minPercent: 61,
    maxPercent: 80,
    emoji: '🔥',
    sticker: 'assets/images/20261010-1127-friendshipmania-icon-01_cutout.png',
    title: 'Actual Real Friends, No Cap',
    subtitle: "Genuine, load-bearing friendship. Your aura just levelled up.",
  ),
  ScoreBand(
    minPercent: 81,
    maxPercent: 100,
    emoji: '👑',
    sticker: 'assets/images/20261010-1127-friendshipmania-icon-02_cutout.png',
    title: 'Ride-or-Die Main Characters',
    subtitle:
        "Certified soulmates. Send this before they realise how lucky they are. (They already know.)",
  ),
];

/// Turns a list of chosen answer scores into a 0-100 percentage, using
/// each question's own maximum so the math stays fair regardless of how
/// many questions were asked.
int scoreToPercent(List<Question> questions, List<int> chosenScores) {
  assert(questions.length == chosenScores.length);
  if (questions.isEmpty) return 0;

  final earned = chosenScores.fold<int>(0, (sum, s) => sum + s);
  final possible = questions.fold<int>(0, (sum, q) => sum + q.maxScore);
  if (possible == 0) return 0;

  return ((earned / possible) * 100).round();
}

ScoreBand bandForPercent(int percent) {
  return soloScoreBands.firstWhere(
    (b) => b.matches(percent),
    orElse: () => soloScoreBands.last,
  );
}

/// One line of the report's category breakdown: how this run scored on
/// a single question tag (e.g. "loyalty", "chaos"), plus a friendly label
/// for that tag so the UI never has to show raw ids.
class TagScore {
  final String tag;
  final String label;
  final int percent;

  const TagScore({
    required this.tag,
    required this.label,
    required this.percent,
  });
}

const Map<String, String> _tagLabels = {
  'roast': '🔥 Roast Resilience',
  'loyalty': '🛡️ Ride-or-Die Index',
  'chaos': '🎢 Chaos Compatibility',
  'receipts': '📝 Brutal Honesty',
  'nostalgia': '📼 Lore Together',
};

/// Breaks a quiz run down by question tag, so the report can show more than
/// one number — only tags that actually appeared in this run are included,
/// since a 10-question sample from a 5-tag bank won't always hit all five.
List<TagScore> tagBreakdown(List<Question> questions, List<int> chosenScores) {
  assert(questions.length == chosenScores.length);

  final earnedByTag = <String, int>{};
  final possibleByTag = <String, int>{};

  for (var i = 0; i < questions.length; i++) {
    final tag = questions[i].tag;
    earnedByTag[tag] = (earnedByTag[tag] ?? 0) + chosenScores[i];
    possibleByTag[tag] = (possibleByTag[tag] ?? 0) + questions[i].maxScore;
  }

  final result = <TagScore>[];
  for (final tag in earnedByTag.keys) {
    final possible = possibleByTag[tag] ?? 0;
    final percent = possible == 0
        ? 0
        : ((earnedByTag[tag]! / possible) * 100).round();
    result.add(
      TagScore(tag: tag, label: _tagLabels[tag] ?? tag, percent: percent),
    );
  }

  result.sort((a, b) => b.percent.compareTo(a.percent));
  return result;
}
