import 'package:flutter/material.dart';

import 'names_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('🕵️', style: TextStyle(fontSize: 88)),
              const SizedBox(height: 20),
              Text(
                'The Friendship\nPolygraph',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'Nobody lies to a polygraph.',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 12),
              Text(
                'Answer some brutally honest questions about your '
                'friendship. Then send it to them and see if their '
                'story matches yours.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 36),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NamesScreen()),
                  );
                },
                child: const Text('Start the interrogation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
