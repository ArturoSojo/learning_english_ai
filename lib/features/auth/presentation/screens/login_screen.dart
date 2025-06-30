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
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Learning English AI',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              const Text(
                'Inicia sesión para continuar',
                style: TextStyle(fontSize: 18),
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
                icon: Image.asset('assets/images/google_logo.png', height: 24),
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