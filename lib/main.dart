import 'package:flutter/material.dart';

import 'screens/welcome_screen.dart';
import 'theme.dart';

void main() {
  runApp(const FriendshipPolygraphApp());
}

class FriendshipPolygraphApp extends StatelessWidget {
  const FriendshipPolygraphApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Friendship Polygraph',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const WelcomeScreen(),
    );
  }
}
