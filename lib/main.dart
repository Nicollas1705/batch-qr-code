import 'package:flutter/material.dart';

import 'presentation/controllers/app_controller.dart';
import 'presentation/main_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MainApp(appController: AppController()));
}
