import 'base_translation.dart';

class TranslationPtBr extends BaseTranslation {
  @override
  String get appTitle => 'Gerador de ${global.qrCodes} em Lote';
  @override
  String get qrCodeGenerator => 'Gerador de ${global.qrCodes}';
  @override
  String generatedQrCodes(int total) => '${global.qrCodes} Gerados ($total)';
  @override
  String get theme => 'Tema';
  @override
  String get language => 'Idioma';
  @override
  String get selectErrorLevel => 'Selecione o nível de correção de erro';
  @override
  String get lightTheme => 'Claro';
  @override
  String get darkTheme => 'Escuro';
  @override
  String get systemTheme => 'Sistema';
  @override
  String get cameraPermissionDenied =>
      'Acesso à câmera negado. Permita o acesso para escanear ${global.qrCodes}.';
  @override
  String qrCodeReadingError(int current, int? total) =>
      'Erro ao ler ${global.qrCode} ${global.indexRange(current, total)}';
  @override
  String get readBatchQrCodesAlert => 'Leia os ${global.qrCodes} em lote';
  @override
  String get copiedToClipboard => 'Copiado para a área de transferência';
  @override
  String get selectQrStoreSize => 'Tamanho de armazenamento do ${global.qrCode}';
}
