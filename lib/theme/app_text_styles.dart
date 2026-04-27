import 'package:flutter/material.dart';

abstract final class AppTextStyles {
  static const bodyFontFamily = 'Inter';
  static const displayFontFamily = 'Plus Jakarta Sans';

  static TextTheme textTheme(Color textColor) {
    return TextTheme(
      displayMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 48,
        height: 1,
        fontWeight: FontWeight.w800,
        letterSpacing: -3.8,
        color: textColor,
      ),
      displaySmall: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 32,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        color: textColor,
      ),
      headlineMedium: TextStyle(
        fontFamily: displayFontFamily,
        fontSize: 24,
        height: 1.08,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        color: textColor,
      ),
      titleLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 18,
        height: 1.25,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.3,
        color: textColor,
      ),
      titleMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16,
        height: 1.25,
        fontWeight: FontWeight.w700,
        color: textColor,
      ),
      bodyLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodyMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 14,
        height: 1.4,
        fontWeight: FontWeight.w500,
        color: textColor,
      ),
      bodySmall: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 12,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: textColor,
      ),
      labelLarge: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 13,
        height: 1.15,
        fontWeight: FontWeight.w800,
        color: textColor,
      ),
      labelMedium: TextStyle(
        fontFamily: bodyFontFamily,
        fontSize: 11,
        height: 1.1,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: textColor,
      ),
    );
  }
}
