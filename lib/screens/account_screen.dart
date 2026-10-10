import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/auth_service.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';
import 'about_screen.dart';
import 'history_screen.dart';

const Color _danger = Color(0xFFB0003A);

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _signOut() async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await AppServices.of(context).auth.signOut();
      if (mounted) Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (_) {
      _snack("Couldn't sign out. Try again?");
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _deleteAccount(AppUser user) async {
    if (_busy) return;
    final services = AppServices.of(context);

    final confirmed = await showDialog<_DeleteConfirmation>(
      context: context,
      builder: (_) => _DeleteDialog(needsPassword: user.usesPassword),
    );
    if (confirmed == null || !mounted) return;

    setState(() => _busy = true);
    try {
      // Verify identity FIRST: a mistyped password must never be able to
      // leave someone with an account but no data.
      await services.auth.reauthenticate(password: confirmed.password);
      await services.data.deleteAllUserData(user.uid);
      await services.auth.deleteAccount();
      if (mounted) {
        Navigator.of(context).popUntil((r) => r.isFirst);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account deleted. We never knew you. 👋')),
        );
      }
    } on AuthFailure catch (e) {
      if (e.kind != AuthFailureKind.cancelled) _snack(e.message);
      if (mounted) setState(() => _busy = false);
    } catch (_) {
      _snack("Couldn't delete the account right now. Check your connection and try again.");
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = AppServices.of(context);

    return GradientPage(
      appBar: AppBar(
        title: const Text('My account 😎'),
        actions: const [MuteButton()],
      ),
      body: StreamBuilder<AppUser?>(
        stream: services.auth.authChanges(),
        initialData: services.auth.currentUser,
        builder: (context, snapshot) {
          final user = snapshot.data;
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Text(
                    user.shortName.characters.first.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF5636C4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  user.shortName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ),
              if (user.email != null)
                Center(
                  child: Text(
                    user.email!,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.9)),
                  ),
                ),
              const SizedBox(height: 28),
              _Tile(
                icon: Icons.history_rounded,
                label: 'My verdicts',
                onTap: _busy
                    ? null
                    : () => Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => HistoryScreen(uid: user.uid),
                        )),
              ),
              _Tile(
                icon: Icons.info_rounded,
                label: 'About & credits',
                onTap: _busy
                    ? null
                    : () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AboutScreen()),
                        ),
              ),
              _Tile(
                icon: Icons.logout_rounded,
                label: 'Sign out',
                onTap: _busy ? null : _signOut,
              ),
              _Tile(
                icon: Icons.delete_forever_rounded,
                label: 'Delete account & data',
                color: _danger,
                onTap: _busy ? null : () => _deleteAccount(user),
              ),
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.icon, required this.label, required this.onTap, this.color});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? const Color(0xFF2B0B4E);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        color: Colors.white,
        child: ListTile(
          leading: Icon(icon, color: color ?? const Color(0xFF5636C4)),
          title: Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: c)),
          trailing: const Icon(Icons.chevron_right_rounded),
          enabled: onTap != null,
          onTap: onTap,
        ),
      ),
    );
  }
}

class _DeleteConfirmation {
  const _DeleteConfirmation(this.password);
  final String? password;
}

class _DeleteDialog extends StatefulWidget {
  const _DeleteDialog({required this.needsPassword});

  final bool needsPassword;

  @override
  State<_DeleteDialog> createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<_DeleteDialog> {
  final _password = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete your account? 💀'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This permanently deletes your account and every saved verdict. '
            "No take-backs, no undo, no 'just kidding'.",
          ),
          if (widget.needsPassword) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: InputDecoration(
                labelText: 'Confirm your password',
                errorText: _error,
                border: const OutlineInputBorder(),
              ),
            ),
          ] else ...[
            const SizedBox(height: 12),
            const Text("You'll be asked to confirm with Google next."),
          ],
        ],
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Keep my account'),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: _danger),
          onPressed: () {
            if (widget.needsPassword && _password.text.isEmpty) {
              setState(() => _error = 'Enter your password to confirm.');
              return;
            }
            Navigator.of(context).pop(
              _DeleteConfirmation(widget.needsPassword ? _password.text : null),
            );
          },
          child: const Text('Delete forever'),
        ),
      ],
    );
  }
}
