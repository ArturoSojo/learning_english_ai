part of 'auth_bloc.dart';

@freezed
class AuthEvent with _$AuthEvent {
  const factory AuthEvent.userChanged(User? user) = AuthUserChanged;
  const factory AuthEvent.logoutRequested() = AuthLogoutRequested;
  const factory AuthEvent.loginWithGoogleRequested() = AuthLoginWithGoogleRequested;
}
