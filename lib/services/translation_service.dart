import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Free Google Translate service — no API key required.
/// Uses the unofficial `translate.googleapis.com` endpoint.
/// On "Translate & Publish", all text fields are translated once and stored in Firestore.
class TranslationService {
  static const List<String> _targetLangs = ['hi', 'gu'];

  /// Translate a single text string to [targetLang] (e.g. 'hi', 'gu').
  /// Returns the original text on failure.
  static Future<String> translateText(String text, String targetLang) async {
    if (text.trim().isEmpty) return text;
    try {
      final encodedText = Uri.encodeComponent(text);
      final url = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=en&tl=$targetLang&dt=t&q=$encodedText',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Response: [[[translated, original, ...], ...], ...]
        final translatedParts = (decoded[0] as List)
            .map((part) => (part as List).first.toString())
            .join('');
        return translatedParts.isNotEmpty ? translatedParts : text;
      }
    } catch (e) {
      debugPrint('TranslationService error ($targetLang): $e');
    }
    return text;
  }

  /// Translate a list of texts to [targetLang] sequentially.
  static Future<List<String>> translateBatch(
      List<String> texts, String targetLang) async {
    final results = <String>[];
    for (final t in texts) {
      results.add(await translateText(t, targetLang));
      // Small delay to avoid rate-limiting
      await Future.delayed(const Duration(milliseconds: 200));
    }
    return results;
  }

  /// Translate a single text to BOTH Hindi and Gujarati.
  /// Returns a map: {'en': original, 'hi': hindi, 'gu': gujarati}
  static Future<Map<String, String>> translateToAll(String englishText) async {
    if (englishText.trim().isEmpty) {
      return {'en': englishText, 'hi': '', 'gu': ''};
    }
    final hi = await translateText(englishText, 'hi');
    final gu = await translateText(englishText, 'gu');
    return {'en': englishText, 'hi': hi, 'gu': gu};
  }

  /// Translate all fields of a flat map that contain non-empty String values.
  /// [translatableKeys] = the list of field names that should be translated.
  /// Returns a new map containing the original fields PLUS `_hi` and `_gu` variants.
  static Future<Map<String, dynamic>> translateMap(
    Map<String, dynamic> sourceMap,
    List<String> translatableKeys,
  ) async {
    final result = Map<String, dynamic>.from(sourceMap);
    for (final key in translatableKeys) {
      final value = sourceMap[key];
      if (value is String && value.trim().isNotEmpty) {
        for (final lang in _targetLangs) {
          result['${key}_$lang'] = await translateText(value, lang);
          await Future.delayed(const Duration(milliseconds: 150));
        }
      }
    }
    return result;
  }
}
