import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/app/di.dart';
import 'package:learning_english_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learning_english_ai/features/user_progress/domain/repositories/user_progress_repository.dart';
import 'package:learning_english_ai/features/user_progress/presentation/bloc/user_progress_bloc.dart';
import 'package:learning_english_ai/features/user_progress/presentation/widgets/progress_indicator.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select(
      (AuthBloc bloc) => bloc.state.whenOrNull(
        authenticated: (user) => user.uid,
      ),
    );

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('User not authenticated')),
      );
    }

    return BlocProvider(
      create: (context) => UserProgressBloc(
        repository: getIt<UserProgressRepository>(),
      )..add(UserProgressEvent.loadProgress(userId)),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Progress'),
        ),
        body: BlocBuilder<UserProgressBloc, UserProgressState>(
          builder: (context, state) {
            return state.when(
              initial: () => const Center(child: CircularProgressIndicator()),
              loading: () => const Center(child: CircularProgressIndicator()),
              updating: () => const Center(child: CircularProgressIndicator()),
              loaded: (progress) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ProgressIndicatorCard(
                      title: 'Current Level',
                      value: progress.level.toDouble(),
                      maxValue: 10,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    ProgressIndicatorCard(
                      title: 'Points',
                      value: progress.points.toDouble(),
                      maxValue: 1000,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    ProgressIndicatorCard(
                      title: 'Conversations',
                      value: progress.conversationsCompleted.toDouble(),
                      maxValue: 100,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 16),
                    ProgressIndicatorCard(
                      title: 'Words Learned',
                      value: progress.wordsLearned.toDouble(),
                      maxValue: 500,
                      color: Colors.purple,
                    ),
                  ],
                ),
              ),
              error: (message) => Center(child: Text('Error: $message')),
            );
          },
        ),
      ),
    );
  }
}