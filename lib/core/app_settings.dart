import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'i18n/lang.dart';

abstract final class AppSettings {
  static const defaultThemeMode = ThemeMode.system;
  static const deviceOrientation = [DeviceOrientation.portraitUp];
  static const defaultLanguage = Lang.en_US;
  static const spacing = Spacing();
  static final defaultAppColor = Colors.yellow[800]!;
  static final globalScaffoldKey = GlobalKey<ScaffoldState>();
  static final globalNavigationKey = GlobalKey<NavigatorState>();
  static final routeObserver = RouteObserver<Route>();
}

class Spacing {
  const Spacing();
  final double small = 8;
  final double medium = 16;
  final double big = 32;
}
