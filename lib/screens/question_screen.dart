import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/scoring.dart';
import '../widgets/gradient_page.dart';
import 'result_screen.dart';

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
  }

  void _choose(int score) {
    if (_locked) return;
    _locked = true;

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
    final progress = currentIndex / _questions.length;

    return GradientPage(
      appBar: AppBar(
        title: Text('Question ${currentIndex + 1} of ${_questions.length} 🕵️'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              question.prompt,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 28),
            Expanded(
              child: ListView.separated(
                itemCount: question.options.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) {
                  final option = question.options[i];
                  return OutlinedButton(
                    onPressed: () => _choose(option.score),
                    style: OutlinedButton.styleFrom(
                      alignment: Alignment.centerLeft,
                    ),
                    child: Text(option.text),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
