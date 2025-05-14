import 'lang.dart';

abstract class BaseTranslation {
  String get appTitle;
  String get qrCodeGenerator;
  String generatedQrCodes(int total);
  String get theme;
  String get language;
  String get selectErrorLevel;
  String get lightTheme;
  String get darkTheme;
  String get systemTheme;
  String get cameraPermissionDenied;
  String qrCodeReadingError(int current, int? total);
  String get readBatchQrCodesAlert;
  String get copiedToClipboard;
  String get selectQrStoreSize;
}

extension BaseTranslationGlobal on BaseTranslation {
  TranslationGlobal get global => const TranslationGlobal();
}

class TranslationGlobal {
  const TranslationGlobal();

  String langName(Lang lang) => switch (lang) {
    Lang.pt_BR => 'Português (Brasil)',
    Lang.en_US => 'English (United States)',
    Lang.es => 'Español',
  };

  String indexRange(int current, int? total) => '[ $current / ${total ?? '??'} ]';

  String get qrCode => 'QR Code';
  String get qrCodes => 'QR Codes';
}
