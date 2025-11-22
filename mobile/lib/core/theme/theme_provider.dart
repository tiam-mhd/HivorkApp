import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'theme_service.dart';

/// Provider to manage app theme based on system settings
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isSystemDarkMode = false;

  ThemeProvider() {
    _initTheme();
    _listenToThemeChanges();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isSystemDarkMode => _isSystemDarkMode;

  /// Initialize theme from system
  Future<void> _initTheme() async {
    // Only for Windows desktop (not web)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      _isSystemDarkMode = await ThemeService.isSystemDarkMode();
      notifyListeners();
    }
  }

  /// Listen to system theme changes
  void _listenToThemeChanges() {
    // Only for Windows desktop (not web)
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
      ThemeService.themeChanges.listen((isDark) {
        _isSystemDarkMode = isDark;
        notifyListeners();
      });
    }
  }

  /// Set theme mode manually (for future settings page)
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  /// Get effective brightness based on theme mode and system settings
  Brightness getEffectiveBrightness(BuildContext context) {
    switch (_themeMode) {
      case ThemeMode.light:
        return Brightness.light;
      case ThemeMode.dark:
        return Brightness.dark;
      case ThemeMode.system:
        // For web and other platforms, use Flutter's built-in detection
        // which works correctly with browser/system theme
        return MediaQuery.platformBrightnessOf(context);
    }
  }
}
