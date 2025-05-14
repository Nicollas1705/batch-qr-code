import 'base_translation.dart';

class TranslationEnUs extends BaseTranslation {
  @override
  String get appTitle => 'Batch ${global.qrCodes} Generator';
  @override
  String get qrCodeGenerator => '${global.qrCodes} Generator';
  @override
  String generatedQrCodes(int total) => 'Generated ${global.qrCodes} ($total)';
  @override
  String get theme => 'Theme';
  @override
  String get language => 'Language';
  @override
  String get selectErrorLevel => 'Select error correction level';
  @override
  String get lightTheme => 'Light';
  @override
  String get darkTheme => 'Dark';
  @override
  String get systemTheme => 'System';
  @override
  String get cameraPermissionDenied =>
      'Camera access denied. Please allow camera access to scan ${global.qrCodes}.';
  @override
  String qrCodeReadingError(int current, int? total) =>
      'Error reading ${global.qrCode} ${global.indexRange(current, total)}';
  @override
  String get readBatchQrCodesAlert => 'Read the ${global.qrCodes} in batch';
  @override
  String get copiedToClipboard => 'Copied to clipboard';
  @override
  String get selectQrStoreSize => 'Select ${global.qrCode} storage size';
}
