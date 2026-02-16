import 'package:flutter/material.dart';
import 'package:mai_app/models/screens/home_screen.dart';
import 'services/auth_service.dart';
import 'models/screens/auth_screen.dart';
import 'theme/mai_theme.dart';

void main() {
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

// Экран загрузки - проверяет авторизацию
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
    await Future.delayed(const Duration(seconds: 1)); // Показываем splash

    final isLoggedIn = await _authService.isLoggedIn();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              isLoggedIn ? const HomeScreen() : const AuthScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClaudeColors.primaryDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.calculate_rounded,
                size: 60,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Color(0xFF667eea),
            ),
          ],
        ),
      ),
    );
  }
}
