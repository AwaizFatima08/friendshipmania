import 'package:flutter/material.dart';

import 'question_screen.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});

  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

class _NamesScreenState extends State<NamesScreen> {
  final _formKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  final _friendNameController = TextEditingController();

  @override
  void dispose() {
    _yourNameController.dispose();
    _friendNameController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuestionScreen(
          yourName: _yourNameController.text.trim(),
          friendName: _friendNameController.text.trim(),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kind of need a name here.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Who are we interrogating?')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'No login, no email, no nonsense. Just two names.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 28),
                TextFormField(
                  controller: _yourNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Your name'),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _friendNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration:
                      const InputDecoration(labelText: "Your friend's name"),
                  validator: _requiredValidator,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startQuiz,
                  child: const Text('Start the quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
