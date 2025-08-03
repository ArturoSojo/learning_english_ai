import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';

class AiCallScreen extends StatefulWidget {
  const AiCallScreen({super.key});

  @override
  State<AiCallScreen> createState() => _AiCallScreenState();
}

class _AiCallScreenState extends State<AiCallScreen>
    with SingleTickerProviderStateMixin {
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final List<String> _messages = [
    'AI: Hi! I\'m ready for our English call.',
  ];
  bool _isListening = false;
  bool _showSubtitles = true;
  bool _professionalMode = false;
  bool _useFemaleVoice = true;
  double _soundLevel = 0;
  String _lastUserWords = '';
  Timer? _inactivityTimer;
  late AnimationController _controller;

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
      onError: (error) {
        setState(() {
          _messages.add('AI: $error');
        });
      },
    );
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _updateVoice();
    SystemSound.play(SystemSoundType.alert);
    await _speak('Llamada con IA iniciada. ¿En qué puedo ayudarte hoy?');
    _startListening();
    _resetInactivityTimer();
  }

  void _statusListener(String status) {
    if (status == 'notListening') {
      _processUserInput();
    }
  }

  Future<void> _startListening() async {
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _lastUserWords = result.recognizedWords;
          if (_lastUserWords.isNotEmpty) {
            setState(() {
              _messages.add('Me: $_lastUserWords');
            });
          }
        }
        _resetInactivityTimer();
      },
      onSoundLevelChange: (level) {
        setState(() {
          _soundLevel = level;
        });
      },
      pauseFor: const Duration(seconds: 3),
      listenFor: const Duration(minutes: 1),
      localeId: 'en_US',
    );
    setState(() => _isListening = true);
  }

  Future<void> _processUserInput() async {
    if (!_isListening) return;
    setState(() => _isListening = false);
    if (_lastUserWords.isEmpty) {
      await _speak('No te entendí. ¿Puedes repetir?');
      _startListening();
      return;
    }
    if (_lastUserWords.toLowerCase().contains('adiós') ||
        _lastUserWords.toLowerCase().contains('terminar') ||
        _lastUserWords.toLowerCase().contains('bye')) {
      await _endCall();
      return;
    }

    final casualResponses = [
      'Um, hello, how can I help you?',
      'Ah, nice to talk with you.',
      'Hmm, can you tell me more?',
      'I am here to assist you.',
      'Let\'s practice English together.',
    ];
    final professionalResponses = [
      'Hello, how can I help you?',
      'It is a pleasure to talk with you.',
      'Could you provide more details?',
      'I am here to assist you.',
      'Let\'s practice English together.',
    ];
    final responses =
        _professionalMode ? professionalResponses : casualResponses;
    final reply = responses[Random().nextInt(responses.length)];
    await Future.delayed(
        Duration(seconds: 1 + Random().nextInt(2))); // natural delay
    setState(() {
      _messages.add('AI: $reply');
    });
    await _speak(reply);
    _lastUserWords = '';
    _startListening();
    _resetInactivityTimer();
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> _updateVoice() async {
    await _tts.setVoice({
      'name': _useFemaleVoice
          ? 'en-us-x-sfg#female-1'
          : 'en-us-x-tpd#male-1',
      'locale': 'en-US'
    });
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(seconds: 60), () {
      _endCall();
    });
  }

  Future<void> _endCall() async {
    _inactivityTimer?.cancel();
    SystemSound.play(SystemSoundType.alert);
    await _speak('Llamada finalizada. ¡Que tengas un buen día!');
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  void _toggleListening() {
    if (_isListening) {
      _speech.stop();
    } else {
      _startListening();
    }
  }

  void _toggleProfessionalMode() {
    setState(() => _professionalMode = !_professionalMode);
  }

  void _toggleVoice() {
    setState(() => _useFemaleVoice = !_useFemaleVoice);
    _updateVoice();
  }

  void _toggleSubtitles() {
    setState(() => _showSubtitles = !_showSubtitles);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _inactivityTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('AI Voice Call'),
        backgroundColor: colorScheme.background,
        actions: [
          IconButton(
            icon: Icon(
              _showSubtitles
                  ? Icons.closed_caption
                  : Icons.closed_caption_off,
            ),
            onPressed: _toggleSubtitles,
          ),
          IconButton(
            icon: Icon(
              _professionalMode ? Icons.work : Icons.record_voice_over,
            ),
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
              duration: const Duration(milliseconds: 200),
              width: 120 + _soundLevel * 2,
              height: 120 + _soundLevel * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colorScheme.primary.withOpacity(0.2),
              ),
              child: Icon(
                _isListening ? Icons.hearing : Icons.hearing_disabled,
                color: colorScheme.primary,
                size: 60,
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
                      final text = _messages[index];
                      final isMe = text.startsWith('Me:');
                      return Align(
                        alignment:
                            isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isMe
                                ? colorScheme.primary
                                : colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            text
                                .replaceFirst('Me: ', '')
                                .replaceFirst('AI: ', ''),
                            style: TextStyle(
                              color:
                                  isMe ? Colors.white : colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _toggleListening,
        child: Icon(_isListening ? Icons.mic_off : Icons.mic),
      ),
    );
  }
}

