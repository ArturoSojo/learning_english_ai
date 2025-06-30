import 'package:learning_english_ai/core/errors/failures.dart';
import 'package:learning_english_ai/features/user_progress/domain/entities/user_progress.dart';
import 'package:dartz/dartz.dart';

abstract class UserProgressRepository {
  Future<UserProgress> getUserProgress(String userId);
  Future<void> updateUserProgress(String userId, UserProgress progress);

  
}

