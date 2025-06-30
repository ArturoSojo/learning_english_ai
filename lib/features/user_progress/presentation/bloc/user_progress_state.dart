part of 'user_progress_bloc.dart';

@freezed
class UserProgressState with _$UserProgressState {
  const factory UserProgressState.initial() = _Initial;
  const factory UserProgressState.loading() = _Loading;
  const factory UserProgressState.updating() = _Updating;
  const factory UserProgressState.loaded(UserProgress progress) = _Loaded;
  const factory UserProgressState.error(String message) = _Error;
}