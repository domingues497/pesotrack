import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppGradients {
  static const accent = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [AppColors.accent, AppColors.accentSoft],
  );

  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFDFC),
      AppColors.surfaceAlt,
      Color(0xFFFFE0D4),
    ],
    stops: [0, 0.52, 1],
  );

  static const softWarm = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFFFAF8),
      Color(0xFFFFF1EC),
    ],
  );
}
