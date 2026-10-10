import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';
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
  bool _submitting = false;
  bool _prefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_prefilled) return;
    _prefilled = true;
    final user = AppServices.of(context).auth.currentUser;
    if (user != null && _yourNameController.text.isEmpty) {
      final name = user.shortName;
      _yourNameController.text = name.length > 30
          ? name.substring(0, 30)
          : name;
    }
  }

  @override
  void dispose() {
    _yourNameController.dispose();
    _friendNameController.dispose();
    super.dispose();
  }

  void _startQuiz() {
    if (_submitting) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => QuestionScreen(
              yourName: _yourNameController.text.trim(),
              friendName: _friendNameController.text.trim(),
            ),
          ),
        )
        .then((_) {
          // Re-enable the button once the user is back on this screen,
          // whether that's from pressing back mid-quiz or any other route.
          if (mounted) setState(() => _submitting = false);
        });
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Kind of need a name here. Even a nickname. Even "Bestie #3".';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return GradientPage(
      appBar: AppBar(
        title: const Text("Who's on trial? 🔍"),
        actions: const [MuteButton()],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Two names. That's it. We'll handle the drama. 🍿",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              const SizedBox(height: 28),
              TextFormField(
                controller: _yourNameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                decoration: const InputDecoration(labelText: 'Your name'),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _friendNameController,
                textCapitalization: TextCapitalization.words,
                maxLength: 30,
                decoration: const InputDecoration(
                  labelText: "Your friend's name",
                ),
                validator: _requiredValidator,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _submitting ? null : _startQuiz,
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Color(0xFF2B0B4E)),
                        ),
                      )
                    : const Text('Start the quiz 🚀'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
