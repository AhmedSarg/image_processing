import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing/logic/cubit/base_states.dart';
import 'package:image_processing/logic/extensions/extensions.dart';
import 'package:image_processing/ui/resources/app_size.dart';

import '../../resources/app_widgets_extensions.dart';
import '../viewmodel/home_viewmodel.dart';
import 'widgets/process_options_dialog.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeViewModel, BaseStates>(
      builder: (context, state) {
        HomeViewModel viewModel = HomeViewModel.get(context);
        return Form(
          key: _formKey,
          child: Scaffold(
            appBar: AppBar(
              title: const Text('Image Processing'),
            ),
            body: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const AppPadding.all(AppSize.l),
                child: Wrap(
                  runSpacing: AppSize.l,
                  spacing: AppSize.l,
                  runAlignment: WrapAlignment.center,
                  alignment: WrapAlignment.center,
                  children: [
                    ImageContainer(
                      image: viewModel.initialImage,
                      validator: (_) {
                        if (viewModel.initialImage == null) {
                          return 'load an image to start';
                        }
                        return null;
                      },
                      placeholder: 'load an image to start',
                    ),
                    ImageContainer(
                      image: viewModel.processedImage,
                      placeholder: 'process an image to start',
                    ),
                    const SizedBox(height: AppSize.l),
                  ],
                ),
              ),
            ),
            bottomSheet: SizedBox(
              width: double.infinity,
              height: AppSize.l,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: AppElevatedButton.simple(
                          onPressed: () async {
                            await viewModel.loadImage();
                            if (viewModel.initialImage != null) {
                              _formKey.currentState!.reset();
                            }
                          },
                          padding: const AppPadding.vertical(AppSize.s),
                          child: const Text('Load'),
                        ),
                      ),
                      VerticalDivider(
                        width: 2,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      Expanded(
                        child: AppElevatedButton.simple(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              showDialog(
                                context: context,
                                builder: (context) => ProcessOptionsDialog(
                                  onMethodPressed: (method) async {
                                    Navigator.pop(context);
                                    await viewModel.processImage(method);
                                  },
                                ),
                              );
                            }
                          },
                          padding: const AppPadding.vertical(AppSize.s),
                          child: const Text('Process'),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: viewModel.clear,
                    style: IconButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.surface,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Theme.of(context).colorScheme.surface,
                          width: 2,
                        ),
                      ),
                    ),
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ImageContainer extends StatelessWidget {
  const ImageContainer({
    super.key,
    required this.image,
    required this.placeholder,
    this.onPressed,
    this.validator,
  });

  final File? image;
  final String placeholder;
  final Function()? onPressed;
  final String? Function(String? value)? validator;

  @override
  Widget build(BuildContext context) {
    return FormField(
      validator: validator,
      builder: (formState) {
        return GestureDetector(
          onTap: () async {
            if (onPressed != null) {
              await onPressed!();
            }
            formState.validate();
          },
          child: Container(
            height: context.width() - 2 * AppSize.l > 500
                ? 500
                : context.width() - 2 * AppSize.l,
            width: context.width() - 2 * AppSize.l > 500
                ? 500
                : context.width() - 2 * AppSize.l,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(AppSize.m),
              border: Border.all(
                color: formState.hasError
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.secondary,
                strokeAlign: BorderSide.strokeAlignOutside,
                width: AppSize.xxs,
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: image != null
                ? Image.file(
                    image!,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: Text(
                      placeholder,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
