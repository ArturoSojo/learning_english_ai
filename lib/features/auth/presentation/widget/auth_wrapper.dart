import 'package:auto_route/auto_route.dart';
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
          unauthenticated: () => const LoginScreen(),
          authenticated: (user) => const HomeScreen(),
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (message) => LoginScreen(errorMessage: message),
          unknown: () => const Scaffold(body: Center(child: Text('Unknown state'))),
        );
      },
    );
  }
}