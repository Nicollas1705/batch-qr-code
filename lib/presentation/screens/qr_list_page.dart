import 'package:flutter/material.dart';

import '../../core/app_settings.dart';
import '../../core/i18n/lang.dart';
import '../../core/utils.dart';
import '../../entities/qr_code_data.dart';
import '../controllers/app_controller.dart';
import '../widgets/qr_code_widget.dart';
import 'qr_full_screen_page.dart';

class QrListPage extends StatelessWidget {
  const QrListPage({super.key, required this.appController, required this.data});

  final AppController appController;
  final QrCodeData data;

  static const route = '/qr-list';

  static void open(QrCodeData data) => Utils.open(route, data);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appController.lang.translation.generatedQrCodes(data.chunks.length)),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_outlined),
            onPressed: () => openQrFullScreen(context, 0, autoPlay: true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: data.chunks.length,
              itemBuilder: (context, index) {
                final theme = Theme.of(context);

                return InkWell(
                  onTap: () => openQrFullScreen(context, index),
                  child: Ink(
                    color: theme.focusColor.withValues(alpha: index % 2 == 0 ? .1 : 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: Text('${index + 1}', style: const TextStyle(fontSize: 30)),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.all(AppSettings.spacing.small),
                            child: QrCodeWidget(data: data.chunks[index], level: data.level),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void openQrFullScreen(BuildContext context, int initialIndex, {bool autoPlay = false}) {
    QrFullScreenPage.open(
      QrFullScreenArgs(initialIndex: initialIndex, data: data, autoPlay: autoPlay),
    );
  }
}
