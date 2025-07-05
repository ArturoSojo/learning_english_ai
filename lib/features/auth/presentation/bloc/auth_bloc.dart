import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/services.dart';

part 'auth_event.dart';
part 'auth_state.dart';
part 'auth_bloc.freezed.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc({
    required FirebaseAuth firebaseAuth,
  })  : _firebaseAuth = firebaseAuth,
        super(const AuthState.unknown()) {
    on<AuthUserChanged>(_onUserChanged);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthLoginWithGoogleRequested>(_onLoginWithGoogleRequested);

    _firebaseAuth.authStateChanges().listen((user) {
      add(AuthUserChanged(user));
    });
  }

  Future<void> _onUserChanged(
    AuthUserChanged event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      event.user != null
          ? AuthState.authenticated(event.user!)
          : const AuthState.unauthenticated(),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await GoogleSignIn.instance.disconnect();
    await _firebaseAuth.signOut();
  }

  Future<void> _onLoginWithGoogleRequested(
    AuthLoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthState.loading());

      // ✅ Inicializar GoogleSignIn correctamente
      await GoogleSignIn.instance.initialize(
        clientId: 'AIzaSyA4nmb_JuHnruB8YOP7MBSP6yLG0aBH9Ns', // ← usa el client ID de tipo "Web"
      );

      // ✅ Autenticar (nuevo método en v7+)
      final googleUser = await GoogleSignIn.instance.authenticate();

      if (googleUser == null) {
        emit(const AuthState.unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;

      if (googleAuth.idToken == null) {
        throw PlatformException(
          code: 'AUTH_ERROR',
          message: 'No se recibió token de Google',
        );
      }

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print('Nuevo usuario registrado con Google: ${userCredential.user?.uid}');
      } else {
        print('Usuario existente logueado con Google: ${userCredential.user?.uid}');
      }
    } on PlatformException catch (e) {
      print('Error de plataforma: ${e.code} - ${e.message}');
      emit(AuthState.error(_mapPlatformError(e.code)));
    } on FirebaseAuthException catch (e) {
      print('Error de Firebase Auth: ${e.code} - ${e.message}');
      emit(AuthState.error(_mapFirebaseError(e.code)));
    } catch (e) {
      print('Error inesperado en Google Sign-In: $e');
      emit(AuthState.error('Error inesperado al autenticar con Google'));
    } finally {
      if (_firebaseAuth.currentUser == null) {
        emit(const AuthState.unauthenticated());
      }
    }
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return 'Esta cuenta ya está asociada con otro método de autenticación';
      case 'invalid-credential':
        return 'Credenciales inválidas';
      case 'operation-not-allowed':
        return 'Método de autenticación no permitido';
      case 'user-disabled':
        return 'Cuenta deshabilitada';
      case 'user-not-found':
        return 'Usuario no encontrado';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'invalid-verification-code':
        return 'Código de verificación inválido';
      case 'network-request-failed':
        return 'Error de conexión de red';
      default:
        return 'Error de autenticación';
    }
  }

  String _mapPlatformError(String code) {
    switch (code) {
      case 'AUTH_ERROR':
        return 'Error al obtener credenciales de Google';
      case 'sign_in_failed':
        return 'No se pudo iniciar sesión con Google';
      default:
        return 'Error de plataforma desconocido';
    }
  }
}
