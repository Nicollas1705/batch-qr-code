import 'package:flutter/material.dart';

import 'presentation/controllers/app_controller.dart';
import 'presentation/main_app.dart';

// * Note: if the app doesn't run correctly in debug mode on Android, check out the file: android/app/src/main/AndroidManifest.xml
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(appController: AppController()));
}
