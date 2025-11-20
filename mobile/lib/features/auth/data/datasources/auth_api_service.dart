import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

part 'auth_api_service.g.dart';

@RestApi()
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  @POST('/auth/send-otp')
  Future<HttpResponse<dynamic>> sendOtp(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/register')
  Future<HttpResponse<dynamic>> register(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/login')
  Future<HttpResponse<dynamic>> login(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/verify-phone')
  Future<HttpResponse<dynamic>> verifyPhone(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/refresh-token')
  Future<HttpResponse<dynamic>> refreshToken(
    @Body() Map<String, dynamic> body,
  );

  @POST('/auth/logout')
  Future<HttpResponse<dynamic>> logout();

  @POST('/auth/resend-verification')
  Future<HttpResponse<dynamic>> resendVerification(
    @Body() Map<String, dynamic> body,
  );

  @GET('/auth/profile')
  Future<HttpResponse<dynamic>> getProfile();
}