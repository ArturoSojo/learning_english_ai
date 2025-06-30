part of 'chat_ai_bloc.dart';

@freezed
class ChatAiState with _$ChatAiState {
  const factory ChatAiState.initial() = _Initial;
  const factory ChatAiState.loading() = _Loading;
  const factory ChatAiState.loaded(List<ChatMessage> messages) = _Loaded;
  const factory ChatAiState.error(String message) = _Error;
  const factory ChatAiState.voiceRecording() = _VoiceRecording;
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String message,
    required bool isUser,
    required DateTime timestamp,
  }) = _ChatMessage;
}