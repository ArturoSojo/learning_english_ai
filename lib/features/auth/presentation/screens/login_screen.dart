import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/core/widgets/primary_button.dart';
import 'package:learning_english_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:auto_route/annotations.dart';

@RoutePage()
class LoginScreen extends StatelessWidget {
  final String? errorMessage;
  const LoginScreen({super.key, this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Learning English AI',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Inicia sesión para continuar',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 40),
              if (errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              PrimaryButton(
                text: 'Continuar con Google',
                icon: Image.asset('assets/images/google.png', height: 24),
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthLoginWithGoogleRequested());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}