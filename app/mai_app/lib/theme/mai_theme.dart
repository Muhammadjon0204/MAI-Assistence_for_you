import 'package:flutter/material.dart';

class ClaudeColors {
  static const Color primaryDark = Color(0xFF0D0D0D);
  static const Color secondaryDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF242424);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentGreen = Color(0xFF10B981);
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textHint = Color(0xFF6B7280);
  static const Color userMessageBg = Color(0xFF374151);
  static const Color aiMessageBg = Color(0xFF1F2937);
  static const Color borderColor = Color(0xFF374151);
}

class ClaudeTheme {
  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: ClaudeColors.primaryDark,
      scaffoldBackgroundColor: ClaudeColors.primaryDark,
      canvasColor: ClaudeColors.secondaryDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: ClaudeColors.secondaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: ClaudeColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: ClaudeColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: ClaudeColors.cardDark,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ClaudeColors.borderColor, width: 0.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ClaudeColors.accentBlue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ClaudeColors.cardDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ClaudeColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ClaudeColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: ClaudeColors.accentBlue, width: 2),
        ),
        contentPadding: const EdgeInsets.all(16),
        hintStyle: const TextStyle(color: ClaudeColors.textHint),
        labelStyle: const TextStyle(color: ClaudeColors.textSecondary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            color: ClaudeColors.textPrimary,
            fontSize: 28,
            fontWeight: FontWeight.w700),
        displayMedium: TextStyle(
            color: ClaudeColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.w600),
        displaySmall: TextStyle(
            color: ClaudeColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: ClaudeColors.textPrimary, fontSize: 16),
        bodyMedium: TextStyle(color: ClaudeColors.textSecondary, fontSize: 14),
        bodySmall: TextStyle(color: ClaudeColors.textHint, fontSize: 12),
      ),
      // ✅ ИСПРАВЛЕНО: DialogThemeData вместо DialogTheme
      dialogTheme: DialogThemeData(
        backgroundColor: ClaudeColors.secondaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: ClaudeColors.borderColor,
        thickness: 0.5,
        space: 1,
      ),
    );
  }
}
