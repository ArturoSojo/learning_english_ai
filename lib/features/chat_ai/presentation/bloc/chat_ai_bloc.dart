import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:learning_english_ai/app/di.dart';
import 'package:learning_english_ai/core/errors/failures.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/voice_service.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart';
import 'package:learning_english_ai/features/chat_ai/domain/repositories/chat_ai_repository.dart';

part 'chat_ai_event.dart';
part 'chat_ai_state.dart';
part 'chat_ai_bloc.freezed.dart';

class ChatAiBloc extends Bloc<ChatAiEvent, ChatAiState> {
  final ChatAiRepository chatAiRepository;
  final List<ChatMessage> _messages = [];

  ChatAiBloc({required this.chatAiRepository}) : super(const ChatAiState.initial()) {
    on<ChatAiEvent>((event, emit) {
      return event.map(
        messageSent: (e) => _handleMessageSent(e, emit),
        voiceMessage: (e) => _handleVoiceMessage(e, emit),
        clearConversation: (e) => _handleClearConversation(e, emit),
      );
    });
  }

  Future<void> _handleMessageSent(
    _MessageSent event,
    Emitter<ChatAiState> emit,
  ) async {
    // Add user message
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: event.message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    _messages.insert(0, userMessage);
    emit(ChatAiState.loaded(List.from(_messages)));

    // Get AI response
    emit(const ChatAiState.loading());
    final response = await chatAiRepository.sendMessage(event.message);
    
    response.fold(
      (failure) => emit(ChatAiState.error(failure.toString())),
      (aiMessage) {
        _messages.insert(0, aiMessage as ChatMessage);
        emit(ChatAiState.loaded(List.from(_messages)));
      },
    );
  }

 Future<void> _handleVoiceMessage(
  _VoiceMessage event,
  Emitter<ChatAiState> emit,
) async {
  emit(const ChatAiState.voiceRecording());
  final voiceService = getIt<VoiceService>();
  final spokenText = await voiceService.listen();
  
  if (spokenText != null && spokenText.isNotEmpty) {
    add(ChatAiEvent.messageSent(spokenText));
  } else {
    emit(ChatAiState.loaded(List.from(_messages)));
  }
}

  void _handleClearConversation(
    _ClearConversation event,
    Emitter<ChatAiState> emit,
  ) {
    _messages.clear();
    emit(const ChatAiState.initial());
  }
}