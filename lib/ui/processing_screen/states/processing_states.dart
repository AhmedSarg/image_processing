import 'package:image_processing/logic/cubit/base_states.dart';
import 'package:image_processing/services/image_processor.dart';

class ProcessingLoadingState extends LoadingState {
  final ImageProcessingMethod method;

  ProcessingLoadingState(this.method);
}
