import 'package:flutter/material.dart';

abstract final class AppShadows {
  static const soft = [
    BoxShadow(
      color: Color(0x1278350F),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static const medium = [
    BoxShadow(
      color: Color(0x1C78350F),
      blurRadius: 42,
      offset: Offset(0, 18),
    ),
  ];
}
