import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:learning_english_ai/features/chat_ai/data/repositories/chat_ai_repository_impl.dart';
import 'package:learning_english_ai/features/chat_ai/data/services/voice_service.dart';
import 'package:learning_english_ai/features/chat_ai/domain/repositories/chat_ai_repository.dart';
import 'package:learning_english_ai/features/chat_ai/presentation/bloc/chat_ai_bloc.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:text_to_speech/text_to_speech.dart';
import 'di.config.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // Register services
  getIt.registerSingleton<VoiceService>(VoiceService());
  getIt.registerFactory<ChatAiBloc>(
    () => ChatAiBloc(chatAiRepository: getIt<ChatAiRepository>()),
  );
  // Initialize services
  await getIt<VoiceService>().initialize();
  
}

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() async => $initGetIt(getIt);

@module
abstract class AppModule {
  @singleton
  FirebaseAuth get firebaseAuth => FirebaseAuth.instance;

  @singleton
  GoogleSignIn get googleSignIn => GoogleSignIn.instance;

  @singleton
  http.Client get httpClient => http.Client();

  @singleton
  stt.SpeechToText get speechToText => stt.SpeechToText();

  @singleton
  TextToSpeech get textToSpeech => TextToSpeech();

  @singleton
  VoiceService get voiceService => VoiceService();

  @singleton
  ChatAiRepository get chatAiRepository => ChatAiRepositoryImpl(
        client: getIt<http.Client>(),
        baseUrl: 'https://your-python-backend.com/api', // Reemplaza con tu URL
      );
}
