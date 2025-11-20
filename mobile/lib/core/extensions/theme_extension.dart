import 'package:flutter/material.dart';

/// Extension to easily access theme colors in dark/light mode
extension ThemeExtension on BuildContext {
  /// Returns true if the current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Returns the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Returns the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  /// Primary color (adapts to theme)
  Color get primaryColor => colorScheme.primary;
  
  /// Secondary color (adapts to theme)
  Color get secondaryColor => colorScheme.secondary;
  
  /// Background color (adapts to theme)
  Color get backgroundColor => colorScheme.surface;
  
  /// Surface color (adapts to theme)
  Color get surfaceColor => colorScheme.surface;
  
  /// Text primary color (adapts to theme)
  Color get textPrimary => colorScheme.onSurface;
  
  /// Text secondary color (adapts to theme)
  Color get textSecondary => colorScheme.onSurfaceVariant;
  
  /// Error color (adapts to theme)
  Color get errorColor => colorScheme.error;
}
