import 'qr_recovery_data_level.dart';

class QrCodeData {
  const QrCodeData({required this.chunks, required this.level});

  final List<String> chunks;
  final QrRecoveryDataLevel level;
}
