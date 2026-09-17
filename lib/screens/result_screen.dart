import 'package:flutter/material.dart';

import '../models/question.dart';
import '../services/report_service.dart';
import '../services/scoring.dart';
import '../widgets/gradient_page.dart';
import '../widgets/report_card.dart';
import 'welcome_screen.dart';

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

  Future<void> _download(int percent) async {
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

  Future<void> _share(int percent, String title) async {
    await _withBusyGuard(() async {
      try {
        final bytes = await captureBoundaryAsPng(_reportKey);
        await shareReport(
          bytes: bytes,
          yourName: widget.yourName,
          friendName: widget.friendName,
          percent: percent,
          verdictTitle: title,
        );
      } catch (_) {
        _showSnack("Couldn't open the share sheet. Please try again.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final percent = scoreToPercent(widget.questions, widget.chosenScores);
    final band = bandForPercent(percent);
    final breakdown = tagBreakdown(widget.questions, widget.chosenScores);

    return GradientPage(
      appBar: AppBar(title: const Text('Your verdict 📋')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: RepaintBoundary(
                  key: _reportKey,
                  child: ReportCard(
                    yourName: widget.yourName,
                    friendName: widget.friendName,
                    percent: percent,
                    band: band,
                    breakdown: breakdown,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : () => _download(percent),
                    icon: const Icon(Icons.download_rounded),
                    label: const Text('Download'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _busy ? null : () => _share(percent, band.title),
                    icon: const Icon(Icons.ios_share_rounded),
                    label: const Text('Share'),
                  ),
                ),
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
      ),
    );
  }
}
