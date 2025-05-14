import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import '../core/app_settings.dart';
import '../core/i18n/lang.dart';
import '../entities/qr_code_data.dart';
import 'controllers/app_controller.dart';
import 'screens/camera_scan_page.dart';
import 'screens/home_page.dart';
import 'screens/qr_full_screen_page.dart';
import 'screens/qr_list_page.dart';
import 'screens/raw_data_content_page.dart';

class MainApp extends StatefulWidget {
  const MainApp({super.key, required this.appController});
  final AppController appController;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(AppSettings.deviceOrientation);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appController,
      builder: (context, child) {
        return MaterialApp(
          title: widget.appController.lang.translation.appTitle,
          navigatorKey: AppSettings.globalNavigationKey,
          navigatorObservers: [AppSettings.routeObserver],
          themeMode: widget.appController.themeMode,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: widget.appController.themeColor,
              brightness: Brightness.light,
            ),
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: widget.appController.themeColor,
              brightness: Brightness.dark,
            ),
          ),
          localeResolutionCallback: (locale, supportedLocales) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale?.languageCode &&
                  supportedLocale.countryCode == locale?.countryCode) {
                return supportedLocale;
              }
            }
            return supportedLocales.first;
          },
          locale: widget.appController.lang.toLocale,
          supportedLocales: Lang.values.map((lang) => lang.toLocale),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: HomePage(appController: widget.appController),
          onGenerateRoute: (settings) {
            return switch (settings.name) {
              QrListPage.route => MaterialPageRoute(
                builder: (context) {
                  return QrListPage(
                    appController: widget.appController,
                    data: settings.arguments as QrCodeData,
                  );
                },
              ),
              QrFullScreenPage.route => MaterialPageRoute(
                builder: (context) {
                  return QrFullScreenPage(
                    appController: widget.appController,
                    args: settings.arguments as QrFullScreenArgs,
                  );
                },
              ),
              RawDataContentPage.route => MaterialPageRoute(
                builder: (context) {
                  return RawDataContentPage(
                    appController: widget.appController,
                    rawData: settings.arguments as String,
                  );
                },
              ),
              _ => null,
            };
          },
          routes: {
            CameraScanPage.route: (context) => CameraScanPage(appController: widget.appController),
          },
        );
      },
    );
  }
}
