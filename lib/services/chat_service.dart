import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  static const String baseUrl = 'https://api.shizo.top/ai/gpt';
  static const String apiKey = 'shizo';

  static Future<String> sendMessage(String query) async {
    final uri = Uri.parse('$baseUrl?apikey=$apiKey&query=${Uri.encodeComponent(query)}');
    final response = await http.get(uri, headers: {'User-Agent': 'CoreAI-Flutter'});
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['msg'] ?? 'Aucune réponse';
    } else {
      throw Exception('Erreur API : ${response.statusCode}');
    }
  }
}
