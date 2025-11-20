import 'package:dio/dio.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';

class AuthInterceptor extends Interceptor {
  final AuthLocalDataSource localDataSource;

  AuthInterceptor(this.localDataSource);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get access token from secure storage
    final accessToken = await localDataSource.getAccessToken();

    if (accessToken != null && accessToken.isNotEmpty) {
      // Add Authorization header
      options.headers['Authorization'] = 'Bearer $accessToken';
      print('🔑 [AUTH_INTERCEPTOR] Added token to request: ${options.path}');
    } else {
      print('⚠️ [AUTH_INTERCEPTOR] No token found for request: ${options.path}');
    }

    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // If 401 Unauthorized, try to refresh token
    if (err.response?.statusCode == 401) {
      print('🔄 [AUTH_INTERCEPTOR] 401 Unauthorized, attempting token refresh...');
      
      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // TODO: Implement token refresh logic
          // For now, just pass the error
          print('❌ [AUTH_INTERCEPTOR] Token refresh not implemented yet');
        } catch (e) {
          print('❌ [AUTH_INTERCEPTOR] Token refresh failed: $e');
        }
      }
    }

    return handler.next(err);
  }
}
