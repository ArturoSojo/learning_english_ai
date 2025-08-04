import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:lottie/lottie.dart';
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
  final Random _random = Random();

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
    await _configureTts();
    _playCallSound();
    await _speak('AI call started. How can I help you today?');
    _startListening();
    _resetInactivityTimer();
  }

  Future<void> _configureTts() async {
    await _tts.awaitSpeakCompletion(true);
    await _tts.setLanguage('en-US');
    await _tts.setPitch(_useFemaleVoice ? 1.1 : 0.9);
    await _tts.setSpeechRate(0.5);
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

    await Future.delayed(Duration(seconds: 1 + _random.nextInt(2)));
    await _generateRandomResponse();

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

  Future<void> _generateRandomResponse() async {
    final responses =
        _professionalMode ? _professionalResponses : _casualResponses;

    final reply = responses[_random.nextInt(responses.length)];
    _addMessage('AI: $reply');
    await _speak(reply);
  }

  final List<String> _casualResponses = [
    "That's interesting! Tell me more about it.",
    "I see what you mean. How does that make you feel?",
    "Wow, that's quite something!",
    "Let me think about that... Yes, I agree with you.",
    "Hmm, that's a good point you're making there.",
    "You know, I was just thinking about something similar!",
    "I'd love to hear more details about that.",
    "That reminds me of something I heard recently.",
    "Interesting perspective! Can you elaborate?",
    "I'm not entirely sure about that, but it sounds fascinating."
  ];

  final List<String> _professionalResponses = [
    "I understand your point. Could you provide more details?",
    "That's a valid observation. Let me analyze that.",
    "Thank you for sharing that information with me.",
    "Based on my analysis, I would suggest considering alternatives.",
    "That's an important aspect we should discuss further.",
    "I appreciate your input on this matter.",
    "Let me process that information and get back to you.",
    "That's a comprehensive view of the situation.",
    "I'll take that into consideration for our discussion.",
    "Your feedback is valuable for this conversation."
  ];

  Future<void> _speak(String text) async {
    await _tts.speak(text);
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
    await _speak('Call ended. Have a nice day!');
    if (mounted) Navigator.pop(context);
  }

  void _toggleListening() => _isListening ? _speech.stop() : _startListening();

  void _toggleProfessionalMode() {
    setState(() => _professionalMode = !_professionalMode);
  }

  void _toggleVoice() {
    setState(() => _useFemaleVoice = !_useFemaleVoice);
    _configureTts();
  }

  void _toggleSubtitles() {
    setState(() => _showSubtitles = !_showSubtitles);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
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
