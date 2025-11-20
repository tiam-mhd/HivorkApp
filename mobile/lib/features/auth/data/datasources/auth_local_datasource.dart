import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> cacheTokens(String accessToken, String refreshToken);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
  Future<bool> isLoggedIn();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({
    required this.secureStorage,
    required this.sharedPreferences,
  });

  @override
  Future<void> cacheTokens(String accessToken, String refreshToken) async {
    print('💾 [LOCAL] Caching tokens (platform: ${kIsWeb ? "WEB" : "MOBILE"}): ${accessToken.substring(0, 20)}...');
    
    if (kIsWeb) {
      // در محیط Web از SharedPreferences استفاده میکنیم چون persistence بهتری داره
      await Future.wait([
        sharedPreferences.setString(AppConstants.accessTokenKey, accessToken),
        sharedPreferences.setString(AppConstants.refreshTokenKey, refreshToken),
      ]);
    } else {
      // در موبایل از FlutterSecureStorage استفاده میکنیم برای امنیت بیشتر
      await Future.wait([
        secureStorage.write(key: AppConstants.accessTokenKey, value: accessToken),
        secureStorage.write(key: AppConstants.refreshTokenKey, value: refreshToken),
      ]);
    }
    
    print('✅ [LOCAL] Tokens cached successfully');
    
    // بلافاصله بعد از cache، یه تست بخوانیم ببینیم ذخیره شده یا نه
    final testToken = await getAccessToken();
    print('🔍 [LOCAL] Verification read after cache: ${testToken != null ? "SUCCESS ✅" : "FAILED ❌"}');
  }

  @override
  Future<String?> getAccessToken() async {
    try {
      final token = kIsWeb 
          ? sharedPreferences.getString(AppConstants.accessTokenKey)
          : await secureStorage.read(key: AppConstants.accessTokenKey)
              .timeout(const Duration(seconds: 5));
      
      print('🔐 [LOCAL] getAccessToken result: ${token != null ? "Found (${token.substring(0, 20)}...)" : "NULL"}');
      return token;
    } catch (e) {
      print('⚠️ [LOCAL] Error reading access token: $e');
      return null;
    }
   }

  @override
  Future<String?> getRefreshToken() async {
    try {
      return kIsWeb
          ? sharedPreferences.getString(AppConstants.refreshTokenKey)
          : await secureStorage.read(key: AppConstants.refreshTokenKey)
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      print('⚠️ [LOCAL] Error reading refresh token: $e');
      return null;
    }
  }

  @override
  Future<void> clearTokens() async {
    if (kIsWeb) {
      await Future.wait([
        sharedPreferences.remove(AppConstants.accessTokenKey),
        sharedPreferences.remove(AppConstants.refreshTokenKey),
      ]);
    } else {
      await Future.wait([
        secureStorage.delete(key: AppConstants.accessTokenKey),
        secureStorage.delete(key: AppConstants.refreshTokenKey),
      ]);
    }
    print('🗑️ [LOCAL] Tokens cleared');
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.userDataKey,
      user.toJson().toString(),
    );
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userString = sharedPreferences.getString(AppConstants.userDataKey);
    if (userString != null) {
      try {
        // Note: This is a simplified implementation
        // In production, you should use proper JSON parsing
        return null; // TODO: Implement proper JSON parsing
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(AppConstants.userDataKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final accessToken = await getAccessToken();
    final isLoggedIn = accessToken != null && accessToken.isNotEmpty;
    print('🔐 [LOCAL] isLoggedIn: $isLoggedIn (token: ${accessToken != null ? "${accessToken.substring(0, 20)}..." : "null"})');
    return isLoggedIn;
  }
}