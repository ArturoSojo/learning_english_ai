import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/app/di.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/voice_service.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/bloc/chat_ai_bloc.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/widgets/chat_message_bubble.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _initializeVoiceService();
  }

  Future<void> _initializeVoiceService() async {
    await getIt<VoiceService>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI English Tutor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              context.read<ChatAiBloc>().add(const ChatAiEvent.clearConversation());
            },
          ),
        ],
      ),
      body: BlocConsumer<ChatAiBloc, ChatAiState>(
        listener: (context, state) {
          state.whenOrNull(
            voiceRecording: () => setState(() => _isListening = true),
            loaded: (_) => setState(() => _isListening = false),
            error: (_) => setState(() => _isListening = false),
          );
        },
        builder: (context, state) {
          return state.when(
            initial: () => const Center(child: Text('Start a conversation!')),
            loading: () => Stack(
              children: [
                if (_messages.isNotEmpty)
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessageBubble(
                        message: message.message,
                        isUser: message.isUser,
                      );
                    },
                  ),
                const Center(child: CircularProgressIndicator()),
              ],
            ),
            loaded: (messages) {
              _messages = messages;
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                reverse: true,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return ChatMessageBubble(
                    message: message.message,
                    isUser: message.isUser,
                  );
                },
              );
            },
            error: (message) => Center(child: Text('Error: $message')),
            voiceRecording: () => Stack(
              children: [
                if (_messages.isNotEmpty)
                  ListView.builder(
                    padding: const EdgeInsets.all(8),
                    reverse: true,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return ChatMessageBubble(
                        message: message.message,
                        isUser: message.isUser,
                      );
                    },
                  ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.mic, size: 72, color: Colors.red),
                      const SizedBox(height: 16),
                      const Text('Listening...'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          getIt<VoiceService>().stopListening();
                          setState(() => _isListening = false);
                          context.read<ChatAiBloc>().add(
                                const ChatAiEvent.messageSent(''),
                              );
                        },
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: _isListening
          ? null
          : FloatingActionButton(
              child: const Icon(Icons.mic),
              onPressed: () {
                context.read<ChatAiBloc>().add(const ChatAiEvent.voiceMessage());
              },
            ),
      bottomNavigationBar: _isListening
          ? null
          : Padding(
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
                      decoration: const InputDecoration(
                        hintText: 'Type your message...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () {
                      final message = _textController.text.trim();
                      if (message.isNotEmpty) {
                        context.read<ChatAiBloc>().add(
                              ChatAiEvent.messageSent(message),
                            );
                        _textController.clear();
                      }
                    },
                  ),
                ],
              ),
            ),
    );
  }

  List<ChatMessage> _messages = [];
}