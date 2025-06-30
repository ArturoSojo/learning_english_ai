import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String message,
    required bool isUser,
    required DateTime timestamp,
  }) = _ChatMessage;
}