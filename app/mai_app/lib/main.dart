// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mai_app/models/screens/auth_screen.dart';
import 'package:mai_app/models/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'theme/mai_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Stripe.publishableKey =
      'pk_test_51T1mU6PjPI0z2HhUJgZk4bN2UW6Tpu79OaEQw6MUlZvc3erGCZvKKVxGzeVBnd30imeLIKQJbdqZ4PztQX4X3a5200BOToHaez';

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "MAI ASSISTANT",
      theme: ClaudeTheme.darkTheme,
      darkTheme: ClaudeTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));

    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => isLoggedIn
              ? const HomeScreen()
              : const AuthScreen(), // ← ИЗМЕНЕНО!
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // ← Claude цвет
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Иконка как у Claude
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 21, 164, 216),
                    const Color.fromARGB(255, 57, 104, 186).withOpacity(0.7),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.auto_awesome,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color.fromARGB(255, 57, 154, 244), // ← Claude цвет
            ),
          ],
        ),
      ),
    );
  }
}
