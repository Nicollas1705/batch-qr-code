import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../entities/qr_recovery_data_level.dart';

class QrCodeWidget extends StatelessWidget {
  const QrCodeWidget({super.key, required this.level, required this.data, this.size});

  final QrRecoveryDataLevel level;
  final String data;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final qrCodeColor =
        theme.textTheme.titleLarge?.color ??
        switch (theme.brightness) {
          Brightness.dark => Colors.white,
          Brightness.light => Colors.black,
        };

    return QrImageView(
      data: data,
      version: QrVersions.auto,
      size: size,
      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: qrCodeColor),
      dataModuleStyle: QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: qrCodeColor,
      ),
      errorCorrectionLevel: level.toQrErrorCorrectLevel,
    );
  }
}
