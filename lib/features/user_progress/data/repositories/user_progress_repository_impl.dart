import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:learning_english_ai/core/errors/failures.dart';
import 'package:learning_english_ai/features/user_progress/domain/entities/user_progress.dart';
import 'package:learning_english_ai/features/user_progress/domain/repositories/user_progress_repository.dart';

class UserProgressRepositoryImpl implements UserProgressRepository {
  final FirebaseFirestore firestore;

  UserProgressRepositoryImpl({required this.firestore});

  @override
  Future<UserProgress> getUserProgress(String userId) async {
    try {
      final doc = await firestore.collection('user_progress').doc(userId).get();
      
      if (!doc.exists) {
        // Crear un progreso inicial si no existe
        final initialProgress = UserProgress(
          userId: userId,
          level: 1,
          points: 0,
          conversationsCompleted: 0,
          wordsLearned: 0,
          lastActive: DateTime.now(),
        );
        await doc.reference.set(initialProgress.toJson());
        return initialProgress;
      }

      return UserProgress.fromJson(doc.data()!);
    } catch (e) {
      throw ServerFailure('Failed to get user progress: ${e.toString()}');
    }
  }

  @override
  Future<void> updateUserProgress(String userId, UserProgress progress) async {
    try {
      await firestore
          .collection('user_progress')
          .doc(userId)
          .update(progress.toJson());
    } catch (e) {
      throw ServerFailure('Failed to update user progress: ${e.toString()}');
    }
  }
}