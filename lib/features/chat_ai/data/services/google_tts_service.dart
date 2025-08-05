import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// Service that wraps Google Cloud Text-to-Speech API.
/// It requires the environment variable `GOOGLE_TTS_API_KEY` to be set.
class GoogleTtsService {
  final String _apiKey = dotenv.env['GOOGLE_TTS_API_KEY'] ?? '';

  /// Synthesizes [text] into speech using the provided [voice] and [languageCode].
  /// Returns the audio content as raw bytes in MP3 format.
  Future<Uint8List> synthesize({
    required String text,
    required String voice,
    required String languageCode,
  }) async {
    final uri = Uri.parse(
        'https://texttospeech.googleapis.com/v1/text:synthesize?key=$_apiKey');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({
        'input': {'text': text},
        'voice': {
          'languageCode': languageCode,
          'name': voice,
        },
        'audioConfig': {'audioEncoding': 'MP3'},
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('TTS request failed: ${response.body}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final audioContent = data['audioContent'] as String;
    return base64.decode(audioContent);
  }
}
