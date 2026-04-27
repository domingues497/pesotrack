import 'package:flutter/widgets.dart';

abstract final class AppSpacing {
  static const x1 = 4.0;
  static const x2 = 8.0;
  static const x3 = 12.0;
  static const x4 = 16.0;
  static const x5 = 20.0;
  static const x6 = 24.0;
  static const x8 = 32.0;

  static const screenPadding = EdgeInsets.symmetric(horizontal: x4);
  static const cardPadding = EdgeInsets.all(x4);
  static const buttonPadding = EdgeInsets.symmetric(horizontal: x4);
  static const fieldPadding = EdgeInsets.symmetric(horizontal: x4, vertical: x4);
}
