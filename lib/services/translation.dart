import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  Future<String> translateToTurkish(String text) async {
    final url = Uri.parse('https://libretranslate.de/translate');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "q": text,
          "source": "en",
          "target": "tr",
          "format": "text",
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['translatedText'] ?? text;
      }

      return text;
    } catch (e) {
      print("Çeviri hatası: $e");
      return text;
    }
  }
}
