import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/scoring.dart';
import '../widgets/friendship_meter.dart';
import 'welcome_screen.dart';

class ResultScreen extends StatelessWidget {
  final String yourName;
  final String friendName;
  final List<Question> questions;
  final List<int> chosenScores;

  const ResultScreen({
    super.key,
    required this.yourName,
    required this.friendName,
    required this.questions,
    required this.chosenScores,
  });

  @override
  Widget build(BuildContext context) {
    final percent = scoreToPercent(questions, chosenScores);
    final band = bandForPercent(percent);

    return Scaffold(
      appBar: AppBar(title: const Text('Your verdict')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(
                        children: [
                          Text(
                            '$yourName on $friendName',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          FriendshipMeter(percent: percent, emoji: band.emoji),
                          const SizedBox(height: 20),
                          Text(
                            band.title,
                            style: Theme.of(context).textTheme.headlineMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            band.subtitle,
                            style: Theme.of(context).textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Sharing this with $friendName and inviting them '
                        'to answer back is coming in the next build stage.',
                      ),
                    ),
                  );
                },
                child: Text('Share with $friendName (coming soon)'),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Play again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
