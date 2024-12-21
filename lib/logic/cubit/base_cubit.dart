import 'package:flutter_bloc/flutter_bloc.dart';

import 'base_states.dart';

abstract class BaseCubit extends Cubit<BaseStates> {
  BaseCubit() : super(InitState()) {
    onStart();
  }

  void onStart();
}
