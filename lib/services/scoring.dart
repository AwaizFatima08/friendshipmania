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
  final String title;
  final String subtitle;

  const ScoreBand({
    required this.minPercent,
    required this.maxPercent,
    required this.emoji,
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
    emoji: '🧊',
    title: 'Certified Frenemies',
    subtitle: "Your answers read like a hostage statement. Somebody needs a talk.",
  ),
  ScoreBand(
    minPercent: 21,
    maxPercent: 40,
    emoji: '🤨',
    title: 'Friendship, Allegedly',
    subtitle: "It's giving 'we follow each other on Instagram.' Room to grow.",
  ),
  ScoreBand(
    minPercent: 41,
    maxPercent: 60,
    emoji: '🍿',
    title: 'Solid Acquaintance, Occasional Friend',
    subtitle: "Reliable, mostly drama-free, definitely invited to the group hangout.",
  ),
  ScoreBand(
    minPercent: 61,
    maxPercent: 80,
    emoji: '🔥',
    title: 'Actual Real Friends',
    subtitle: "This is a genuine, load-bearing friendship. Respect.",
  ),
  ScoreBand(
    minPercent: 81,
    maxPercent: 100,
    emoji: '👑',
    title: 'Ride-or-Die, No Notes',
    subtitle: "Certified soulmates. Send this scorecard before they forget how lucky they are.",
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
