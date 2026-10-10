import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/app_services.dart';
import '../services/audio_service.dart';
import '../services/scoring.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';
import 'result_screen.dart';

/// One-liners shown above each question, so ten questions in a row feel
/// like a conversation rather than a form.
const List<String> _quips = [
  'Warm-up round 🔥',
  'Easy one. Probably.',
  'Getting warmer 🌡️',
  'No lying to the polygraph.',
  'Halfway! Your pulse is fine. Allegedly.',
  'The lie detector is sweating.',
  'Plot twist incoming…',
  'Almost there, bestie.',
  'Penultimate chaos.',
  'Final question. Breathe. 🙏',
];

class QuestionScreen extends StatefulWidget {
  final String yourName;
  final String friendName;

  const QuestionScreen({
    super.key,
    required this.yourName,
    required this.friendName,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  late final List<Question> _questions;

  // Answers are shuffled once per question (not on every rebuild) so the
  // best-friendship answer isn't always sitting in the same spot.
  late final List<List<AnswerOption>> _shuffledOptions;

  final List<int> _chosenScores = [];

  // Guards against a fast double-tap on an answer button firing _choose()
  // twice before the rebuild lands — without this, two taps on the same
  // option could double-add a score or fire the last-question navigation
  // twice in a row.
  bool _locked = false;

  @override
  void initState() {
    super.initState();
    _questions = pickRandomQuestions(questionsPerRun);
    _shuffledOptions = [
      for (final q in _questions) (List<AnswerOption>.of(q.options)..shuffle()),
    ];
  }

  void _choose(int score) {
    if (_locked) return;
    _locked = true;

    AppServices.of(context).audio.playSfx(Sfx.answer);

    final updated = [..._chosenScores, score];

    if (updated.length == _questions.length) {
      // Last question: go straight to the result screen without another
      // rebuild of this screen — there's no question left at this index.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ResultScreen(
            yourName: widget.yourName,
            friendName: widget.friendName,
            questions: _questions,
            chosenScores: updated,
          ),
        ),
      );
    } else {
      setState(() {
        _chosenScores.add(score);
        _locked = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _chosenScores.length;
    final question = _questions[currentIndex];
    final options = _shuffledOptions[currentIndex];
    final progress = currentIndex / _questions.length;

    return GradientPage(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1} of ${_questions.length} 🕵️'),
        actions: const [MuteButton()],
      ),
      // The whole page scrolls as one, so large-text and small screens can
      // always reach every answer instead of squeezing them into a tiny list.
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(value: progress, minHeight: 10),
          ),
          const SizedBox(height: 14),
          Text(
            _quips[currentIndex % _quips.length],
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: OutlinedButton(
                onPressed: () => _choose(option.score),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                ),
                child: Text(option.text),
              ),
            ),
        ],
      ),
    );
  }
}
