import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/core/theme/app_theme.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/bloc/chat_ai_bloc.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/home_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:auto_route/annotations.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart'
    hide ChatMessage;

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
  bool _isDarkMode = false;

  // Mock responses for the AI
  final List<String> _mockResponses = [
    "That's an interesting question!",
    "I'd be happy to help with that.",
    "Could you clarify what you mean?",
    "In English, we would say it like this...",
    "Great question! Here's what I think...",
    "Let me think about that for a moment...",
    "The correct pronunciation would be...",
    "Here's an example sentence for you..."
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _sendMessage(String message) {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      isUser: true,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.insert(0, userMessage);
    });

    // Simulate AI thinking
    Future.delayed(const Duration(seconds: 1), () {
      // Generate mock AI response
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        message: _mockResponses[_messages.length % _mockResponses.length],
        isUser: false,
        timestamp: DateTime.now(),
      );

      setState(() {
        _messages.insert(0, aiMessage);
      });
    });
  }

  void _clearConversation() {
    setState(() {
      _messages.clear();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MaterialApp(
      theme: theme,
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HomeScreen(),
                  ),
                );
              } catch (e) {
                debugPrint("Error navegando: $e");
              }
            }, // Navega hacia atrás
          ),
          title: const Text('AI English Tutor'),
          actions: [
            IconButton(
              icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: _toggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _clearConversation,
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.05),
                theme.colorScheme.primary.withOpacity(0.01),
              ],
            ),
          ),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              return ChatMessageBubble(
                message: message.message,
                isUser: message.isUser,
                bubbleColor: message.isUser
                    ? theme.colorScheme.secondary
                    : theme.colorScheme.primary,
              );
            },
          ),
        ),
        floatingActionButton: _isListening
            ? FloatingActionButton(
                backgroundColor: theme.colorScheme.error,
                child: const Icon(Icons.mic, color: Colors.white),
                onPressed: () {
                  setState(() => _isListening = false);
                  _sendMessage("This is a mock voice message");
                },
              )
            : FloatingActionButton(
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(Icons.mic, color: theme.colorScheme.onSecondary),
                onPressed: () {
                  setState(() => _isListening = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() => _isListening = false);
                      _sendMessage("This is a mock voice message");
                    }
                  });
                },
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 8,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceVariant,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.secondary,
                ),
                child: IconButton(
                  icon: Icon(Icons.send, color: theme.colorScheme.onSecondary),
                  onPressed: () {
                    final message = _textController.text.trim();
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                      _textController.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
