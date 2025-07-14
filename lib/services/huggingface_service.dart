import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class HuggingFaceService {
  final String apiKey = dotenv.env['HUGGINGFACE_API_KEY'] ?? '';

  // Kullanılabilir ve inference API'si açık bir model
  final String model = 'google/medgemma-27b-text-it';

  Future<String> sendMessage(String prompt) async {
    if (apiKey.isEmpty) {
      return 'API anahtarı bulunamadı. .env dosyasını kontrol edin.';
    }

    final String apiUrl = 'https://api-inference.huggingface.co/models/$model';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'inputs': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data is List &&
            data.isNotEmpty &&
            data[0]['generated_text'] != null) {
          return data[0]['generated_text'];
        } else if (data is Map && data.containsKey('error')) {
          return 'API Hatası: ${data['error']}';
        } else if (data is String) {
          return data;
        } else {
          return 'Yanıt alınamadı.';
        }
      } else if (response.statusCode == 404) {
        return 'Model bulunamadı. Model adını kontrol edin.';
      } else if (response.statusCode == 403) {
        return 'API erişim reddedildi. API anahtarınızı ve izinleri kontrol edin.';
      } else {
        return 'API Hatası: ${response.statusCode}';
      }
    } catch (e) {
      return 'İstek sırasında hata oluştu: $e';
    }
  }
}
