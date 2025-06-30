import 'package:speech_to_text/speech_recognition_result.dart' as stt;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_speech/text_to_speech.dart';

class VoiceService {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  final TextToSpeech _textToSpeech = TextToSpeech();
  bool _isListening = false;

  Future<bool> initialize() async {
    return await _speechToText.initialize();
  }

  Future<String?> listen() async {
    if (_isListening) return null;
    
    String? result;
    _isListening = true;
    
    await _speechToText.listen(
      onResult: (stt.SpeechRecognitionResult recognition) {
        if (recognition.finalResult) {
          result = recognition.recognizedWords;
          _isListening = false;
        }
      },
    );

    while (_isListening) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return result;
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
  }

  Future<void> speak(String text) async {
    await _textToSpeech.speak(text);
  }

  void stopSpeaking() {
    _textToSpeech.stop();
  }
}