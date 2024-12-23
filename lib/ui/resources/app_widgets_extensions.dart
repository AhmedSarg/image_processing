import 'package:flutter/material.dart';
import 'package:image_processing/ui/resources/app_size.dart';

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
  static ElevatedButton rounded({
    void Function()? onPressed,
    Widget? child,
    EdgeInsets? padding,
    Color? backgroundColor,
    Color? foregroundColor,
    double? borderRadius,
  }) =>
      ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppSize.s),
          ),
          padding: padding,
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
        ),
        child: child,
      );
}

extension AppColumn on Column {
  static Column spaced({
    double? spacing,
    List<Widget> children = const [],
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: children
            .expand(
              (element) => [
                element,
                SizedBox(height: spacing ?? AppSize.s),
              ],
            )
            .toList()
          ..removeLast(),
      );
}
