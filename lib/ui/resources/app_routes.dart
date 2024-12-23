import 'package:flutter/material.dart';

import '../home_screen/view/home_screen.dart';
import '../processing_screen/view/processing_screen.dart';

class Routes {
  Routes._();
  static const String homeRoute = "/";
  static const String processingRoute = "/processing";
}

class RouteGenerator {
  RouteGenerator._();

  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.homeRoute:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case Routes.processingRoute:
        return MaterialPageRoute(builder: (_) => const ProcessingScreen());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
      ),
    );
  }
}
