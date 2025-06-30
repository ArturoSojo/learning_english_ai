part of 'user_progress_bloc.dart';

@freezed
class UserProgressEvent with _$UserProgressEvent {
  const factory UserProgressEvent.loadProgress(String userId) = _LoadProgress;
  const factory UserProgressEvent.updateProgress(
    String userId,
    UserProgress progress,
  ) = _UpdateProgress;
}