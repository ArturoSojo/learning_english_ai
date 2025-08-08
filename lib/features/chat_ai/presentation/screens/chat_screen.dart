import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/home_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/chat_stream_service.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ChatStreamService _chatService = ChatStreamService();
  final SpeechToText _speech = SpeechToText();

  List<ChatMessage> _messages = [];
  bool _isListening = false;
  bool _isTyping = false;
  String _currentTypingText = '';

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    await _speech.initialize();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: DateTime.now().toString(),
      message: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final aiMsg = ChatMessage(
      id: DateTime.now().toString(),
      message: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMsg);
      _messages.insert(0, aiMsg);
      _isTyping = true;
      _currentTypingText = '';
    });

    final buffer = StringBuffer();

    _chatService.queryStream(text).listen(
      (chunk) {
        buffer.write(chunk);
        setState(() {
          _currentTypingText = buffer.toString();
          _messages[0] = aiMsg.copyWith(message: _currentTypingText);
        });
      },
      onDone: () {
        setState(() => _isTyping = false);
      },
      onError: (error) {
        setState(() {
          _messages[0] = aiMsg.copyWith(message: 'Error: ${error.toString()}');
          _isTyping = false;
        });
      },
    );

    _scrollToBottom();
  }

  void _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    final available = await _speech.initialize();
    if (!available) return;

    setState(() => _isListening = true);

    _speech.listen(
      localeId: 'en_US',
      listenFor: const Duration(seconds: 5),
      onResult: (result) {
        if (result.finalResult && result.recognizedWords.trim().isNotEmpty) {
          setState(() => _isListening = false);
          _sendMessage(result.recognizedWords.trim());
        }
      },
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _speech.stop();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Lottie.asset('assets/lotties/AI.json', width: 40, height: 40),
            const SizedBox(width: 8),
            const Text('AI Tutor'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => setState(() => _messages.clear()),
          )
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                // Mostrar Lottie si mensaje AI está cargando
                if (!msg.isUser && msg.message.isEmpty) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Lottie.asset(
                      'assets/lotties/Loading.json',
                      width: 140,
                      height: 100,
                    ),
                  );
                }

                return ChatMessageBubble(
                  message: msg.message,
                  isUser: msg.isUser,
                  bubbleColor: msg.isUser
                      ? theme.colorScheme.secondary
                      : theme.colorScheme.primary,
                );
              },
            ),
          ),
          if (_isTyping && _currentTypingText.isNotEmpty)
            _AnimatedTypingText(
              text: _currentTypingText,
              bubbleColor: theme.colorScheme.primary,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _isListening ? Icons.stop : Icons.mic,
                    color: theme.colorScheme.primary,
                  ),
                  onPressed: _toggleListening,
                ),
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Type something to learn...',
                      fillColor: theme.colorScheme.surfaceVariant,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (value) {
                      _sendMessage(value);
                      _textController.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primary,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: () {
                      _sendMessage(_textController.text);
                      _textController.clear();
                    },
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _AnimatedTypingText extends StatefulWidget {
  final String text;
  final Color bubbleColor;

  const _AnimatedTypingText({
    required this.text,
    required this.bubbleColor,
  });

  @override
  State<_AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<_AnimatedTypingText>
    with SingleTickerProviderStateMixin {
  String _displayedText = '';
  int _charIndex = 0;

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  void _startTyping() async {
    for (int i = 0; i <= widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 800));
      if (!mounted) return;
      setState(() {
        _displayedText = widget.text.substring(0, i);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChatMessageBubble(
      message: _displayedText,
      isUser: false,
      bubbleColor: widget.bubbleColor,
    );
  }
}
