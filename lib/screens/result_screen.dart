import 'dart:async';

import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/ads_service.dart';
import '../services/app_services.dart';
import '../services/audio_service.dart';
import '../services/report_service.dart';
import '../services/scoring.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';
import '../widgets/report_card.dart';
import 'auth_screen.dart';
import 'welcome_screen.dart';

enum _SaveState { guest, saving, saved, failed }

class ResultScreen extends StatefulWidget {
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
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final GlobalKey _reportKey = GlobalKey();
  bool _busy = false;
  bool _didInit = false;
  _SaveState _saveState = _SaveState.guest;

  late final int _percent = scoreToPercent(
    widget.questions,
    widget.chosenScores,
  );
  late final ScoreBand _band = bandForPercent(_percent);
  late final List<TagScore> _breakdown = tagBreakdown(
    widget.questions,
    widget.chosenScores,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_didInit) return;
    _didInit = true;
    final services = AppServices.of(context);
    services.audio.playSfx(Sfx.reveal);
    _saveToHistory(initial: true);
  }

  /// Saves this verdict to the signed-in user's history. The write is
  /// queued by Firestore even when offline, so we never block the UI on it.
  void _saveToHistory({bool initial = false}) {
    final services = AppServices.of(context);
    final user = services.auth.currentUser;
    if (user == null) {
      _saveState = _SaveState.guest;
      return;
    }

    if (initial) {
      _saveState = _SaveState.saving;
    } else {
      setState(() => _saveState = _SaveState.saving);
    }

    unawaited(
      services.data
          .saveReport(
            uid: user.uid,
            yourName: widget.yourName,
            friendName: widget.friendName,
            percent: _percent,
            bandTitle: _band.title,
            bandEmoji: _band.emoji,
            tagPercents: {for (final t in _breakdown) t.tag: t.percent},
          )
          .then((_) {
            if (mounted) setState(() => _saveState = _SaveState.saved);
          })
          .catchError((Object _) {
            if (mounted) setState(() => _saveState = _SaveState.failed);
          }),
    );
  }

  Future<void> _signInToSave() async {
    final signedIn = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const AuthScreen(allowGuest: false)),
    );
    if (signedIn == true && mounted) _saveToHistory();
  }

  Future<void> _withBusyGuard(Future<void> Function() action) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _download() async {
    AppServices.of(context).audio.playSfx(Sfx.tap);
    await _withBusyGuard(() async {
      try {
        final bytes = await captureBoundaryAsPng(_reportKey);
        final result = await saveReportToGallery(bytes);
        _showSnack(result.message);
      } catch (_) {
        _showSnack("Couldn't download the report. Please try again.");
      }
    });
  }

  Future<void> _share() async {
    AppServices.of(context).audio.playSfx(Sfx.tap);
    await _withBusyGuard(() async {
      try {
        final bytes = await captureBoundaryAsPng(_reportKey);
        await shareReport(
          bytes: bytes,
          yourName: widget.yourName,
          friendName: widget.friendName,
          percent: _percent,
          verdictTitle: _band.title,
        );
      } catch (_) {
        _showSnack("Couldn't open the share sheet. Please try again.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // Side-by-side buttons break words ("Dow/nload") on narrow screens or
    // with large text, so stack them instead.
    final stackButtons =
        media.size.width < 400 || media.textScaler.scale(10) > 11.5;

    final download = OutlinedButton.icon(
      onPressed: _busy ? null : _download,
      icon: const Icon(Icons.download_rounded),
      label: const Text('Download'),
    );
    final share = ElevatedButton.icon(
      onPressed: _busy ? null : _share,
      icon: const Icon(Icons.ios_share_rounded),
      label: const Text('Share'),
    );

    return GradientPage(
      appBar: AppBar(
        title: const Text('Your verdict 📋'),
        actions: const [MuteButton()],
      ),
      // Pinned below the page — never inside the RepaintBoundary, so the
      // downloaded/shared scorecard image never contains an ad.
      bottom: AppServices.of(context).ads.banner(AdPlacement.result),
      // One scrolling page: the whole scorecard is always reachable, instead
      // of being squeezed into a small window above fixed buttons.
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          RepaintBoundary(
            key: _reportKey,
            // Cap text scaling on the card only: very large system text made
            // the exported image a 1:3.5 strip that social apps crop badly.
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.15,
              child: ReportCard(
                yourName: widget.yourName,
                friendName: widget.friendName,
                percent: _percent,
                band: _band,
                breakdown: _breakdown,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _SaveStatus(
            state: _saveState,
            onSignIn: _signInToSave,
            onRetry: _saveToHistory,
          ),
          const SizedBox(height: 14),
          if (stackButtons) ...[
            share,
            const SizedBox(height: 12),
            download,
          ] else
            Row(
              children: [
                Expanded(child: download),
                const SizedBox(width: 12),
                Expanded(child: share),
              ],
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _busy
                ? null
                : () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const WelcomeScreen()),
                      (route) => false,
                    );
                  },
            child: const Text('Play again 🔁'),
          ),
        ],
      ),
    );
  }
}

/// A one-line status under the scorecard (deliberately outside the
/// RepaintBoundary, so it never ends up in the shared image).
class _SaveStatus extends StatelessWidget {
  const _SaveStatus({
    required this.state,
    required this.onSignIn,
    required this.onRetry,
  });

  final _SaveState state;
  final VoidCallback onSignIn;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    Widget pill(Widget child, {VoidCallback? onTap}) => Center(
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(999),
          ),
          child: child,
        ),
      ),
    );

    switch (state) {
      case _SaveState.guest:
        return pill(
          Text('Sign in to save this verdict 💾', style: style),
          onTap: onSignIn,
        );
      case _SaveState.saving:
        return pill(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Text('Saving to your history…', style: style),
            ],
          ),
        );
      case _SaveState.saved:
        return pill(Text('Saved to your history ✅', style: style));
      case _SaveState.failed:
        return pill(
          Text("Couldn't save to your history 😬 Tap to retry", style: style),
          onTap: onRetry,
        );
    }
  }
}
