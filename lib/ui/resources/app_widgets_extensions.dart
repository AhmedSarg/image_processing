import 'package:flutter/material.dart';

extension AppElevatedButton on ElevatedButton {
  static ElevatedButton simple({
    void Function()? onPressed,
    Widget? child,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? foregroundColor,
  }) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: const LinearBorder(),
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: child,
      );
}
