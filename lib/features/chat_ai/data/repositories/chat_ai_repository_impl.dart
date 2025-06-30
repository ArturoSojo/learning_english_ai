import 'package:dartz/dartz.dart';
import 'package:learning_english_ai/core/errors/failures.dart';
import 'package:learning_english_ai/features/chat_ai/domain/repositories/chat_ai_repository.dart';
import 'package:learning_english_ai/features/chat_ai/domain/entities/chat_message.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChatAiRepositoryImpl implements ChatAiRepository {
  final http.Client client;
  final String baseUrl;

  ChatAiRepositoryImpl({required this.client, required this.baseUrl});

  @override
  Future<Either<Failure, ChatMessage>> sendMessage(String message) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return Right(ChatMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          message: data['response'],
          isUser: false,
          timestamp: DateTime.now(),
        ));
      } else {
        return Left(ServerFailure('Failed to get response from AI'));
      }
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}