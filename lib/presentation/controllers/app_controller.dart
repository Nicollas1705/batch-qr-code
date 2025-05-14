import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_consts.dart';
import '../../core/app_settings.dart';
import '../../core/helpers/internal_notifiers.dart';
import '../../core/i18n/lang.dart';

class AppController extends InternalNotifiers {
  AppController() {
    _loadPreferences();
    _setListeners();
  }

  final _themeMode = ValueNotifier(AppSettings.defaultThemeMode);
  final _lang = ValueNotifier(AppSettings.defaultLanguage);
  final _themeColor = ValueNotifier(AppSettings.defaultAppColor);
  late final SharedPreferences _prefs;

  @override
  List<ValueNotifier> get internalNotifiers => [_themeMode, _lang, _themeColor];

  ThemeMode get themeMode => _themeMode.value;
  Lang get lang => _lang.value;
  Color get themeColor => _themeColor.value;

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();

    final themeModeStored = _prefs.getString(AppConsts.themeMode);
    if (themeModeStored != null && themeModeStored.isNotEmpty) {
      _themeMode.value = ThemeMode.values.firstWhere(
        (mode) => mode.name == themeModeStored,
        orElse: () => AppSettings.defaultThemeMode,
      );
    }

    final langStored = _prefs.getString(AppConsts.language);
    if (langStored != null && langStored.isNotEmpty) {
      _lang.value = Lang.values.firstWhere(
        (lang) => lang.name == langStored,
        orElse: () => AppSettings.defaultLanguage,
      );
    }

    final themeColorStored = _prefs.getString(AppConsts.themeColor);
    if (themeColorStored != null && themeColorStored.isNotEmpty) {
      final intColor = int.tryParse(themeColorStored);
      if (intColor != null) {
        _themeColor.value = Color(intColor);
      }
    }
  }

  void _setListeners() {
    _themeMode.addListener(() {
      _updatePreference(AppConsts.themeMode, _themeMode.value.name);
    });

    _lang.addListener(() {
      _updatePreference(AppConsts.language, _lang.value.name);
    });

    _themeColor.addListener(() {
      _updatePreference(AppConsts.themeColor, _themeColor.value.toARGB32().toString());
    });
  }

  Future<bool> _updatePreference(String prefKey, String newValue) =>
      _prefs.setString(prefKey, newValue);

  void updateThemeMode(ThemeMode mode) => _themeMode.value = mode;

  void updateLang(Lang lang) => _lang.value = lang;

  void updateThemeColor(Color themeColor) => _themeColor.value = themeColor;
}
