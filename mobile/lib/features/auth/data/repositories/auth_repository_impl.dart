import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_service.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService apiService;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.apiService,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, Map<String, dynamic>>> sendOtp(String phone) async {
    try {
      print('🔵 [SEND_OTP] Request: $phone');
      final response = await apiService.sendOtp({'phone': phone});
      print('🟢 [SEND_OTP] Response: ${response.data}');
      
      if (response.response.statusCode == 200) {
        // Backend: {success, data: {exists, message}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        print('✅ [SEND_OTP] Result: $data');
        return Right(data);
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'خطا در ارسال کد تأیید',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      print('❌ [SEND_OTP] Error: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('💥 [CHECK_PHONE] Exception: $e');
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> register({
    required String fullName,
    required String phone,
    required String password,
    String? email,
  }) async {
    try {
      final response = await apiService.register({
        'fullName': fullName,
        'phone': phone,
        'password': password,
        if (email != null && email.isNotEmpty) 'email': email,
      });

      print('🟢 [REGISTER] Response: ${response.data}');
      
      if (response.response.statusCode == 201) {
        // Backend: {success, data: {user, tokens}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        final authResponse = AuthResponseModel.fromJson(data);
        
        print('✅ [REGISTER] Caching tokens...');
        await localDataSource.cacheTokens(
          authResponse.tokens.accessToken,
          authResponse.tokens.refreshToken,
        );
        await localDataSource.cacheUser(authResponse.user);

        return Right(authResponse);
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'خطا در ثبت‌نام',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> login({
    required String phone,
    required String password,
  }) async {
    try {
      print('🔵 [LOGIN] Request: $phone');
      final response = await apiService.login({
        'phone': phone,
        'password': password,
      });

      print('🟢 [LOGIN] Response: ${response.data}');
      
      if (response.response.statusCode == 200) {
        // Backend: {success, data: {user, tokens}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        final authResponse = AuthResponseModel.fromJson(data);
        
        print('✅ [LOGIN] Caching tokens...');
        await localDataSource.cacheTokens(
          authResponse.tokens.accessToken,
          authResponse.tokens.refreshToken,
        );
        await localDataSource.cacheUser(authResponse.user);

        return Right(authResponse);
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'خطا در ورود',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      print('❌ [LOGIN] Error: ${e.response?.data}');
      return Left(_handleDioError(e));
    } catch (e) {
      print('💥 [LOGIN] Exception: $e');
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyPhone({
    required String phone,
    required String verificationCode,
  }) async {
    try {
      print('🔵 [VERIFY] Request: $phone');
      final response = await apiService.verifyPhone({
        'phone': phone,
        'code': verificationCode,
      });

      print('🟢 [VERIFY] Response: ${response.data}');
      
      if (response.response.statusCode == 200) {
        // Backend: {success, data: {success, message, user, exists}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        final userData = data['user'] as Map<String, dynamic>;
        final user = UserModel.fromJson(userData);
        final exists = data['exists'] as bool;
        
        print('✅ [VERIFY] User verified. Exists: $exists');
        await localDataSource.cacheUser(user);

        return Right({
          'user': user,
          'exists': exists,
          'message': data['message'] ?? 'تأیید شد',
        });
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'کد تایید نامعتبر است',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, AuthResponse>> refreshToken() async {
    try {
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return Left(UnauthorizedFailure());
      }

      final response = await apiService.refreshToken({
        'refreshToken': refreshToken,
      });

      print('🟢 [REFRESH_TOKEN] Response: ${response.data}');
      
      if (response.response.statusCode == 200) {
        // Backend: {success, data: {tokens}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        final tokens = AuthTokensModel.fromJson(data);
        
        print('✅ [REFRESH_TOKEN] Caching new tokens...');
        await localDataSource.cacheTokens(
          tokens.accessToken,
          tokens.refreshToken,
        );

        // Get cached user and return auth response
        final user = await localDataSource.getCachedUser();
        if (user != null) {
          return Right(AuthResponseModel(user: user, tokens: tokens));
        } else {
          return Left(CacheFailure());
        }
      } else {
        return Left(UnauthorizedFailure());
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await apiService.logout();
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      return Right(null);
    } on DioException {
      // Even if API call fails, clear local data
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> resendVerificationCode(String phone) async {
    try {
      final response = await apiService.resendVerification({
        'phone': phone,
      });

      if (response.response.statusCode == 200) {
        return Right(null);
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'خطا در ارسال کد تایید',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, User>> getProfile() async {
    try {
      final response = await apiService.getProfile();

      print('🟢 [PROFILE] Response: ${response.data}');
      
      if (response.response.statusCode == 200) {
        // Backend: {success, data: {user}, message, meta}
        final data = response.data['data'] as Map<String, dynamic>;
        final user = UserModel.fromJson(data);
        
        print('✅ [PROFILE] Updating cached user...');
        await localDataSource.cacheUser(user);

        return Right(user);
      } else {
        return Left(ServerFailure(
          message: response.data['message'] ?? 'خطا در دریافت اطلاعات کاربر',
          statusCode: response.response.statusCode,
        ));
      }
    } on DioException catch (e) {
      return Left(_handleDioError(e));
    } catch (e) {
      return Left(ServerFailure(message: 'خطای غیرمنتظره: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    try {
      final isLoggedIn = await localDataSource.isLoggedIn();
      return Right(isLoggedIn);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  @override
  Future<Either<Failure, void>> clearTokens() async {
    try {
      await localDataSource.clearTokens();
      await localDataSource.clearUser();
      return Right(null);
    } catch (e) {
      return Left(CacheFailure());
    }
  }

  Failure _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkFailure();
      case DioExceptionType.badResponse:
        if (e.response?.statusCode == 401) {
          return UnauthorizedFailure();
        }
        // Handle statusCode type conversion for web compatibility
        int? statusCode;
        if (e.response?.statusCode != null) {
          final code = e.response!.statusCode;
          statusCode = code is int ? code : int.tryParse(code.toString());
        }
        return ServerFailure(
          message: e.response?.data?['message'] ?? 'خطای سرور',
          statusCode: statusCode,
        );
      default:
        return NetworkFailure();
    }
  }
}