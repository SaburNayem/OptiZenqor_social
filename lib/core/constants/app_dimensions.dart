import 'package:flutter/widgets.dart';

class AppDimensions {
  AppDimensions._();

  static const double spacingXs = 6;
  static const double spacingSm = 10;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
  static const double spacingXl = 32;

  static const double radiusSm = 10;
  static const double radiusMd = 14;
  static const double radiusLg = 20;

  static const EdgeInsets pagePadding = EdgeInsets.symmetric(
    horizontal: spacingMd,
    vertical: spacingSm,
  );
}
