import 'dart:async';

import 'package:flutter/material.dart';

import '../config.dart';
import '../services/app_services.dart';
import '../services/auth_service.dart';
import '../utils/open_url.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';

const Color _deepPurple = Color(0xFF2B0B4E);

final RegExp _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

/// Sign up / sign in with email + password, or with Google.
///
/// Pops with `true` once the user is signed in — or, when [allowGuest] is
/// set and they tap "skip", once they've chosen to carry on without an
/// account. Popping with null means they backed out.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.allowGuest = true, this.startOnSignUp = true});

  final bool allowGuest;
  final bool startOnSignUp;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late bool _signUp = widget.startOnSignUp;
  bool _obscure = true;

  // Guards against a double tap firing two sign-in requests at once.
  bool _busy = false;

  String? _error;
  String? _info;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _setMode(bool signUp) {
    if (_busy || signUp == _signUp) return;
    setState(() {
      _signUp = signUp;
      _error = null;
      _info = null;
    });
  }

  Future<void> _run(Future<void> Function(AppServices s) action) async {
    if (_busy) return;
    final services = AppServices.of(context);
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await action(services);
      final user = services.auth.currentUser;
      if (user != null) {
        // Best-effort: the profile doc is a nicety, never a blocker.
        unawaited(services.data.ensureProfile(user).catchError((_) {}));
      }
      if (mounted) Navigator.of(context).pop(true);
    } on AuthFailure catch (e) {
      if (mounted && e.kind != AuthFailureKind.cancelled) {
        setState(() => _error = e.message);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Something broke and it was not you. Try again in a moment.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    _run((s) => _signUp
        ? s.auth.signUpWithEmail(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
          )
        : s.auth.signInWithEmail(
            email: _emailController.text,
            password: _passwordController.text,
          ));
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() {
        _error = 'Type your email above first, then tap "Forgot password".';
        _info = null;
      });
      return;
    }
    if (_busy) return;
    final auth = AppServices.of(context).auth;
    setState(() {
      _busy = true;
      _error = null;
      _info = null;
    });
    try {
      await auth.sendPasswordReset(email);
      if (mounted) {
        setState(() => _info = 'Reset link sent 📬 Check your inbox (and spam, because of course).');
      }
    } on AuthFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  String? _validateName(String? v) {
    if (!_signUp) return null;
    if (v == null || v.trim().isEmpty) return 'What do we call you? A nickname works.';
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || !_emailPattern.hasMatch(v.trim())) {
      return "That doesn't look like an email.";
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password needed. Bring your best one.';
    if (_signUp && v.length < 8) return 'At least 8 characters, please.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final onGradient = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white.withValues(alpha: 0.95),
        );

    return GradientPage(
      appBar: AppBar(
        title: Text(_signUp ? 'Hop in 🎉' : 'Hey again 👋'),
        actions: [
          if (widget.allowGuest)
            TextButton(
              onPressed: _busy
                  ? null
                  : () {
                      AppServices.of(context).session.guestChosen = true;
                      Navigator.of(context).pop(true);
                    },
              child: const Text('Skip 🐺'),
            ),
          const MuteButton(),
        ],
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.all(24),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ModeToggle(signUp: _signUp, onChanged: _setMode),
                const SizedBox(height: 18),
                Text(
                  _signUp
                      ? 'Join the chaos. Make an account so your verdicts never get lost. Receipts last forever. 📜'
                      : 'Welcome back, menace. Your past verdicts missed you. (Some of them are dramatic.)',
                  style: onGradient,
                ),
                const SizedBox(height: 18),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _run((s) => s.auth.signInWithGoogle()),
                  icon: Image.asset('assets/images/google_g.png', width: 22, height: 22),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.5))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or use email', style: onGradient),
                    ),
                    Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.5))),
                  ],
                ),
                const SizedBox(height: 16),
                if (_signUp) ...[
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    maxLength: 30,
                    decoration: const InputDecoration(labelText: 'Your name or nickname'),
                    validator: _validateName,
                  ),
                  const SizedBox(height: 6),
                ],
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  autocorrect: false,
                  enableSuggestions: false,
                  textInputAction: TextInputAction.done,
                  autofillHints: [
                    _signUp ? AutofillHints.newPassword : AutofillHints.password,
                  ],
                  onFieldSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      tooltip: _obscure ? 'Show password' : 'Hide password',
                      icon: Icon(_obscure
                          ? Icons.visibility_rounded
                          : Icons.visibility_off_rounded),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: _validatePassword,
                ),
                if (!_signUp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _busy ? null : _forgotPassword,
                      child: const Text('Forgot password?'),
                    ),
                  ),
                if (_error != null) _Banner(text: _error!, isError: true),
                if (_info != null) _Banner(text: _info!, isError: false),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _busy ? null : _submit,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(_deepPurple),
                          ),
                        )
                      : Text(_signUp ? 'Create my account 🚀' : 'Let me in 🔓'),
                ),
                const SizedBox(height: 10),
                _FinePrint(onGradient: onGradient),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.signUp, required this.onChanged});

  final bool signUp;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget segment(String label, bool value) {
      final selected = signUp == value;
      return Expanded(
        child: Semantics(
          button: true,
          selected: selected,
          label: label,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => onChanged(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: selected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: ExcludeSemantics(
                child: Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: selected ? _deepPurple : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(children: [segment('Sign up', true), segment('Sign in', false)]),
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.text, required this.isError});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isError ? const Color(0xCCB0003A) : const Color(0xCC1B7F4B),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _FinePrint extends StatelessWidget {
  const _FinePrint({required this.onGradient});

  final TextStyle? onGradient;

  @override
  Widget build(BuildContext context) {
    final small = onGradient?.copyWith(fontSize: 12);
    final link = small?.copyWith(
      decoration: TextDecoration.underline,
      fontWeight: FontWeight.w700,
    );
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('By continuing you agree to our ', style: small),
        GestureDetector(
          onTap: () => openUrl(context, termsUrl),
          child: Text('Terms', style: link),
        ),
        Text(' and ', style: small),
        GestureDetector(
          onTap: () => openUrl(context, privacyUrl),
          child: Text('Privacy Policy', style: link),
        ),
        Text('.', style: small),
      ],
    );
  }
}
