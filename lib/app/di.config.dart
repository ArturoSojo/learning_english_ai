// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:firebase_auth/firebase_auth.dart' as _i59;
import 'package:get_it/get_it.dart' as _i174;
import 'package:google_sign_in/google_sign_in.dart' as _i116;
import 'package:http/http.dart' as _i519;
import 'package:injectable/injectable.dart' as _i526;
import 'package:speech_to_text/speech_to_text.dart' as _i941;
import 'package:text_to_speech/text_to_speech.dart' as _i710;

import '../features/chat_ai/data/services/voice_service.dart' as _i99;
import '../features/chat_ai/domain/repositories/chat_ai_repository.dart'
    as _i529;
import 'di.dart' as _i913;

// initializes the registration of main-scope dependencies inside of GetIt
_i174.GetIt $initGetIt(
  _i174.GetIt getIt, {
  String? environment,
  _i526.EnvironmentFilter? environmentFilter,
}) {
  final gh = _i526.GetItHelper(
    getIt,
    environment,
    environmentFilter,
  );
  final appModule = _$AppModule();
  final firebaseModule = _$FirebaseModule();
  gh.singleton<_i59.FirebaseAuth>(() => appModule.firebaseAuth);
  gh.singleton<_i116.GoogleSignIn>(() => appModule.googleSignIn);
  gh.singleton<_i519.Client>(() => appModule.httpClient);
  gh.singleton<_i941.SpeechToText>(() => appModule.speechToText);
  gh.singleton<_i710.TextToSpeech>(() => appModule.textToSpeech);
  gh.singleton<_i99.VoiceService>(() => appModule.voiceService);
  gh.singleton<_i529.ChatAiRepository>(() => appModule.chatAiRepository);
  gh.singleton<_i974.FirebaseFirestore>(() => firebaseModule.firestore);
  return getIt;
}

class _$AppModule extends _i913.AppModule {}

class _$FirebaseModule {
  _i974.FirebaseFirestore get firestore => _i974.FirebaseFirestore.instance;
}
