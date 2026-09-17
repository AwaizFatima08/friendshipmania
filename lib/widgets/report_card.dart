import 'package:flutter/material.dart';

import '../services/scoring.dart';
import 'friendship_meter.dart';

/// The shareable/downloadable scorecard itself.
///
/// This is exactly what gets captured to a PNG, so it deliberately paints
/// its own opaque background (a transparent card would export with a
/// see-through hole when shared) and avoids anything that only makes sense
/// on-screen, like ripple effects.
class ReportCard extends StatelessWidget {
  final String yourName;
  final String friendName;
  final int percent;
  final ScoreBand band;
  final List<TagScore> breakdown;

  const ReportCard({
    super.key,
    required this.yourName,
    required this.friendName,
    required this.percent,
    required this.band,
    required this.breakdown,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.surface,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Text(
                'friendshipmania',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
              ),
              const SizedBox(height: 8),
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
              if (breakdown.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  'The breakdown',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                ...breakdown.map((t) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              t.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 4,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: t.percent / 100,
                                minHeight: 10,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                valueColor:
                                    AlwaysStoppedAnimation(colorScheme.primary),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 36,
                            child: Text(
                              '${t.percent}%',
                              textAlign: TextAlign.end,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
