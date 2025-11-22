import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Service to detect and monitor system theme changes
class ThemeService {
  static const MethodChannel _channel = MethodChannel('com.hivork.app/theme');
  
  /// Check if system is using dark theme
  /// Returns true for dark theme, false for light theme
  static Future<bool> isSystemDarkMode() async {
    // For Web platform, we can't detect system theme via Dart
    // Flutter will handle it automatically via MediaQuery
    if (kIsWeb) {
      return false; // Let Flutter handle it via ThemeMode.system
    }
    
    // Only use method channel on Windows desktop
    if (defaultTargetPlatform == TargetPlatform.windows) {
      try {
        final bool isDark = await _channel.invokeMethod('isSystemDarkMode');
        return isDark;
      } on PlatformException catch (e) {
        debugPrint('Failed to get system theme: ${e.message}');
        return false; // Default to light mode on error
      } catch (e) {
        debugPrint('Failed to get system theme: $e');
        return false;
      }
    }
    
    // For other platforms, return false as fallback
    return false;
  }
  
  /// Listen to system theme changes
  static Stream<bool> get themeChanges {
    // Only use method channel on Windows desktop (not web)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      return const EventChannel('com.hivork.app/theme_changes')
          .receiveBroadcastStream()
          .map((event) => event as bool);
    }
    
    // For other platforms, return empty stream
    return Stream.empty();
  }
}
