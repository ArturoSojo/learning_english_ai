import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
  bool _isListening = false;
  List<ChatMessage> _messages = [];

  final ChatStreamService _chatService = ChatStreamService();

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
    });

    final buffer = StringBuffer();

    _chatService.queryStream(text).listen(
      (chunk) {
        buffer.write(chunk);
        setState(() {
          _messages[0] = aiMsg.copyWith(message: buffer.toString());
        });
      },
      onError: (error) {
        setState(() {
          _messages[0] = aiMsg.copyWith(message: 'Error: ${error.toString()}');
        });
      },
    );
  }

  void _toggleListening() {
    setState(() => _isListening = !_isListening);

    if (_isListening) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _isListening = false);
          _sendMessage("[Voice input] How do I pronounce \"apple\"?");
        }
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Lottie.asset(
              'assets/lotties/AI.json',
              width: 40,
              height: 40,
            ),
          
            Text(' AI Tutor'),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(
              context, MaterialPageRoute(builder: (_) => const HomeScreen())),
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
              reverse: true,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];

                // Si el mensaje es del AI y está vacío => mostrar Lottie de carga
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

                // Si el mensaje es del AI y tiene texto => animar con efecto "máquina de escribir"
                if (!msg.isUser) {
                  return _AnimatedTypingText(
                    text: msg.message,
                    bubbleColor: theme.colorScheme.primary,
                  );
                }

                // Mensajes del usuario normales
                return ChatMessageBubble(
                  message: msg.message,
                  isUser: msg.isUser,
                  bubbleColor: theme.colorScheme.secondary,
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
                      color: theme.colorScheme.primary),
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

/// Widget para animar texto como si fuera máquina de escribir
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
      await Future.delayed(const Duration(milliseconds: 30));
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
