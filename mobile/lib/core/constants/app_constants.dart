class AppConstants {
  // API
  // static const String baseUrl = 'http://localhost:3000/api/v1';
  static const String baseUrl = 'https://hivorkapp-backend.onrender.com/api/v1';
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  
  // Storage Keys
  static const String accessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userDataKey = 'user_data';
  static const String businessIdKey = 'business_id';
  static const String languageKey = 'language';
  static const String themeKey = 'theme';
  
  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;
  
  // Formats
  static const String dateFormat = 'yyyy/MM/dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy/MM/dd HH:mm';
  
  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int phoneLength = 11;
}
