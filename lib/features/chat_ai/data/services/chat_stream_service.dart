import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatStreamService {
  final http.Client _client;
  String? _sessionId;

  ChatStreamService({http.Client? client}) : _client = client ?? http.Client();

  Stream<String> queryStream(String message) async* {
    final request = http.Request(
      'POST',
      Uri.parse('https://dapi.pulbot.store/api/v1/rag/query-stream'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': '0GRkN3gPg81DYsLhxeIzar1t',
      })
      ..body = jsonEncode({
        'message': message,
        'bot_id': '68961f300f36ac73e8dff085',
        if (_sessionId != null) 'session_id': _sessionId,
      });

    try {
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        throw http.ClientException('An error occurred, please try again later.');
      }

      // Capture session ID from headers if present
      final sessionId = response.headers['x-session-id'];
      if (sessionId != null && sessionId.isNotEmpty) {
        _sessionId = sessionId;
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }

  // Clear the stored session ID if needed
  void clearSession() {
    _sessionId = null;
  }
}