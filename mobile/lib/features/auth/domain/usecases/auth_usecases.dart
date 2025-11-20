import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call(String phone) async {
    return await repository.sendOtp(phone);
  }
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    return await repository.register(
      fullName: fullName,
      phone: phone,
      password: password,
      email: email,
    );
  }
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, AuthResponse>> call({
    required String phone,
    required String password,
  }) async {
    return await repository.login(
      phone: phone,
      password: password,
    );
  }
}

class VerifyPhoneUseCase {
  final AuthRepository repository;

  VerifyPhoneUseCase(this.repository);

  Future<Either<Failure, Map<String, dynamic>>> call({
    required String phone,
    required String verificationCode,
  }) async {
    return await repository.verifyPhone(
      phone: phone,
      verificationCode: verificationCode,
    );
  }
}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class GetProfileUseCase {
  final AuthRepository repository;

  GetProfileUseCase(this.repository);

  Future<Either<Failure, User>> call() async {
    return await repository.getProfile();
  }
}

class IsLoggedInUseCase {
  final AuthRepository repository;

  IsLoggedInUseCase(this.repository);

  Future<Either<Failure, bool>> call() async {
    return await repository.isLoggedIn();
  }
}