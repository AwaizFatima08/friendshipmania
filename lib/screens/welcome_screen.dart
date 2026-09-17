import 'package:flutter/material.dart';

import '../widgets/gradient_page.dart';
import 'names_screen.dart';

/// The launch screen. This one deliberately breaks from the app's plain
/// light theme used everywhere else — it's the first thing anyone sees, so
/// it gets the loud gradient-and-stickers treatment while every other
/// screen stays clean and readable for actually answering questions.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-bleed gradient backdrop.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: appGradientColors,
                ),
              ),
            ),
          ),

          // Loose, slightly-rotated "sticker" emoji scattered around the
          // edges — decorative only, so they're excluded from screen readers.
          const Positioned(
            top: 60,
            left: 18,
            child: _StickerEmoji(emoji: '👀', angle: -0.25, size: 34),
          ),
          const Positioned(
            top: 90,
            right: 24,
            child: _StickerEmoji(emoji: '💅', angle: 0.3, size: 30),
          ),
          const Positioned(
            bottom: 130,
            left: 28,
            child: _StickerEmoji(emoji: '🔥', angle: 0.2, size: 32),
          ),
          const Positioned(
            bottom: 90,
            right: 20,
            child: _StickerEmoji(emoji: '✨', angle: -0.2, size: 28),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        '✨ VIBE CHECK: FRIENDSHIP EDITION ✨',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _PopIn(
                    child: Center(
                      child: Container(
                        width: 116,
                        height: 116,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.18),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: const Text('🕵️', style: TextStyle(fontSize: 60)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      colors: [Colors.white, Color(0xFFFFE97A)],
                    ).createShader(bounds),
                    child: Text(
                      'friendshipmania',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontSize: 38,
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Nobody lies to a polygraph.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '10 unhinged questions. Zero chill. Find out if this '
                    "friendship really hits different — then send it and "
                    'let them cook.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                  ),
                  const SizedBox(height: 36),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const NamesScreen()),
                      );
                    },
                    child: const Text('Start the Interrogation 🕵️'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small rotated emoji "sticker" — purely decorative, hidden from
/// assistive tech so screen readers don't announce a wall of emoji.
class _StickerEmoji extends StatelessWidget {
  final String emoji;
  final double angle;
  final double size;

  const _StickerEmoji({required this.emoji, required this.angle, required this.size});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Opacity(
        opacity: 0.55,
        child: Transform.rotate(
          angle: angle,
          child: Text(emoji, style: TextStyle(fontSize: size)),
        ),
      ),
    );
  }
}

/// A one-shot "pop in" entrance — scales up from slightly small with a
/// bouncy overshoot, purely a launch-screen flourish.
class _PopIn extends StatelessWidget {
  final Widget child;

  const _PopIn({required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1.0),
      duration: const Duration(milliseconds: 650),
      curve: Curves.elasticOut,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: child,
    );
  }
}
