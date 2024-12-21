import 'package:flutter/cupertino.dart';

class AppSize {
  static const double xxxs = 2.0;
  static const double xxs = 4.0;
  static const double xs = 8.0;
  static const double s = 16.0;
  static const double m = 32.0;
  static const double l = 64.0;
  static const double xl = 128.0;
  static const double xxl = 256.0;
  static const double xxxl = 512.0;
}

class AppPadding extends EdgeInsets {
  const AppPadding.all(super.value) : super.all();

  const AppPadding.only({
    super.top,
    super.right,
    super.bottom,
    super.left,
  }) : super.only();

  const AppPadding.fromLTRB(
    super.left,
    super.top,
    super.right,
    super.bottom,
  ) : super.fromLTRB();

  const AppPadding.symmetric({
    super.horizontal,
    super.vertical,
  }) : super.symmetric();

  const AppPadding.horizontal(double value)
      : super.symmetric(
          vertical: 0,
          horizontal: value,
        );

  const AppPadding.vertical(double value)
      : super.symmetric(
          horizontal: 0,
          vertical: value,
        );

  const AppPadding.top(double value) : super.only(top: value);

  const AppPadding.bottom(double value) : super.only(bottom: value);

  const AppPadding.left(double value) : super.only(left: value);

  const AppPadding.right(double value) : super.only(right: value);

  const AppPadding.allExcept({
    double? top,
    double? right,
    double? bottom,
    double? left,
  }) : super.only(
          top: top == null ? (right ?? bottom ?? left ?? 0) : 0,
          right: right == null ? (bottom ?? left ?? top ?? 0) : 0,
          bottom: bottom == null ? (left ?? top ?? right ?? 0) : 0,
          left: left == null ? (top ?? right ?? bottom ?? 0) : 0,
        );

  const AppPadding.zero() : super.all(0);
}
