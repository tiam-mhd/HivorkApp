import 'package:flutter/foundation.dart';

/// کلاس کمکی برای لاگ‌گیری
class Logger {
  static void info(String message) {
    if (kDebugMode) {
      print('ℹ️ INFO: $message');
    }
  }

  static void success(String message) {
    if (kDebugMode) {
      print('✅ SUCCESS: $message');
    }
  }

  static void warning(String message) {
    if (kDebugMode) {
      print('⚠️ WARNING: $message');
    }
  }

  static void error(String message, [Object? error]) {
    if (kDebugMode) {
      print('❌ ERROR: $message');
      if (error != null) {
        print('Details: $error');
      }
    }
  }

  static void debug(String message) {
    if (kDebugMode) {
      print('🔍 DEBUG: $message');
    }
  }
}
