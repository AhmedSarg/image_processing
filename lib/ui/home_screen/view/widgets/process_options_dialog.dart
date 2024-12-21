import 'package:flutter/material.dart';
import 'package:image_processing/services/image_processor.dart';
import 'package:image_processing/ui/resources/app_size.dart';

class ProcessOptionsDialog extends StatelessWidget {
  const ProcessOptionsDialog({
    super.key,
    required this.onMethodPressed,
  });

  final Function(ImageProcessingMethod method) onMethodPressed;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: const AppPadding.allExcept(bottom: AppSize.s),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: ImageProcessingMethod.values
              .map(
                (method) => Padding(
                  padding: const AppPadding.only(bottom: AppSize.s),
                  child: ProcessOptionButton(
                    onPressed: () {
                      onMethodPressed(method);
                    },
                    text:
                        '${method.name.characters.first.toUpperCase()}${method.name.substring(1)}',
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class ProcessOptionButton extends StatelessWidget {
  const ProcessOptionButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(text),
    );
  }
}
