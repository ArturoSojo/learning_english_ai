import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/chat_query_service.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/google_tts_service.dart';
import 'package:english_words/english_words.dart' as ew;

class AiCallScreen extends StatefulWidget {
  const AiCallScreen({super.key});

  @override
  State<AiCallScreen> createState() => _AiCallScreenState();
}

class _Segment {
  final String text;
  final bool isEnglish;
  const _Segment(this.text, this.isEnglish);
}

class _AiCallScreenState extends State<AiCallScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final GoogleTtsService _googleTts = GoogleTtsService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _messages = [];
  bool _isListening = false;
  bool _showSubtitles = false;
  bool _professionalMode = false;
  bool _useFemaleVoice = true;
  double _soundLevel = 0;
  String _lastUserWords = '';
  Timer? _silenceTimer;
  Timer? _inactivityTimer;
  late AnimationController _controller;
  final ChatQueryService _chatService = ChatQueryService();
  final Set<String> _englishWords = {...ew.all};

  // Preferred voices for Spanish (LatAm) and English.
  // Fallback to neutral accents if specific voices are unavailable on device.
  final Map<String, String> _spanishFemaleVoice =
      const {'name': 'es-VE-Standard-A', 'locale': 'es-VE'};
  final Map<String, String> _spanishMaleVoice =
      const {'name': 'es-VE-Standard-B', 'locale': 'es-VE'};
  final Map<String, String> _englishFemaleVoice =
      const {'name': 'en-US-Wavenet-F', 'locale': 'en-US'};
  final Map<String, String> _englishMaleVoice =
      const {'name': 'en-US-Wavenet-D', 'locale': 'en-US'};

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
      lowerBound: 0.8,
      upperBound: 1.2,
    )..repeat(reverse: true);
    _initConversation();
  }

  Future<void> _initConversation() async {
    await _speech.initialize(
      onStatus: _statusListener,
      onError: (error) => _addMessage('Error: $error'),
    );
    _playCallSound();
    await speak('AI call started. How can I help you today?');
    _startListening();
    _resetInactivityTimer();
  }

  void _statusListener(String status) {
    if (status == 'notListening' && _isListening) {
      _processUserInput();
    }
  }

  Future<void> _startListening() async {
    _cancelSilenceTimer();
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastUserWords = result.recognizedWords;
          if (_lastUserWords.isNotEmpty) {
            _addMessage('You: $_lastUserWords');
          }
        }
        _resetTimers();
      },
      onSoundLevelChange: (level) {
        setState(() => _soundLevel = level);
        _resetTimers();
      },
      listenFor: const Duration(minutes: 5),
      localeId: 'en-US',
    );
    setState(() => _isListening = true);
  }

  void _resetTimers() {
    _cancelSilenceTimer();
    _silenceTimer = Timer(const Duration(seconds: 3), _processUserInput);
    _resetInactivityTimer();
  }

  Future<void> _processUserInput() async {
    if (!_isListening) return;

    setState(() => _isListening = false);
    _speech.stop();

    if (_shouldEndCall()) {
      await _endCall();
      return;
    }

    try {
      final prompt = _professionalMode
          ? 'Please respond in a professional tone: $_lastUserWords'
          : _lastUserWords;
      final result = await _chatService.query(prompt);
      _addMessage('AI: ${result.answer}');
      await speak(result.answer);
    } catch (e) {
      _addMessage('AI: Error: ${e.toString()}');
      await speak('Sorry, an error occurred.');
    }

    _lastUserWords = '';
    _startListening();
  }

  bool _shouldEndCall() {
    final words = _lastUserWords.toLowerCase();
    return words.contains('bye') ||
        words.contains('goodbye') ||
        words.contains('end call') ||
        words.contains('terminate');
  }

  // Removed random response generation in favor of querying the AI service.

  bool _isEnglishWord(String word) {
    final clean = word.toLowerCase().replaceAll(RegExp(r'[^a-z]'), '');
    if (clean.isEmpty) return false;
    return _englishWords.contains(clean);
  }

  List<_Segment> _segmentText(String text) {
    final tokens = text.split(RegExp(r'(\s+)'));
    final segments = <_Segment>[];
    final buffer = StringBuffer();
    bool? currentEnglish;

    for (final token in tokens) {
      final isEnglish = _isEnglishWord(token);
      if (currentEnglish == null || isEnglish != currentEnglish) {
        if (buffer.isNotEmpty) {
          segments.add(_Segment(buffer.toString(), currentEnglish ?? false));
          buffer.clear();
        }
        currentEnglish = isEnglish;
      }
      buffer.write(token);
    }

    if (buffer.isNotEmpty) {
      segments.add(_Segment(buffer.toString(), currentEnglish ?? false));
    }

    return segments;
  }

  Future<void> speak(String text) async {
    final segments = _segmentText(text);
    for (final seg in segments) {
      final voice = seg.isEnglish
          ? (_useFemaleVoice ? _englishFemaleVoice : _englishMaleVoice)
          : (_useFemaleVoice ? _spanishFemaleVoice : _spanishMaleVoice);
      final bytes = await _googleTts.synthesize(
        text: seg.text.trim(),
        voice: voice['name']!,
        languageCode: voice['locale']!,
      );
      await _audioPlayer.play(BytesSource(bytes));
      await _audioPlayer.onPlayerComplete.first;
    }
  }

  void _playCallSound() {
    SystemSound.play(SystemSoundType.alert);
  }

  void _addMessage(String message) {
    setState(() => _messages.add(message));
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 60), _endCall);
  }

  void _cancelSilenceTimer() {
    _silenceTimer?.cancel();
  }

  Future<void> _endCall() async {
    _cancelSilenceTimer();
    _inactivityTimer?.cancel();
    _speech.stop();
    _playCallSound();
    await speak('Call ended. Have a nice day!');
    if (mounted) Navigator.pop(context);
  }

  void _toggleListening() => _isListening ? _speech.stop() : _startListening();

  void _toggleProfessionalMode() {
    setState(() => _professionalMode = !_professionalMode);
  }

  void _toggleVoice() {
    setState(() => _useFemaleVoice = !_useFemaleVoice);
  }

  void _toggleSubtitles() {
    setState(() => _showSubtitles = !_showSubtitles);
  }

  @override
  void dispose() {
    _speech.stop();
    _audioPlayer.dispose();
    _silenceTimer?.cancel();
    _inactivityTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('AI English Conversation'),
        actions: [
          IconButton(
            icon: Icon(_showSubtitles ? Icons.subtitles : Icons.subtitles_off),
            onPressed: _toggleSubtitles,
          ),
          IconButton(
            icon: Icon(_professionalMode ? Icons.work : Icons.cases),
            onPressed: _toggleProfessionalMode,
          ),
          IconButton(
            icon: Icon(_useFemaleVoice ? Icons.female : Icons.male),
            onPressed: _toggleVoice,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _controller,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: 120 + _soundLevel * 3,
              height: 120 + _soundLevel * 3,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.1),
                    theme.colorScheme.primary.withOpacity(0.3),
                  ],
                ),
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_off,
                size: 50,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _showSubtitles
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final isUser = _messages[index].startsWith('You:');
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isUser
                                ? theme.colorScheme.primary
                                : theme.colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _messages[index]
                                .replaceFirst('You: ', '')
                                .replaceFirst('AI: ', ''),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUser
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Lottie.asset(
                      'assets/lotties/Wave_Loop.json',
                      fit: BoxFit.contain,
                      repeat: true,
                      animate: true,
                      frameRate: FrameRate.max,
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        backgroundColor:
            _isListening ? theme.colorScheme.primary : theme.colorScheme.error,
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: theme.colorScheme.onPrimary,
        ),
      ),
    );
  }
}
