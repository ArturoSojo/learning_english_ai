import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learning_english_ai/app/app.dart';
import 'package:learning_english_ai/app/di.dart';
import 'package:learning_english_ai/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:learning_english_ai/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await init();

    runApp(
      MultiRepositoryProvider(
        providers: [
          RepositoryProvider<FirebaseAuth>(
            create: (context) => FirebaseAuth.instance,
          ),
          RepositoryProvider<GoogleSignIn>(
            create: (context) => GoogleSignIn.instance,
          ),
        ],
        child: MultiBlocProvider(
          providers: [
            BlocProvider<AuthBloc>(
              create: (context) => AuthBloc(
                firebaseAuth: context.read<FirebaseAuth>(),
              ),
            ),
          ],
          child: const App(),
        ),
      ),
    );
  } catch (e) {
    debugPrint('Error inicializando Firebase: $e');
    runApp(const ErrorApp());
  }
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error inicializando la aplicación'),
        ),
      ),
    );
  }
}
