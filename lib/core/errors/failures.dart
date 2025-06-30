import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

// Errores generales
class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}

class CacheFailure extends Failure {
  const CacheFailure(String message) : super(message);
}

class NetworkFailure extends Failure {
  const NetworkFailure() : super('No internet connection');
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message) : super(message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message) : super(message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(String message) : super(message);
}

// Errores específicos del dominio
class InsufficientPointsFailure extends Failure {
  const InsufficientPointsFailure() 
      : super('You don\'t have enough points for this action');
}

class AchievementNotUnlockedFailure extends Failure {
  const AchievementNotUnlockedFailure() 
      : super('This achievement hasn\'t been unlocked yet');
}

class VoiceRecognitionFailure extends Failure {
  const VoiceRecognitionFailure(String message) 
      : super('Voice recognition error: $message');
}