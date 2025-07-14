import 'dart:convert';
import 'package:http/http.dart' as http;

class GeminiService {
  static const String _apiKey =
      'yourkey'; // 🔑 Buraya kendi API anahtarını ekle
  static const String _url =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini:generateContent?key=$_apiKey';

  Future<String> sendMessage(String prompt) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
            ],
          },
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final reply = data['candidates'][0]['content']['parts'][0]['text'];
      return reply;
    } else {
      throw Exception('Gemini API hatası: ${response.body}');
    }
  }
}
