import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, Map<String, dynamic>>> sendOtp(String phone);
  
  Future<Either<Failure, AuthResponse>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  });

  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  });

  Future<Either<Failure, Map<String, dynamic>>> verifyPhone({
    required String phone,
    required String verificationCode,
  });

  Future<Either<Failure, AuthResponse>> refreshToken();

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, void>> resendVerificationCode(String phone);

  Future<Either<Failure, User>> getProfile();

  Future<Either<Failure, bool>> isLoggedIn();

  Future<Either<Failure, void>> clearTokens();
}