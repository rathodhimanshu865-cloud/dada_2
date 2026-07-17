import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  Locale _locale;

  Locale get locale => _locale;

  LanguageController(String initialLanguageCode)
      : _locale = Locale(initialLanguageCode);

  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }
}
