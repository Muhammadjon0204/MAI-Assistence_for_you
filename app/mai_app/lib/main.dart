import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MAIApp());
}

class MAIApp extends StatelessWidget {
  const MAIApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAI - Math AI Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
