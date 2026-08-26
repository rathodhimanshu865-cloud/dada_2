import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

/// Free Google Translate service — no API key required.
/// Uses the unofficial `translate.googleapis.com` endpoint.
/// On "Translate & Publish", all text fields are translated once and stored in Firestore.
class TranslationService {

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

  /// Translate a single text to BOTH Hindi and Gujarati.
  /// Returns a map: {'en': original, 'hi': hindi, 'gu': gujarati}
  static Future<Map<String, String>> translateToAll(String englishText) async {
    if (englishText.trim().isEmpty) {
      return {'en': englishText, 'hi': '', 'gu': ''};
    }
    final results = await Future.wait([
      translateText(englishText, 'hi'),
      translateText(englishText, 'gu'),
    ]);
    return {'en': englishText, 'hi': results[0], 'gu': results[1]};
  }

  /// Translate a list of texts to [targetLang] concurrently in batches.
  static Future<List<String>> translateBatch(
      List<String> texts, String targetLang) async {
    final results = <String>[];
    const batchSize = 10; // Process 10 concurrent requests at a time
    for (int i = 0; i < texts.length; i += batchSize) {
      final end = (i + batchSize < texts.length) ? i + batchSize : texts.length;
      final batch = texts.sublist(i, end);
      final batchResults = await Future.wait(
        batch.map((t) => translateText(t, targetLang))
      );
      results.addAll(batchResults);
      // Small delay between batches to avoid rate-limiting
      if (end < texts.length) {
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
    return results;
  }

  /// Translate all fields of a flat map that contain non-empty String values.
  /// [translatableKeys] = the list of field names that should be translated.
  /// Returns a new map containing the original fields PLUS `_hi` and `_gu` variants.
  static Future<Map<String, dynamic>> translateMap(
    Map<String, dynamic> sourceMap,
    List<String> translatableKeys,
  ) async {
    final result = Map<String, dynamic>.from(sourceMap);
    final futures = <Future<void>>[];

    for (final key in translatableKeys) {
      final value = sourceMap[key];
      if (value is String && value.trim().isNotEmpty) {
        futures.add(Future(() async {
          final translatedHi = await translateText(value, 'hi');
          final translatedGu = await translateText(value, 'gu');
          result['${key}_hi'] = translatedHi;
          result['${key}_gu'] = translatedGu;
        }));
      }
    }
    
    // Process all fields in parallel
    await Future.wait(futures);
    return result;
  }
}
