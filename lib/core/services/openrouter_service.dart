import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenRouterException implements Exception {
  final String message;
  final int? statusCode;

  const OpenRouterException(this.message, {this.statusCode});

  @override
  String toString() => 'OpenRouterException: $message';
}

class OpenRouterService {
  static const _baseUrl = 'https://openrouter.ai/api/v1';

  /// Sends the finished prompt to the model and returns the response text.
  /// Throws [OpenRouterException] on 401 (invalid key), 402 (insufficient
  /// credits), network errors, or unexpected response format.
  static Future<String> generate({
    required String apiKey,
    required String model,
    required String prompt,
  }) async {
    final uri = Uri.parse('$_baseUrl/chat/completions');
    final http.Response response;

    try {
      response = await http
          .post(
            uri,
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://github.com/kaijen/kailibrate',
              'X-Title': 'Kailibrate',
            },
            body: jsonEncode({
              'model': model,
              'messages': [
                {'role': 'user', 'content': prompt},
              ],
            }),
          )
          .timeout(const Duration(seconds: 90));
    } catch (e) {
      throw OpenRouterException('Netzwerkfehler: $e');
    }

    if (response.statusCode == 401) {
      throw const OpenRouterException('API-Key ungültig.',
          statusCode: 401);
    }
    if (response.statusCode == 402) {
      throw const OpenRouterException('Guthaben aufgebraucht.',
          statusCode: 402);
    }
    if (response.statusCode != 200) {
      throw OpenRouterException(
        'API-Fehler ${response.statusCode}: ${response.body}',
        statusCode: response.statusCode,
      );
    }

    final Map<String, dynamic> body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const OpenRouterException('Ungültige JSON-Antwort vom Server.');
    }

    final content =
        body['choices']?[0]?['message']?['content'] as String?;
    if (content == null) {
      throw const OpenRouterException('Antwort enthält keinen Inhalt.');
    }

    return content;
  }
}
