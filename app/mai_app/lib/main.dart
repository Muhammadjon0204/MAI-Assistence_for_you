// lib/main.dart
import 'package:flutter/material.dart';
import 'package:mai_app/screens/home_screen.dart';
import 'package:mai_app/theme/mai_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAI ASISSTENT',
      theme: ClaudeTheme.darkTheme,
      darkTheme: ClaudeTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}
