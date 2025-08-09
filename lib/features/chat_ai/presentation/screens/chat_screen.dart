import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/home_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/chat_query_service.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final SpeechToText _speech = SpeechToText();
  final ChatQueryService _chatService = ChatQueryService();

  List<ChatMessage> _messages = [];
  bool _isListening = false;

  // Estado para animación de tipeo
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
          0.0, // reverse:true → el “final” está en 0.0
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final now = DateTime.now();

    final userMsg = ChatMessage(
      id: now.millisecondsSinceEpoch.toString(),
      message: text,
      isUser: true,
      timestamp: now,
    );

    setState(() {
      // Insertamos el mensaje del usuario
      _messages.insert(0, userMsg);

      // Arrancamos modo “tipeo” (mostrará Lottie y luego animación)
      _isTyping = true;
      _currentTypingText = '';
    });

    _scrollToBottom();

    try {
      final result = await _chatService.query(text);

      // Guardamos el texto que se va a tipear (a 25ms/carácter)
      setState(() {
        _currentTypingText = result.answer;
      });
    } catch (error) {
      // Si hay error, mostramos el error con la animada (y luego queda estática)
      setState(() {
        _currentTypingText = '${error.toString()}';
      });
    }
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
              // +1 item si estamos tipeando para mostrar la animada/loader
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                // Si estamos tipeando y es el primer elemento → animada/loader
                if (_isTyping && index == 0) {
                  // Aún no llegó texto: mostrar loader
                  if (_currentTypingText.isEmpty) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Lottie.asset(
                        'assets/lotties/Loading.json',
                        width: 140,
                        height: 100,
                      ),
                    );
                  }
                  // Ya hay texto: mostrar animación tipo máquina de escribir
                  return _AnimatedTypingText(
                    text: _currentTypingText,
                    bubbleColor: theme.colorScheme.primary,
                    onFinish: () {
                      // Cuando termina la animación:
                      // 1) Inserta burbuja estática con el contenido final
                      // 2) Apaga el modo tipeo (remueve la animada)
                      final now = DateTime.now();
                      final aiMsg = ChatMessage(
                        id: (now.millisecondsSinceEpoch).toString(),
                        message: _currentTypingText,
                        isUser: false,
                        timestamp: now,
                      );
                      setState(() {
                        _messages.insert(0, aiMsg);
                        _isTyping = false;
                      });
                      _scrollToBottom();
                    },
                  );
                }

                // Si no es la animada, mapeamos al índice correcto de _messages
                final msgIndex = _isTyping ? index - 1 : index;
                final msg = _messages[msgIndex];

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
  final VoidCallback onFinish;

  const _AnimatedTypingText({
    required this.text,
    required this.bubbleColor,
    required this.onFinish,
  });

  @override
  State<_AnimatedTypingText> createState() => _AnimatedTypingTextState();
}

class _AnimatedTypingTextState extends State<_AnimatedTypingText> {
  String _displayedText = '';

  @override
  void initState() {
    super.initState();
    _startTyping();
  }

  Future<void> _startTyping() async {
    for (int i = 0; i <= widget.text.length; i++) {
      await Future.delayed(const Duration(milliseconds: 25));
      if (!mounted) return;
      setState(() {
        _displayedText = widget.text.substring(0, i);
      });
    }
    widget.onFinish();
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
