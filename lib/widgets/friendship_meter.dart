import 'package:flutter/material.dart';

/// A big, friendly "meter" bar for the scorecard — an animated fill bar
/// plus a large emoji and percentage. Deliberately simple (no custom art
/// assets) so it's cheap to build and easy to re-skin later.
class FriendshipMeter extends StatelessWidget {
  final int percent;
  final String emoji;

  const FriendshipMeter({
    super.key,
    required this.percent,
    required this.emoji,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 72)),
        const SizedBox(height: 12),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: percent / 100),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: value,
                    minHeight: 22,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${(value * 100).round()}%',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
