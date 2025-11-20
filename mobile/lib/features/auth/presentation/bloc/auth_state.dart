part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phone;
  final bool exists;

  const AuthOtpSent({
    required this.phone,
    required this.exists,
  });

  @override
  List<Object> get props => [phone, exists];
}

class AuthPhoneVerified extends AuthState {
  final String phone;
  final User user;

  const AuthPhoneVerified({
    required this.phone,
    required this.user,
  });

  @override
  List<Object> get props => [phone, user];
}

class AuthRegistrationSuccess extends AuthState {
  final User user;

  const AuthRegistrationSuccess(this.user);

  @override
  List<Object> get props => [user];
}

class AuthPhoneVerificationRequired extends AuthState {
  final String phone;
  final User user;

  const AuthPhoneVerificationRequired({
    required this.phone,
    required this.user,
  });

  @override
  List<Object> get props => [phone, user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}