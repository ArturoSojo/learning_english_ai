import 'package:dartz/dartz.dart';
import 'package:learning_english_ai/core/errors/failures.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart';

abstract class ChatAiRepository {
  Future<Either<Failure, ChatMessage>> sendMessage(String message);
}