import 'package:qr_flutter/qr_flutter.dart';

enum QrRecoveryDataLevel {
  low(recovery: .07),
  medium(recovery: .15),
  quartile(recovery: .25),
  high(recovery: .3);

  const QrRecoveryDataLevel({required this.recovery});

  final double recovery;

  int chunkSize(int qrStoreSize) => (qrStoreSize * (1 - (recovery * 2))).ceil();
}

extension RecoveryDataLevelExtension on QrRecoveryDataLevel {
  int get toQrErrorCorrectLevel => switch (this) {
    QrRecoveryDataLevel.low => QrErrorCorrectLevel.L,
    QrRecoveryDataLevel.medium => QrErrorCorrectLevel.M,
    QrRecoveryDataLevel.quartile => QrErrorCorrectLevel.Q,
    QrRecoveryDataLevel.high => QrErrorCorrectLevel.H,
  };
}
