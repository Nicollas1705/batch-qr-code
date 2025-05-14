import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/app_consts.dart';
import '../../core/app_settings.dart';
import '../../core/i18n/base_translation.dart';
import '../../core/i18n/lang.dart';
import '../../core/utils.dart';
import '../../entities/qr_code_data.dart';
import '../../entities/qr_recovery_data_level.dart';
import '../controllers/app_controller.dart';
import '../widgets/choices_dialog.dart';
import '../widgets/numered_text_field.dart';
import '../widgets/text_meta_data.dart';
import 'camera_scan_page.dart';
import 'qr_full_screen_page.dart';
import 'qr_list_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.appController});
  final AppController appController;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final textNotifier = ValueNotifier('');
  final hasTextNotifier = ValueNotifier(false);
  final textLenghtNotifier = ValueNotifier(0);
  final textLinesNotifier = ValueNotifier(1);

  @override
  void initState() {
    super.initState();

    textNotifier.addListener(() {
      hasTextNotifier.value = textNotifier.value.isNotEmpty;
      textLenghtNotifier.value = textNotifier.value.length;
      textLinesNotifier.value = textNotifier.value.split('\n').length;
    });
  }

  @override
  void dispose() {
    textNotifier.dispose();
    hasTextNotifier.dispose();
    textLenghtNotifier.dispose();
    textLinesNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const divider = Divider(thickness: 0, height: 0);

    return Scaffold(
      key: AppSettings.globalScaffoldKey,
      appBar: AppBar(
        title: Text(widget.appController.lang.translation.qrCodeGenerator),
        actions: [
          IconButton(icon: const Icon(Icons.brightness_4), onPressed: onThemeButtonTap),
          IconButton(icon: const Icon(Icons.translate_rounded), onPressed: onLanguageButtonTap),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: NumberedTextField(
              textFieldRestorationId: AppConsts.textFieldRestorationId,
              onChanged: (text) => textNotifier.value = text,
            ),
          ),
          divider,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSettings.spacing.small),
            child: ValueListenableBuilder(
              valueListenable: textNotifier,
              builder: (context, value, child) => TextMetaData(text: value),
            ),
          ),
          divider,
          Padding(
            padding: EdgeInsets.all(AppSettings.spacing.medium),
            child: Row(
              spacing: AppSettings.spacing.small,
              children:
                  [
                    ElevatedButton(
                      onPressed: () => onCameraTap(context),
                      child: const Icon(Icons.camera_alt_outlined),
                    ),
                    ValueListenableBuilder(
                      valueListenable: hasTextNotifier,
                      builder: (context, value, child) {
                        return ElevatedButton(
                          onPressed:
                              !value
                                  ? null
                                  : () => onGenerateQrCodeTap(context, widget.appController),
                          child: const Icon(Icons.send_rounded),
                        );
                      },
                    ),
                  ].map((child) => Expanded(child: child)).toList(),
            ),
          ),
        ],
      ),
    );
  }

  String themeTranslation(ThemeMode theme, BaseTranslation transition) => switch (theme) {
    ThemeMode.system => transition.systemTheme,
    ThemeMode.light => transition.lightTheme,
    ThemeMode.dark => transition.darkTheme,
  };

  Future<void> onCameraTap(BuildContext context) async {
    final status = await Permission.camera.request();
    if (!context.mounted) return;

    if (!status.isGranted) {
      Utils.notify(widget.appController.lang.translation.cameraPermissionDenied);
    } else {
      CameraScanPage.open();
    }
  }

  Future<void> onGenerateQrCodeTap(BuildContext context, AppController appController) async {
    final level = await ChoicesDialog<QrRecoveryDataLevel>(
      title: appController.lang.translation.selectErrorLevel,
      initialValue: QrRecoveryDataLevel.low,
      valueLabelMapper: Map.fromEntries(
        QrRecoveryDataLevel.values.map((level) {
          final label =
              '${level.name.substring(0, 1).toUpperCase()} (${(level.recovery * 100).toInt()}%)';

          return MapEntry(level, Text(label));
        }),
      ),
    ).show(context);

    if (level == null) return;

    if (!context.mounted) return;
    final size = await ChoicesDialog<int>(
      title: appController.lang.translation.selectQrStoreSize,
      initialValue: AppConsts.qrCodeStoreSizes[(AppConsts.qrCodeStoreSizes.length / 2).ceil()],
      valueLabelMapper: Map.fromEntries(
        AppConsts.qrCodeStoreSizes.map((size) => MapEntry(size, Text('$size'))),
      ),
    ).show(context);

    if (size == null) return;
    final chunks = Utils.generateQrCodes(textNotifier.value, level.first, size.first);

    if (chunks.isEmpty || !context.mounted) return;
    final data = QrCodeData(chunks: chunks, level: level.first);

    if (chunks.length > 1) {
      QrListPage.open(data);
      return;
    }

    QrFullScreenPage.open(QrFullScreenArgs(initialIndex: 0, data: data));
  }

  Future<void> onThemeButtonTap() async {
    final mode = await ChoicesDialog<ThemeMode>(
      title: widget.appController.lang.translation.theme,
      initialValue: widget.appController.themeMode,
      valueLabelMapper: Map.fromEntries(
        ThemeMode.values.map(
          (mode) =>
              MapEntry(mode, Text(themeTranslation(mode, widget.appController.lang.translation))),
        ),
      ),
    ).show(context);

    if (mode != null) widget.appController.updateThemeMode(mode.first);
  }

  Future<void> onLanguageButtonTap() async {
    final lang = await ChoicesDialog<Lang>(
      title: widget.appController.lang.translation.language,
      initialValue: widget.appController.lang,
      valueLabelMapper: Map.fromEntries(
        Lang.values.map(
          (lang) =>
              MapEntry(lang, Text(widget.appController.lang.translation.global.langName(lang))),
        ),
      ),
    ).show(context);

    if (lang != null) widget.appController.updateLang(lang.first);
  }
}
