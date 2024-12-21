import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_processing/logic/cubit/base_cubit.dart';
import 'package:image_processing/logic/cubit/base_states.dart';
import 'package:image_processing/services/image_processor.dart';

class HomeViewModel extends BaseCubit {
  static HomeViewModel get(context) => BlocProvider.of(context);
  static final ImageProcessor _imageProcessor = ImageProcessor();

  @override
  void onStart() {}

  loadImage() async {
    final XFile? pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      await _imageProcessor.loadImage(pickedImage.path);
    }
    emit(ContentState());
  }

  processImage(ImageProcessingMethod method) async {
    await _imageProcessor.processImage(method);
    emit(ContentState());
  }

  clear() {
    _imageProcessor.clear();
    emit(ContentState());
  }

  File? get initialImage => _imageProcessor.initialImage;

  File? get processedImage => _imageProcessor.processedImage;
}
