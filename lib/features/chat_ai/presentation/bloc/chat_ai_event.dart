part of 'chat_ai_bloc.dart';

@freezed
class ChatAiEvent with _$ChatAiEvent {
  const factory ChatAiEvent.messageSent(String message) = _MessageSent;
  const factory ChatAiEvent.voiceMessage() = _VoiceMessage;
  const factory ChatAiEvent.clearConversation() = _ClearConversation;
}