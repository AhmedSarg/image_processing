import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing/logic/cubit/base_states.dart';
import 'package:image_processing/logic/cubit/cubit_listener.dart';
import 'package:image_processing/logic/extensions/extensions.dart';
import 'package:image_processing/services/image_processor.dart';
import 'package:image_processing/ui/processing_screen/states/processing_states.dart';
import 'package:image_processing/ui/processing_screen/viewmodel/processing_viewmodel.dart';
import 'package:image_processing/ui/resources/app_size.dart';
import 'package:image_processing/ui/resources/app_widgets_extensions.dart';

class ProcessingScreen extends StatelessWidget {
  const ProcessingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProcessingViewModel()..onStart(),
      child: BlocConsumer<ProcessingViewModel, BaseStates>(
        listener: (context, state) {
          baseListener(context, state);
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Processing'),
              actions: [
                IconButton(
                  onPressed: ProcessingViewModel.get(context).clear,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            body: SizedBox(
              width: double.infinity,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSize.m),
                child: AppColumn.spaced(
                  spacing: AppSize.m,
                  children: [
                    const LabSection(
                      labNumber: 1,
                      options: [
                        ProcessingOption(
                          title: 'Rgb to Gray',
                          method: ImageProcessingMethod.rgb2Gray,
                        ),
                        ProcessingOption(
                          title: 'Rgb to Binary',
                          method: ImageProcessingMethod.rgb2Binary,
                        ),
                        ProcessingOption(
                          title: 'Gray to Binary',
                          method: ImageProcessingMethod.gray2Binary,
                        ),
                      ],
                    ),
                    const LabSection(
                      labNumber: 2,
                      options: [
                        ProcessingOption(
                          title: 'Brightness',
                          method: ImageProcessingMethod.brightness,
                        ),
                        ProcessingOption(
                          title: 'Negative',
                          method: ImageProcessingMethod.negative,
                        ),
                        ProcessingOption(
                          title: 'Contrast',
                          method: ImageProcessingMethod.contrast,
                        ),
                      ],
                    ),
                    const LabSection(
                      labNumber: 3,
                      options: [
                        ProcessingOption(
                          title: 'Histogram',
                          method: ImageProcessingMethod.histogram,
                        ),
                        ProcessingOption(
                          title: 'Gamma Correction',
                          method: ImageProcessingMethod.gammaCorrection,
                        ),
                      ],
                    ),
                    const LabSection(
                      labNumber: 4,
                      options: [
                        ProcessingOption(
                          title: 'Histogram Equalization',
                          method: ImageProcessingMethod.histogramEqualization,
                        ),
                        ProcessingOption(
                          title: 'Convolution',
                          method: ImageProcessingMethod.convolution,
                        ),
                      ],
                    ),
                    const LabSection(
                      labNumber: 5,
                      options: [
                        ProcessingOption(
                          title: 'Blurring (Mean)',
                          method: ImageProcessingMethod.blurringMean,
                        ),
                        ProcessingOption(
                          title: 'Blurring (Weight)',
                          method: ImageProcessingMethod.blurringWeight,
                        ),
                        ProcessingOption(
                          title: 'Edge Detection (Point)',
                          method: ImageProcessingMethod.edgeDetectionPoint,
                        ),
                        ProcessingOption(
                          title: 'Edge Detection (Horizontal)',
                          method: ImageProcessingMethod.edgeDetectionHorizontal,
                        ),
                        ProcessingOption(
                          title: 'Edge Detection (Vertical)',
                          method: ImageProcessingMethod.edgeDetectionVertical,
                        ),
                        ProcessingOption(
                          title: 'Edge Detection (Diagonal Left)',
                          method:
                              ImageProcessingMethod.edgeDetectionDiagonalLeft,
                        ),
                        ProcessingOption(
                          title: 'Edge Detection (Diagonal Right)',
                          method:
                              ImageProcessingMethod.edgeDetectionDiagonalRight,
                        ),
                        ProcessingOption(
                          title: 'Sharpening (Point)',
                          method: ImageProcessingMethod.sharpeningPoint,
                        ),
                        ProcessingOption(
                          title: 'Sharpening (Horizontal)',
                          method: ImageProcessingMethod.sharpeningHorizontal,
                        ),
                        ProcessingOption(
                          title: 'Sharpening (Vertical)',
                          method: ImageProcessingMethod.sharpeningVertical,
                        ),
                        ProcessingOption(
                          title: 'Sharpening (Diagonal Left)',
                          method: ImageProcessingMethod.sharpeningDiagonalLeft,
                        ),
                        ProcessingOption(
                          title: 'Sharpening (Diagonal Right)',
                          method: ImageProcessingMethod.sharpeningDiagonalRight,
                        ),
                      ],
                    ),
                    const LabSection(
                      labNumber: 6,
                      options: [
                        ProcessingOption(
                          title: 'Fourier Transform',
                          method: ImageProcessingMethod.fourierTransform,
                        ),
                        ProcessingOption(
                          title: 'Fourier Transform (Inverse)',
                          method: ImageProcessingMethod.fourierTransformInverse,
                        ),
                        ProcessingOption(
                          title: 'Frequency Domain Filter (Ideal Low Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterIdealLowPass,
                        ),
                        ProcessingOption(
                          title: 'Frequency Domain Filter (Gaussian Low Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterGaussianLowPass,
                        ),
                        ProcessingOption(
                          title:
                              'Frequency Domain Filter (Butterworth Low Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterButterworthLowPass,
                        ),
                        ProcessingOption(
                          title: 'Frequency Domain Filter (Ideal High Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterIdealHighPass,
                        ),
                        ProcessingOption(
                          title: 'Frequency Domain Filter (Gaussian High Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterGaussianHighPass,
                        ),
                        ProcessingOption(
                          title:
                              'Frequency Domain Filter (Butterworth High Pass)',
                          method: ImageProcessingMethod
                              .frequencyDomainFilterButterworthHighPass,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class LabSection extends StatelessWidget {
  const LabSection({
    super.key,
    required this.labNumber,
    required this.options,
  });

  final int labNumber;
  final List<Widget> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Lab $labNumber',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSize.s),
        ...options.expand(
          (element) => [
            element,
            const Divider(
              thickness: 0,
              height: 0,
            ),
          ],
        ),
      ],
    );
  }
}

class ProcessingOption extends StatelessWidget {
  const ProcessingOption({
    super.key,
    required this.title,
    required this.method,
  });

  final String title;
  final ImageProcessingMethod method;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProcessingViewModel, BaseStates>(
      builder: (context, state) {
        ProcessingViewModel viewModel = ProcessingViewModel.get(context);
        return Column(
          children: [
            TextButton(
              onPressed: () {
                viewModel.processImage(method);
              },
              style: TextButton.styleFrom(
                shape: const LinearBorder(),
                padding: const AppPadding.symmetric(
                  vertical: AppSize.m,
                  horizontal: AppSize.xs,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: Text(title)),
                  const SizedBox(width: AppSize.xxs),
                  Icon(
                    viewModel.shownMethods.contains(method)
                        ? Icons.keyboard_arrow_down_rounded
                        : Icons.keyboard_arrow_right_rounded,
                    size: 22,
                  ),
                ],
              ),
            ),
            viewModel.shownMethods.contains(method)
                ? SizedBox(
                    height: context.width() - AppSize.xl,
                    child: BlocBuilder<ProcessingViewModel, BaseStates>(
                      builder: (context, state) {
                        if (state is ProcessingLoadingState &&
                            state.method == method) {
                          return const Center(
                            child: CircularProgressIndicator(strokeWidth: 1),
                          );
                        }
                        return Image.file(
                          viewModel.processedImages[method]!,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        );
      },
    );
  }
}
