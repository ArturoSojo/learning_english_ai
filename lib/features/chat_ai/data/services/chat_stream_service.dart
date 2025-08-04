import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatStreamService {
  final http.Client _client;

  ChatStreamService({http.Client? client}) : _client = client ?? http.Client();

  Stream<String> queryStream(String message) async* {
    final request = http.Request(
      'POST',
      Uri.parse('https://ww68wbbt-8888.euw.devtunnels.ms/api/v1/rag/query-stream'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': '0GRkN3gPg81DYsLhxeIzar1t',
      })
      ..body = jsonEncode({
        'message': message,
        'bot_id': '6886d2b8cbc07515ccb33a2a',
      });

    try {
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        throw http.ClientException('Failed with status: ${response.statusCode}');
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }
}
