// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

import '../app_settings.dart';
import 'base_translation.dart';
import 'translation_en_us.dart';
import 'translation_es.dart';
import 'translation_pt_br.dart';

enum Lang {
  pt_BR,
  en_US,
  es;

  Locale get toLocale {
    final splitted = name.split('_');
    final country = splitted.length > 1 ? splitted.last : null;
    return Locale(splitted.first, country);
  }

  static Lang fromLocale(Locale locale) => Lang.values.firstWhere(
    (mode) => mode.name == [locale.languageCode, locale.countryCode].join('_'),
    orElse: () => AppSettings.defaultLanguage,
  );
}

extension LangExtension on Lang {
  BaseTranslation get translation => switch (this) {
    Lang.pt_BR => TranslationPtBr(),
    Lang.en_US => TranslationEnUs(),
    Lang.es => TranslationEs(),
  };
}
