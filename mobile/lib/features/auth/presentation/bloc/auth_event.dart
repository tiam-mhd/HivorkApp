part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatusEvent extends AuthEvent {}

class SendOtpEvent extends AuthEvent {
  final String phone;

  const SendOtpEvent({required this.phone});

  @override
  List<Object> get props => [phone];
}

class LoginEvent extends AuthEvent {
  final String phone;
  final String password;

  const LoginEvent({
    required this.phone,
    required this.password,
  });

  @override
  List<Object> get props => [phone, password];
}

class RegisterEvent extends AuthEvent {
  final String fullName;
  final String phone;
  final String password;
  final String? email;

  const RegisterEvent({
    required this.fullName,
    required this.phone,
    required this.password,
    this.email,
  });

  @override
  List<Object> get props => [fullName, phone, password, email ?? ''];
}

class VerifyPhoneEvent extends AuthEvent {
  final String phone;
  final String verificationCode;

  const VerifyPhoneEvent({
    required this.phone,
    required this.verificationCode,
  });

  @override
  List<Object> get props => [phone, verificationCode];
}

class LogoutEvent extends AuthEvent {}

class GetProfileEvent extends AuthEvent {}