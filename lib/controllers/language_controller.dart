import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends ChangeNotifier {
  static const String _localeKey = 'selected_locale';
  Locale _locale;
  bool _isDisposed = false;

  void _safeNotifyListeners() {
    if (!_isDisposed) notifyListeners();
  }

  Locale get locale => _locale;

  LanguageController(String initialLanguageCode)
      : _locale = Locale(initialLanguageCode);

  Future<void> changeLanguage(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    _safeNotifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, locale.languageCode);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
