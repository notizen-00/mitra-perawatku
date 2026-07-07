import 'package:flutter/widgets.dart';

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 40;
  static const double xxxl = 48;
  static const double huge = 64;
  static const double gutter = 16;
  static const double mobileMargin = 16;
  static const double tabletMargin = 32;

  static const EdgeInsets screen = EdgeInsets.all(mobileMargin);
  static const EdgeInsets card = EdgeInsets.all(lg);
  static const EdgeInsets button = EdgeInsets.symmetric(
    horizontal: md,
    vertical: md,
  );
}
