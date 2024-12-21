import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_processing/logic/cubit/cubit_builder.dart';
import 'package:image_processing/logic/cubit/cubit_listener.dart';

import '../../../logic/cubit/base_states.dart';
import '../viewmodel/home_viewmodel.dart';
import 'home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeViewModel(),
      child: BlocConsumer<HomeViewModel, BaseStates>(
        listener: (context, state) {
          baseListener(context, state);
        },
        builder: (context, state) {
          return baseBuilder(context, state, const HomeView());
        },
      ),
    );
  }
}
