import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/app/app_bloc_observer.dart';
import 'package:learning_english_ai/core/theme/app_theme.dart';
import 'package:learning_english_ai/features/auth/presentation/widget/auth_wrapper.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Learning English AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AuthWrapper(), 
    );
  }
}