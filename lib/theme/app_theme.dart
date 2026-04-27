import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_spacing.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get lightTheme => _buildTheme(
        background: AppColors.background,
        surface: AppColors.surface,
        surfaceAlt: AppColors.surfaceAlt,
        text: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textMuted,
      );

  static ThemeData get darkTheme => _buildTheme(
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceAlt: AppColors.darkSurfaceAlt,
        text: AppColors.darkText,
        onSurfaceVariant: const Color(0xFFDAB7AD),
      );

  static ThemeData _buildTheme({
    required Color background,
    required Color surface,
    required Color surfaceAlt,
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
      tertiary: AppColors.accentDeep,
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
        scrolledUnderElevation: 0,
        titleSpacing: AppSpacing.x4,
        titleTextStyle: AppTextStyles.textTheme(text).titleLarge,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.large),
          side: const BorderSide(color: AppColors.border),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: AppTextStyles.textTheme(AppColors.white).bodySmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
      ),
      dividerColor: AppColors.border,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTextStyles.textTheme(AppColors.white).labelLarge,
          foregroundColor: AppColors.white,
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          elevation: 0,
          minimumSize: const Size.fromHeight(48),
          padding: AppSpacing.buttonPadding,
          textStyle: AppTextStyles.textTheme(text).labelLarge,
          foregroundColor: text,
          backgroundColor: surface,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceAlt,
        selectedColor: surfaceAlt,
        disabledColor: surfaceAlt,
        side: const BorderSide(color: AppColors.border),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.x2,
          vertical: AppSpacing.x1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.full),
        ),
        labelStyle: AppTextStyles.textTheme(text).bodySmall,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 78,
        backgroundColor: AppColors.white.withValues(alpha: 0.82),
        indicatorColor: surfaceAlt,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return AppTextStyles.textTheme(
            isSelected ? AppColors.accentDeep : AppColors.textMuted,
          ).bodySmall;
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? AppColors.accentDeep : AppColors.textMuted,
            size: 22,
          );
        }),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceAlt,
        hintStyle: AppTextStyles.textTheme(onSurfaceVariant).bodyMedium,
        contentPadding: AppSpacing.fieldPadding,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.2),
        ),
      ),
    );
  }
}
