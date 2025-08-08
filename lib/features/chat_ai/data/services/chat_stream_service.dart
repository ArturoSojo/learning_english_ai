import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChatStreamService {
  WebSocketChannel? _channel;
  String? _sessionId;

  void _ensureConnected() {
    _channel ??= WebSocketChannel.connect(
      Uri.parse('wss://dapi.pulbot.store/api/v1/rag/query-stream'),
      headers: {
        'X-API-Key': '0GRkN3gPg81DYsLhxeIzar1t',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  Stream<String> sendMessage(String message) {
    _ensureConnected();
    final payload = {
      'message': message,
      'bot_id': '68961f300f36ac73e8dff085',
    };
    if (_sessionId != null && _sessionId!.isNotEmpty) {
      payload['session_id'] = _sessionId;
    }
    _channel!.sink.add(jsonEncode(payload));

    return _channel!.stream.map((event) {
      try {
        final data = jsonDecode(event);
        final sessionIdFromResponse =
            data['data']?['session_id'] as String? ?? data['session_id'] as String?;
        if (sessionIdFromResponse != null && sessionIdFromResponse.isNotEmpty) {
          _sessionId = sessionIdFromResponse;
        }
        final answer = data['data']?['answer'] as String? ??
            data['answer'] as String? ??
            event.toString();
        return answer;
      } catch (_) {
        return event.toString();
      }
    });
  }

  void dispose() {
    _channel?.sink.close();
    _channel = null;
  }
}
