import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing/logic/cubit/base_cubit.dart';
import 'package:image_processing/logic/cubit/base_states.dart';
import 'package:image_processing/services/image_processor.dart';
import 'package:image_processing/ui/processing_screen/states/processing_states.dart';

class ProcessingViewModel extends BaseCubit {
  static ProcessingViewModel get(context) => BlocProvider.of(context);
  static final ImageProcessor _imageProcessor = ImageProcessor();

  final Set<ImageProcessingMethod> _shownMethods = {};
  final Map<ImageProcessingMethod, File> _processedImages = {};

  @override
  void onStart() {}

  processImage(ImageProcessingMethod method) async {
    if (_shownMethods.contains(method)) {
      _shownMethods.remove(method);
    } else {
      _shownMethods.add(method);
      if (_processedImages[method] == null) {
        emit(ProcessingLoadingState(method));
        _processedImages[method] = await _imageProcessor.processImage(method);
      }
    }
    emit(ContentState());
  }

  clear() {
    _processedImages.clear();
    _shownMethods.clear();
    emit(ContentState());
  }

  Set<ImageProcessingMethod> get shownMethods => _shownMethods;

  Map<ImageProcessingMethod, File> get processedImages => _processedImages;
}
