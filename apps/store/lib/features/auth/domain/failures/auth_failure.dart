import 'package:equatable/equatable.dart';

sealed class AuthFailure extends Equatable {
  const AuthFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure([
    super.message = 'Invalid email or password',
  ]);
}

class EmailAlreadyInUseFailure extends AuthFailure {
  const EmailAlreadyInUseFailure([
    super.message = 'An account with this email already exists',
  ]);
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure([
    super.message = 'Session expired. Please sign in again',
  ]);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure([
    super.message = 'Network error. Please check your connection',
  ]);
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([
    super.message = 'An unexpected authentication error occurred',
  ]);
}
