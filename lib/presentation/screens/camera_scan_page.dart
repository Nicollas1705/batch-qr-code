import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../core/app_consts.dart';
import '../../core/app_settings.dart';
import '../../core/helpers/route_aware_mixin.dart';
import '../../core/i18n/base_translation.dart';
import '../../core/i18n/lang.dart';
import '../../core/utils.dart';
import '../controllers/app_controller.dart';
import '../widgets/camera_mask.dart';
import 'raw_data_content_page.dart';

class CameraScanPage extends StatefulWidget {
  const CameraScanPage({super.key, required this.appController});
  final AppController appController;

  static const route = '/camera-scan';

  static void open() => Utils.open(route);

  @override
  State<CameraScanPage> createState() => _CameraScanPageState();
}

class _CameraScanPageState extends State<CameraScanPage> with RouteAwareMixin<CameraScanPage> {
  final cameraController = MobileScannerController();
  final scannedCodes = <String>[];
  final totalCodes = ValueNotifier<int?>(null);
  final indexFromCodes = ValueNotifier<int?>(null);
  bool isShowingErrorMessage = false;
  final hasScannedQrGeneratedByAppNotifier = ValueNotifier<bool?>(null);

  BaseTranslation get translation => widget.appController.lang.translation;

  @override
  void dispose() {
    cameraController.dispose();
    totalCodes.dispose();
    indexFromCodes.dispose();
    hasScannedQrGeneratedByAppNotifier.dispose();
    super.dispose();
  }

  @override
  RouteObserver routeObserver() => AppSettings.routeObserver;

  @override
  void didPopNext() {
    cameraController.start();
    reset();
  }

  @override
  void didPushNext() => cameraController.stop();

  @override
  Widget build(BuildContext context) {
    final holeSquareSize = MediaQuery.sizeOf(context).shortestSide - (AppSettings.spacing.big * 2);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: AnimatedBuilder(
          animation: Listenable.merge([indexFromCodes, totalCodes]),
          builder: (context, child) {
            if (indexFromCodes.value == null) {
              return const Icon(Icons.qr_code_scanner_outlined);
            }

            return Text(translation.global.indexRange(indexFromCodes.value!, totalCodes.value));
          },
        ),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: cameraController,
              builder: (context, controller, child) {
                final value = controller.torchState;

                return switch (value) {
                  TorchState.on => const Icon(Icons.flash_on, color: Colors.yellow),
                  _ => const Icon(Icons.flash_off, color: Colors.white),
                };
              },
            ),
            onPressed: cameraController.toggleTorch,
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios_outlined),
            onPressed: cameraController.switchCamera,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Positioned.fill(
                child: MobileScanner(
                  controller: cameraController,
                  onDetect:
                      (barcode) => handleScannedRawData(barcode.barcodes.first.rawValue ?? ''),
                  scanWindow: Rect.fromCircle(
                    center: Offset(constraints.maxWidth / 2, constraints.maxHeight / 2),
                    radius: holeSquareSize,
                  ),
                ),
              ),
              CameraMask(size: Size.square(holeSquareSize)),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSettings.spacing.medium),
        child: AnimatedBuilder(
          animation: Listenable.merge([hasScannedQrGeneratedByAppNotifier, indexFromCodes]),
          builder: (context, child) {
            if (hasScannedQrGeneratedByAppNotifier.value != false) return const SizedBox.shrink();

            final index = indexFromCodes.value;
            return Row(
              children: [
                FloatingActionButton(
                  onPressed: removeLastScannedCode,
                  child: Icon(
                    index != null && index > 1 ? Icons.undo_rounded : Icons.delete_outline_rounded,
                  ),
                ),
                const Spacer(),
                FloatingActionButton(
                  onPressed: () => openContent(separate: true),
                  child: const Icon(Icons.send_rounded),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> showQrCodeReaderErrorMessage() async {
    if (isShowingErrorMessage) return;
    isShowingErrorMessage = true;

    final controller = Utils.notify(
      translation.qrCodeReadingError(scannedCodes.length, totalCodes.value),
    );
    await controller.closed;
    isShowingErrorMessage = false;
  }

  void handleScannedRawData(String rawData) {
    if (rawData.isEmpty || scannedCodes.length == totalCodes.value) return;

    final isQrGeneratedByApp = rawData.startsWith(AppConsts.batchQrId);
    hasScannedQrGeneratedByAppNotifier.value ??= isQrGeneratedByApp;

    if (!hasScannedQrGeneratedByAppNotifier.value!) {
      if (scannedCodes.contains(rawData)) return;
      scannedCodes.add(rawData);
      indexFromCodes.value = scannedCodes.length;
      return;
    }

    if (!isQrGeneratedByApp) {
      showQrCodeReaderErrorMessage();
      return;
    }

    final decoded = Utils.decodeQrCodeHeader(rawData);
    if (decoded == null) {
      showQrCodeReaderErrorMessage();
      return;
    }

    final (index: index, total: total, content: content) = decoded;
    if (scannedCodes.contains(content)) return;

    if (totalCodes.value != null && totalCodes.value != total) {
      showQrCodeReaderErrorMessage();
      return;
    }

    if (scannedCodes.length < index) {
      showQrCodeReaderErrorMessage();
      return;
    }

    scannedCodes.add(content);
    totalCodes.value ??= total;
    indexFromCodes.value = index + 1;

    if (scannedCodes.length == totalCodes.value) openContent();
  }

  void openContent({bool separate = false}) =>
      RawDataContentPage.open(scannedCodes.join(separate ? '\n' : ''));

  void removeLastScannedCode() {
    scannedCodes.removeLast();
    indexFromCodes.value = scannedCodes.length;

    if (scannedCodes.isEmpty) reset();
  }

  void reset() {
    scannedCodes.clear();
    totalCodes.value = null;
    indexFromCodes.value = null;
    hasScannedQrGeneratedByAppNotifier.value = null;
    isShowingErrorMessage = false;
  }
}
