import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatStreamService {
  final http.Client _client;
  String? sessionId; // Variable para almacenar el session_id

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
      });

    try {
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        throw http.ClientException('An error occurred, please try again later.');
      }

      // Captura el session_id de los headers
      final sessionIdFromResponse = response.headers['x-session-id'];
      if (sessionIdFromResponse != null) {
        sessionId = sessionIdFromResponse; // Almacena el session_id
      }

      await for (final chunk in response.stream.transform(utf8.decoder)) {
        yield chunk;
      }
    } catch (e) {
      throw Exception('Stream error: $e');
    }
  }

  // Método para enviar solicitudes adicionales con el session_id
  Future<http.Response> sendFollowUpRequest(String message) async {
    final request = http.Request(
      'POST',
      Uri.parse('https://dapi.pulbot.store/api/v1/rag/query-stream'),
    )
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': '0GRkN3gPg81DYsLhxeIzar1t',
        'X-Session-ID': sessionId ?? '', // Incluye el session_id en la solicitud
      })
      ..body = jsonEncode({
        'message': message,
        'bot_id': '68961f300f36ac73e8dff085',
        'session_id': sessionId ?? '', 
      });

    try {
      final response = await _client.send(request);
      if (response.statusCode != 200) {
        throw http.ClientException('An error occurred, please try again later.');
      }

      return await http.Response.fromStream(response);
    } catch (e) {
      throw Exception('Error sending follow-up request: $e');
    }
  }
}
