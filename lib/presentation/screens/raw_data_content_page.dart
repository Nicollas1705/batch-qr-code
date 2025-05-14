import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/i18n/lang.dart';
import '../../core/utils.dart';
import '../controllers/app_controller.dart';
import '../widgets/text_meta_data.dart';

class RawDataContentPage extends StatelessWidget {
  const RawDataContentPage({super.key, required this.appController, required this.rawData});
  final AppController appController;
  final String rawData;

  static const route = '/content';

  static void open(String text) => Utils.open(route, text);

  @override
  Widget build(BuildContext context) {
    const divider = Divider(thickness: 0, height: 0);
    final padding = EdgeInsets.symmetric(horizontal: AppSettings.spacing.small);

    return Scaffold(
      appBar: AppBar(actions: [IconButton(onPressed: onCopyTap, icon: const Icon(Icons.copy))]),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(padding: padding, child: SelectableText(rawData)),
            ),
          ),
          divider,
          Padding(padding: padding, child: TextMetaData(text: rawData)),
          divider,
        ],
      ),
    );
  }

  void onCopyTap() {
    unawaited(Utils.copyToClipboard(rawData));
    Utils.notify(appController.lang.translation.copiedToClipboard);
  }
}
