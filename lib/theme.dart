import 'package:flutter/material.dart';

/// One shared theme for the whole app: bold, playful, and built entirely
/// out of color/typography/emoji — no custom illustrations needed.
///
/// Every screen except the report card itself sits on the purple/pink
/// gradient from `widgets/gradient_page.dart`, so this theme assumes a
/// vivid backdrop: the app bar is transparent with white text, primary
/// actions are a solid neon-lime pill, and secondary actions (including
/// the quiz's answer options) are solid white pills — both read cleanly
/// against the gradient. The report card stays on its own light surface
/// and is styled directly in `widgets/report_card.dart`, not from here.
ThemeData buildAppTheme() {
  const seed = Color(0xFF6C4CE0); // playful purple
  const neonLime = Color(0xFFD6FF3F);
  const deepPurple = Color(0xFF2B0B4E);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: colorScheme.surface,
    textTheme: const TextTheme(
      headlineLarge: TextStyle(fontWeight: FontWeight.w800),
      headlineMedium: TextStyle(fontWeight: FontWeight.w800),
      titleLarge: TextStyle(fontWeight: FontWeight.w700),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      iconTheme: IconThemeData(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: neonLime,
        foregroundColor: deepPurple,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        elevation: 4,
        shadowColor: Colors.black.withValues(alpha: 0.3),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: deepPurple,
        side: BorderSide.none,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.25),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      labelStyle: TextStyle(color: deepPurple.withValues(alpha: 0.7)),
      counterStyle: TextStyle(color: Colors.white.withValues(alpha: 0.85)),
      errorStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w700,
        backgroundColor: Color(0xAAB0003A),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: neonLime,
      linearTrackColor: Colors.white.withValues(alpha: 0.3),
    ),
  );
}
