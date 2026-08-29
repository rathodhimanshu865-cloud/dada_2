import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class TranslationService {
  // Use a free translation API or a simulated one if no key is provided.
  // For production, replace with Google Cloud Translation or LibreTranslate.
  
  static Future<Map<String, String>> translateToAll(String text) async {
    if (text.trim().isEmpty) return {'hi': '', 'gu': ''};
    
    try {
      // Fast simulation/Batch request logic would go here.
      // For now, we use a public free API (MyMemory) for individual strings.
      final hi = await translate(text, 'hi');
      final gu = await translate(text, 'gu');
      return {'hi': hi, 'gu': gu};
    } catch (e) {
      return {'hi': text, 'gu': text};
    }
  }

  static Future<String> translate(String text, String targetLang) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.mymemory.translated.net/get?q=${Uri.encodeComponent(text)}&langpair=en|$targetLang'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['responseData']['translatedText'] ?? text;
      }
    } catch (_) {}
    return text;
  }

  static Future<List<String>> translateBatch(List<String> texts, String targetLang) async {
    if (texts.isEmpty) return [];
    // MyMemory doesn't support batch, so we process in parallel for speed
    final results = await Future.wait(texts.map((t) => translate(t, targetLang)));
    return results;
  }
}
