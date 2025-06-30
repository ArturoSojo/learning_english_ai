import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:learning_english_ai/features/auth/presentation/screens/login_screen.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        return state.when(
          unknown: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          authenticated: (user) => const HomeScreen(), // Lo implementaremos
          unauthenticated: () => const LoginScreen(), // Lo implementaremos
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (message) => LoginScreen(errorMessage: message),
        );
      },
    );
  }
}