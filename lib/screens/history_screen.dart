import 'package:flutter/material.dart';

import '../services/app_services.dart';
import '../services/user_data_service.dart';
import '../widgets/gradient_page.dart';
import '../widgets/mute_button.dart';

/// The signed-in user's saved verdicts, newest first.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.uid});

  final String uid;

  static String formatDate(DateTime? d) {
    if (d == null) return 'just now';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final data = AppServices.of(context).data;

    return GradientPage(
      appBar: AppBar(
        title: const Text('My verdicts 📋'),
        actions: const [MuteButton()],
      ),
      body: StreamBuilder<List<SavedReport>>(
        stream: data.watchReports(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const _Message(
              emoji: '📡',
              text: "Couldn't load your verdicts. Check your connection and try again.",
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const _Message(
              emoji: '🕵️',
              text: 'No verdicts yet. Your friendships are suspiciously un-judged.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: reports.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final r = reports[i];
              return Card(
                color: Colors.white,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  leading: Text(r.bandEmoji, style: const TextStyle(fontSize: 32)),
                  title: Text(
                    '${r.yourName} on ${r.friendName}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(
                    '${r.percent}% · ${r.bandTitle}\n${formatDate(r.createdAt)}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Delete this verdict',
                    icon: const Icon(Icons.delete_outline_rounded),
                    onPressed: () => _confirmDelete(context, data, r),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserDataService data,
    SavedReport r,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this verdict?'),
        content: Text('${r.yourName} on ${r.friendName} (${r.percent}%) will be gone for good.'),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.black87),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep it'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFB0003A)),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await data.deleteReport(uid, r.id);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Couldn't delete that one. Try again?")),
          );
        }
      }
    }
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.emoji, required this.text});

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
