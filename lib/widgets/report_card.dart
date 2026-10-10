import 'package:flutter/material.dart';

import '../services/scoring.dart';
import 'friendship_meter.dart';
import 'gradient_page.dart';

/// The shareable/downloadable scorecard itself.
///
/// This is exactly what gets captured to a PNG, so it paints its own opaque
/// gradient frame (a transparent export would show a hole when shared) and a
/// small branded footer, and avoids anything that only makes sense on-screen,
/// like ripple effects.
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
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appGradientColors,
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Card(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Text(
                    'friendshipmania',
                    style: textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$yourName on $friendName',
                    style: textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  FriendshipMeter(
                    percent: percent,
                    emoji: band.emoji,
                    sticker: band.sticker,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    band.title,
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    band.subtitle,
                    style: textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  if (breakdown.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text('The breakdown', style: textTheme.titleSmall),
                    const SizedBox(height: 12),
                    for (final t in breakdown)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    t.label,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${t.percent}%',
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: t.percent / 100,
                                minHeight: 10,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                valueColor: AlwaysStoppedAnimation(
                                  colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'friendshipmania · put your friendship on trial 🕵️',
            textAlign: TextAlign.center,
            style: textTheme.labelMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.95),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
