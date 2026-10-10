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

/// A transparent Scaffold on top of the shared gradient, so every screen
/// after the welcome screen feels like the same app.
///
/// The gradient sits *outside* the Scaffold on purpose. A short
/// `SingleChildScrollView` body shrink-wraps to its content, so a gradient
/// painted inside the body used to stop partway down the screen on forms
/// like the names screen. Here it always fills the whole window (including
/// behind the app bar), whatever the body's size. `appBar` gets the
/// transparent/white styling from [buildAppTheme]'s `appBarTheme`.
class GradientPage extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;

  const GradientPage({super.key, this.appBar, required this.body});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: appGradientColors,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: appBar,
        body: SafeArea(child: body),
      ),
    );
  }
}
