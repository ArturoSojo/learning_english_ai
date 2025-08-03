import 'dart:math';

import 'package:flutter/material.dart';
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
    await _speech.initialize(onStatus: _statusListener);
    await _tts.setLanguage('en-US');
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setVoice({'name': 'en-us-x-sfg#female-1', 'locale': 'en-US'});
    _startListening();
  }

  void _statusListener(String status) {
    if (status == 'notListening') {
      _respond();
    }
  }

  Future<void> _startListening() async {
    await _speech.listen(
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.isNotEmpty) {
          setState(() {
            _messages.add('Me: ${result.recognizedWords}');
          });
        }
      },
      pauseFor: const Duration(seconds: 2),
      listenFor: const Duration(seconds: 10),
      localeId: 'en_US',
    );
    setState(() => _isListening = true);
  }

  Future<void> _respond() async {
    if (!_isListening) return;
    setState(() => _isListening = false);
    const responses = [
      'Hello, how can I help you?',
      'Nice to talk with you.',
      'Can you tell me more?',
      'I am here to assist you.',
      'Let\'s practice English together.',
    ];
    final reply = responses[Random().nextInt(responses.length)];
    setState(() {
      _messages.add('AI: $reply');
    });
    await _tts.speak(reply);
    _startListening();
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
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
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ScaleTransition(
            scale: _controller,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: colorScheme.primary.withOpacity(0.2),
              child: Icon(
                _isListening ? Icons.hearing : Icons.hearing_disabled,
                color: colorScheme.primary,
                size: 60,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
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
                      text.replaceFirst('Me: ', '').replaceFirst('AI: ', ''),
                      style: TextStyle(
                        color: isMe ? Colors.white : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

