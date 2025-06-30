import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    required String userId,
    required int level,
    required int points,
    required int conversationsCompleted,
    required int wordsLearned,
    required DateTime lastActive,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) =>
      _$UserProgressFromJson(json);
}

extension UserProgressX on UserProgress {
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'level': level,
        'points': points,
        'conversationsCompleted': conversationsCompleted,
        'wordsLearned': wordsLearned,
        'lastActive': lastActive.toIso8601String(),
      };
}