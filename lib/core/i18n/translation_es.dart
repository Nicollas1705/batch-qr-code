import 'base_translation.dart';

class TranslationEs extends BaseTranslation {
  @override
  String get appTitle => 'Generador de ${global.qrCodes} por Lote';
  @override
  String get qrCodeGenerator => 'Generador de ${global.qrCodes}';
  @override
  String generatedQrCodes(int total) => '${global.qrCodes} Generados ($total)';
  @override
  String get theme => 'Tema';
  @override
  String get language => 'Idioma';
  @override
  String get selectErrorLevel => 'Seleccione el nivel de corrección de error';
  @override
  String get lightTheme => 'Claro';
  @override
  String get darkTheme => 'Oscuro';
  @override
  String get systemTheme => 'Sistema';
  @override
  String get cameraPermissionDenied =>
      'Acceso a la cámara denegado. Permite el acceso para escanear ${global.qrCodes}.';
  @override
  String qrCodeReadingError(int current, int? total) =>
      'Error al leer el ${global.qrCode} ${global.indexRange(current, total)}';
  @override
  String get readBatchQrCodesAlert => 'Lee los ${global.qrCodes} en lote';
  @override
  String get copiedToClipboard => 'Copiado al portapapeles';
  @override
  String get selectQrStoreSize => 'Tamaño de almacenamiento del ${global.qrCode}';
}
