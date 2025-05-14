import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../entities/qr_recovery_data_level.dart';
import 'app_consts.dart';
import 'app_settings.dart';

abstract final class Utils {
  static List<String> generateQrCodes(
    String inputText,
    QrRecoveryDataLevel level,
    int qrStoreSize,
  ) {
    final qrCodes = <String>[];
    final chunkSize = level.chunkSize(qrStoreSize);
    final totalChunks = (inputText.length / chunkSize).ceil();

    for (int i = 0; i < totalChunks; i++) {
      final start = i * chunkSize;

      final end = min((i + 1) * chunkSize, inputText.length);
      final header = qrCodeHeader(i, totalChunks);
      final chunk = inputText.substring(start, end);

      qrCodes.add(header + chunk);
    }
    return qrCodes;
  }

  static const _places = 2;
  static const _radix = 16;
  static final _qrCodesTotalLimit = pow(_radix, _places).toInt() - 1;
  static final _defaultQrCodeHeader = qrCodeHeader(1, 2);

  static String qrCodeHeader(int currentPosition, int totalPosition) {
    if (totalPosition <= 1) return '';

    if (totalPosition > _qrCodesTotalLimit) totalPosition = _qrCodesTotalLimit;

    final index = currentPosition.toRadixString(_radix).padLeft(_places, '0').substring(0, _places);
    final total = totalPosition.toRadixString(_radix).padLeft(_places, '0').substring(0, _places);
    return '${AppConsts.batchQrId}$index$total'.toUpperCase();
  }

  static ({int index, int total, String content})? decodeQrCodeHeader(
    String content, [
    VoidCallback? onError,
  ]) {
    try {
      assert(content.length >= _defaultQrCodeHeader.length);

      final header = content.replaceFirst(AppConsts.batchQrId, '').substring(0, _places * 2);
      content = content.substring(AppConsts.batchQrId.length + (_places * 2));

      final index = int.parse(header.substring(0, _places), radix: _radix);
      final total = int.parse(header.substring(_places), radix: _radix);

      return (index: index, total: total, content: content);
    } catch (_) {
      return null;
    }
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> notify(
    String text, [
    BuildContext? context,
  ]) => ScaffoldMessenger.of(
    context ?? AppSettings.globalScaffoldKey.currentContext!,
  ).showSnackBar(SnackBar(content: Text(text)));

  static Future<T?> open<T>(String route, [Object? args]) {
    return Navigator.pushNamed<T>(
      AppSettings.globalNavigationKey.currentContext!,
      route,
      arguments: args,
    );
  }

  static void pop<T>([T? result]) {
    Navigator.pop<T>(AppSettings.globalNavigationKey.currentContext!, result);
  }

  static Future<void> copyToClipboard(String text) => Clipboard.setData(ClipboardData(text: text));

  /// Returns an object that paints a [TextSpan] tree into a [Canvas].
  ///
  /// [context] is optional to get current [MediaQueryData] of app (used to set [direction],
  /// [textScaler] and [locale]).
  ///
  /// Tip: can be used [TextPainter.computeLineMetrics] to get metrics from each line (e.g. size).
  static TextPainter textPainter({
    String? text,
    BuildContext? context,
    InlineSpan? inlineSpan,
    TextStyle? style,
    int? maxLines,
    double minWidth = 0,
    double maxWidth = double.infinity,
    TextDirection? direction,
    TextScaler? textScaler,
    TextAlign textAlign = TextAlign.start,
    Locale? locale,
    String? ellipsis,
    StrutStyle? strutStyle,
    TextHeightBehavior? textHeightBehavior,
    TextWidthBasis textWidthBasis = TextWidthBasis.parent,
  }) {
    T? maybeOf<T>(T? Function(BuildContext context) onContext) =>
        context == null ? null : onContext(context);

    final textPainter = TextPainter(
      text: inlineSpan ?? TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: maybeOf(Directionality.of) ?? direction ?? TextDirection.ltr,
      textScaler:
          maybeOf((ctx) => MediaQuery.of(ctx).textScaler) ?? textScaler ?? TextScaler.noScaling,
      textAlign: textAlign,
      locale: maybeOf(Localizations.maybeLocaleOf) ?? locale,
      ellipsis: ellipsis,
      strutStyle: strutStyle,
      textHeightBehavior: textHeightBehavior,
      textWidthBasis: textWidthBasis,
    )..layout(minWidth: minWidth, maxWidth: maxWidth);
    return textPainter;
  }
}
