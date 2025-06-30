import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:learning_english_ai/features/user_progress/domain/entities/user_progress.dart';
import 'package:learning_english_ai/features/user_progress/domain/repositories/user_progress_repository.dart';

part 'user_progress_event.dart';
part 'user_progress_state.dart';
part 'user_progress_bloc.freezed.dart';

class UserProgressBloc extends Bloc<UserProgressEvent, UserProgressState> {
  final UserProgressRepository repository;

  UserProgressBloc({required this.repository}) : super(const UserProgressState.initial()) {
    on<UserProgressEvent>((event, emit) async {
      await event.map(
        loadProgress: (e) => _handleLoadProgress(e, emit),
        updateProgress: (e) => _handleUpdateProgress(e, emit),
      );
    });
  }

  Future<void> _handleLoadProgress(
    _LoadProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressState.loading());
    final progress = await repository.getUserProgress(event.userId);
    emit(UserProgressState.loaded(progress));
  }

  Future<void> _handleUpdateProgress(
    _UpdateProgress event,
    Emitter<UserProgressState> emit,
  ) async {
    emit(const UserProgressState.updating());
    await repository.updateUserProgress(event.userId, event.progress);
    emit(UserProgressState.loaded(event.progress));
  }
}