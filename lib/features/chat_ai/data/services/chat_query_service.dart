import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatQueryService {
  final http.Client _client;
  String? _sessionId;

  ChatQueryService({http.Client? client}) : _client = client ?? http.Client();

  Future<QueryResponse> query(String message) async {
    final Map<String, dynamic> body = {
      'message': message,
      'bot_id': '6886d2b8cbc07515ccb33a2a',
    };

    if (_sessionId != null && _sessionId!.isNotEmpty) {
      body['session_id'] = _sessionId;
    }

    final response = await _client.post(
      Uri.parse('https://dapi.pulbot.store/api/v1/rag/query'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': '0GRkN3gPg81DYsLhxeIzar1t',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode != 200) {
      throw http.ClientException('Failed with status: ${response.statusCode}');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    final answer = data['data']?['answer'] as String? ?? '';
    final sessionId = data['data']?['session_id'] as String? ?? '';
    if (sessionId.isNotEmpty) {
      _sessionId = sessionId;
    }
    return QueryResponse(answer: answer, sessionId: sessionId);
  }
}

class QueryResponse {
  final String answer;
  final String sessionId;

  QueryResponse({required this.answer, required this.sessionId});
}

