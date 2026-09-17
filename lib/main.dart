import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FriendshipManiaApp());
}

class FriendshipManiaApp extends StatelessWidget {
  const FriendshipManiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'friendshipmania',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WelcomeScreen(),
    );
  }
}
