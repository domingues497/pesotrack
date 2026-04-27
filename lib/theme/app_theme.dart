import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
        background: AppColors.background,
        surface: AppColors.surface,
        text: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textMuted,
      );

  static ThemeData get darkTheme => _buildTheme(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        text: AppColors.darkText,
        onSurfaceVariant: const Color(0xFFDAB7AD),
      );

  static ThemeData _buildTheme({
    required Color background,
    required Color surface,
    required Color text,
    required Color onSurfaceVariant,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      brightness: background.computeLuminance() > 0.5 ? Brightness.light : Brightness.dark,
    ).copyWith(
      primary: AppColors.accent,
      secondary: AppColors.accentSoft,
      surface: surface,
      onSurface: text,
      onSurfaceVariant: onSurfaceVariant,
      outline: AppColors.border,
      error: AppColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: background,
      textTheme: AppTextStyles.textTheme(text),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: text,
        centerTitle: false,
        elevation: 0,
        titleTextStyle: AppTextStyles.textTheme(text).titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceAlt,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.accent)),
      ),
    );
  }
}
