import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
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
          _messages[0] =
              aiMsg.copyWith(message: 'Error: ${error.toString()}');
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
        title: const Text('English AI Tutor'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HomeScreen())),
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
                return ChatMessageBubble(
                  message: msg.message,
                  isUser: msg.isUser,
                  bubbleColor: msg.isUser ? theme.colorScheme.secondary : theme.colorScheme.primary,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(_isListening ? Icons.stop : Icons.mic, color: theme.colorScheme.primary),
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
