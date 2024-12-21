import 'package:flutter/material.dart';
import 'package:image_processing/ui/resources/app_size.dart';

import '../extensions/extensions.dart';
import 'base_states.dart';

class BaseWidgets {
  BaseWidgets._();

  static Widget buildImage(String imgPath) {
    return SizedBox(
      height: 100,
      width: 100,
      child: Image.asset(imgPath),
    );
  }

  static Widget buildAnimatedImage(String lottiePath, [bool repeat = false]) {
    return const SizedBox(
      height: 200,
      width: 200,
      child: Placeholder(),
      // child: Lottie.asset(
      //   lottiePath,
      //   repeat: repeat,
      // ),
    );
  }

  static Widget buildItemsColumn(List<Widget> children) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );
  }

  ///not used yet
  // static Widget buildItemsRow(List<Widget> children) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.center,
  //     crossAxisAlignment: CrossAxisAlignment.center,
  //     mainAxisSize: MainAxisSize.min,
  //     children: children,
  //   );
  // }

  static void showPopUpDialog(BuildContext context, List<Widget> children,
      {List<Widget>? actions}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              actions: actions,
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              content: Padding(
                padding: const EdgeInsets.all(AppSize.s),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: children,
                  ),
                ),
              ),
            ));
  }

  static Widget buildMessage(
    BuildContext context,
    String message,
  ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSize.xs),
        child: Text(
          message,
          // style: AppTextStyles.baseStatesMessageTextStyle(
          //   context,
          //   textColor,
          // ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  static Widget buildButton(
      {required DisplayType displayType,
      required BuildContext context,
      required String title,
      void Function()? onTap}) {
    if (onTap == null) return const SizedBox();

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSize.xs),
        child: SizedBox(
          width: context.width() * .5,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSize.xs),
              ),
            ),
            onPressed: () {
              if (displayType == DisplayType.popUpDialog) {
                Navigator.of(context).pop();
              }
              onTap();
            },
            child: Text(
              title,
              // style: AppTextStyles.baseStatesElevatedBtnTextStyle(context),
            ),
          ),
        ),
      ),
    );
  }
}
