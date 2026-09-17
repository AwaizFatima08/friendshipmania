import 'package:flutter/material.dart';

/// The purple → magenta → pink gradient used as the backdrop on every
/// screen except the report card itself (which stays light/white on
/// purpose — it's the thing people actually screenshot and share, so it
/// needs to stay legible as a static image, not just readable live in-app).
const List<Color> appGradientColors = [
  Color(0xFF7C5CF0),
  Color(0xFFB84FE0),
  Color(0xFFFF5DA2),
];

/// A Scaffold with the shared gradient backdrop already wired up, so every
/// screen after the welcome screen feels like the same app instead of the
/// launch screen being a one-off. `appBar` gets the transparent/white
/// styling from [buildAppTheme]'s `appBarTheme` automatically — nothing
/// extra to do per-screen for that.
class GradientPage extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const GradientPage({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: appGradientColors.first,
      appBar: appBar,
      body: Stack(
        children: [
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
          SafeArea(child: body),
        ],
      ),
    );
  }
}
