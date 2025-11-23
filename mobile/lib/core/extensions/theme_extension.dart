import 'package:flutter/material.dart';
import '../theme/app_colors_v2.dart';

/// Extension to easily access theme colors in dark/light mode - V2
/// 🎨 Based on the delicious AppColorsV2 palette!
extension ThemeExtension on BuildContext {
  /// Returns true if the current theme is dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Returns the current color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Returns the current text theme
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // ============================================
  // 🎨 PRIMARY COLORS - Brand Identity
  // ============================================
  
  /// Primary color (adapts to theme)
  Color get primaryColor => isDarkMode 
      ? AppColorsV2.darkPrimary 
      : AppColorsV2.primary;
  
  /// Primary dark shade
  Color get primaryDarkColor => isDarkMode 
      ? AppColorsV2.darkPrimaryDark 
      : AppColorsV2.primaryDark;
  
  /// Primary light shade
  Color get primaryLightColor => isDarkMode 
      ? AppColorsV2.darkPrimaryLight 
      : AppColorsV2.primaryLight;
  
  /// Primary pale/subtle shade
  Color get primaryPaleColor => isDarkMode 
      ? AppColorsV2.darkPrimaryPale 
      : AppColorsV2.primaryPale;
  
  // ============================================
  // 💙 SECONDARY COLORS - Professional Trust
  // ============================================
  
  /// Secondary color (adapts to theme)
  Color get secondaryColor => isDarkMode 
      ? AppColorsV2.darkSecondary 
      : AppColorsV2.secondary;
  
  /// Secondary dark shade
  Color get secondaryDarkColor => isDarkMode 
      ? AppColorsV2.darkSecondaryDark 
      : AppColorsV2.secondaryDark;
  
  /// Secondary light shade
  Color get secondaryLightColor => isDarkMode 
      ? AppColorsV2.darkSecondaryLight 
      : AppColorsV2.secondaryLight;
  
  /// Secondary pale/subtle shade
  Color get secondaryPaleColor => isDarkMode 
      ? AppColorsV2.darkSecondaryPale 
      : AppColorsV2.secondaryPale;
  
  // ============================================
  // ✨ ACCENT COLORS - Joy & Success
  // ============================================
  
  /// Accent color (adapts to theme)
  Color get accentColor => AppColorsV2.accent;
  
  /// Accent dark shade
  Color get accentDarkColor => AppColorsV2.accentDark;
  
  /// Accent light shade
  Color get accentLightColor => AppColorsV2.accentLight;
  
  /// Accent pale/subtle shade
  Color get accentPaleColor => AppColorsV2.accentPale;
  
  // ============================================
  // 🌅 BACKGROUNDS & SURFACES
  // ============================================
  
  /// Background color (adapts to theme)
  Color get backgroundColor => isDarkMode 
      ? AppColorsV2.darkBackground 
      : AppColorsV2.background;
  
  /// Background subtle variation
  Color get backgroundSubtleColor => isDarkMode 
      ? AppColorsV2.darkBackgroundSubtle 
      : AppColorsV2.backgroundSubtle;
  
  /// Surface color (adapts to theme)
  Color get surfaceColor => isDarkMode 
      ? AppColorsV2.darkSurface 
      : AppColorsV2.surface;
  
  /// Surface elevated (cards, modals)
  Color get surfaceElevatedColor => isDarkMode 
      ? AppColorsV2.darkSurfaceElevated 
      : AppColorsV2.surfaceElevated;
  
  /// Surface hover state
  Color get surfaceHoverColor => isDarkMode 
      ? AppColorsV2.darkSurfaceHover 
      : AppColorsV2.surfaceHover;
  
  // ============================================
  // 📝 TEXT COLORS - Typography
  // ============================================
  
  /// Text primary color (adapts to theme)
  Color get textPrimary => isDarkMode 
      ? AppColorsV2.darkTextPrimary 
      : AppColorsV2.textPrimary;
  
  /// Text secondary color (adapts to theme)
  Color get textSecondary => isDarkMode 
      ? AppColorsV2.darkTextSecondary 
      : AppColorsV2.textSecondary;
  
  /// Text tertiary color (adapts to theme)
  Color get textTertiaryColor => isDarkMode 
      ? AppColorsV2.darkTextTertiary 
      : AppColorsV2.textTertiary;
  
  /// Text disabled color (adapts to theme)
  Color get textDisabledColor => isDarkMode 
      ? AppColorsV2.darkTextDisabled 
      : AppColorsV2.textDisabled;
  
  /// Text on primary background
  Color get textOnPrimaryColor => AppColorsV2.textOnPrimary;
  
  /// Text on secondary background
  Color get textOnSecondaryColor => AppColorsV2.textOnSecondary;
  
  /// Text on dark background
  Color get textOnDarkColor => AppColorsV2.textOnDark;
  
  // ============================================
  // 🎯 STATUS COLORS - User Feedback
  // ============================================
  
  /// Success color (adapts to theme)
  Color get successColor => isDarkMode 
      ? AppColorsV2.darkSuccess 
      : AppColorsV2.success;
  
  /// Success dark shade
  Color get successDarkColor => AppColorsV2.successDark;
  
  /// Success light shade
  Color get successLightColor => AppColorsV2.successLight;
  
  /// Success pale/subtle shade
  Color get successPaleColor => AppColorsV2.successPale;
  
  /// Warning color (adapts to theme)
  Color get warningColor => isDarkMode 
      ? AppColorsV2.darkWarning 
      : AppColorsV2.warning;
  
  /// Warning dark shade
  Color get warningDarkColor => AppColorsV2.warningDark;
  
  /// Warning light shade
  Color get warningLightColor => AppColorsV2.warningLight;
  
  /// Warning pale/subtle shade
  Color get warningPaleColor => AppColorsV2.warningPale;
  
  /// Error color (adapts to theme)
  Color get errorColor => isDarkMode 
      ? AppColorsV2.darkError 
      : AppColorsV2.error;
  
  /// Error dark shade
  Color get errorDarkColor => AppColorsV2.errorDark;
  
  /// Error light shade
  Color get errorLightColor => AppColorsV2.errorLight;
  
  /// Error pale/subtle shade
  Color get errorPaleColor => AppColorsV2.errorPale;
  
  /// Info color (adapts to theme)
  Color get infoColor => isDarkMode 
      ? AppColorsV2.darkInfo 
      : AppColorsV2.info;
  
  /// Info dark shade
  Color get infoDarkColor => AppColorsV2.infoDark;
  
  /// Info light shade
  Color get infoLightColor => AppColorsV2.infoLight;
  
  /// Info pale/subtle shade
  Color get infoPaleColor => AppColorsV2.infoPale;
  
  // ============================================
  // 🎨 BORDERS & DIVIDERS
  // ============================================
  
  /// Border color (adapts to theme)
  Color get borderColor => isDarkMode 
      ? AppColorsV2.darkBorder 
      : AppColorsV2.border;
  
  /// Border light shade
  Color get borderLightColor => isDarkMode 
      ? AppColorsV2.darkBorderLight 
      : AppColorsV2.borderLight;
  
  /// Border medium shade
  Color get borderMediumColor => isDarkMode 
      ? AppColorsV2.darkBorderMedium 
      : AppColorsV2.borderMedium;
  
  /// Divider color
  Color get dividerColor => isDarkMode 
      ? AppColorsV2.darkDivider 
      : AppColorsV2.divider;
  
  // ============================================
  // 🌫️ SHADOWS & OVERLAYS
  // ============================================
  
  /// Shadow color (adapts to theme)
  Color get shadowColor => isDarkMode 
      ? AppColorsV2.darkShadow 
      : AppColorsV2.shadow;
  
  /// Shadow medium intensity
  Color get shadowMediumColor => isDarkMode 
      ? AppColorsV2.darkShadowMedium 
      : AppColorsV2.shadowMedium;
  
  /// Shadow strong intensity
  Color get shadowStrongColor => isDarkMode 
      ? AppColorsV2.darkShadowStrong 
      : AppColorsV2.shadowStrong;
  
  /// Overlay color
  Color get overlayColor => AppColorsV2.overlay;
  
  /// Overlay light shade
  Color get overlayLightColor => AppColorsV2.overlayLight;
  
  // ============================================
  // 🎨 INTERACTIVE STATES
  // ============================================
  
  /// Hover state color
  Color get hoverColor => isDarkMode 
      ? AppColorsV2.darkHover 
      : AppColorsV2.hover;
  
  /// Pressed state color
  Color get pressedColor => isDarkMode 
      ? AppColorsV2.darkPressed 
      : AppColorsV2.pressed;
  
  /// Focus ring color
  Color get focusRingColor => isDarkMode 
      ? AppColorsV2.darkFocusRing 
      : AppColorsV2.focusRing;
  
  /// Disabled state color
  Color get disabledColor => isDarkMode 
      ? AppColorsV2.darkTextDisabled 
      : AppColorsV2.textDisabled;
  
  // ============================================
  // 📊 DATA VISUALIZATION (Chart Colors)
  // ============================================
  
  /// Get chart colors list
  List<Color> get chartColors => AppColorsV2.chartColors;
  
  /// Get specific chart color by index
  Color chartColor(int index) {
    final colors = chartColors;
    return colors[index % colors.length];
  }
  
  // ============================================
  // 🎨 GRADIENTS
  // ============================================
  
  /// Primary gradient
  List<Color> get primaryGradient => isDarkMode 
      ? AppColorsV2.darkPrimaryGradient 
      : AppColorsV2.primaryGradient;
  
  /// Secondary gradient
  List<Color> get secondaryGradient => isDarkMode 
      ? AppColorsV2.darkSecondaryGradient 
      : AppColorsV2.secondaryGradient;
  
  /// Accent gradient
  List<Color> get accentGradient => AppColorsV2.accentGradient;
  
  /// Warm gradient
  List<Color> get warmGradient => AppColorsV2.warmGradient;
  
  /// Cool gradient
  List<Color> get coolGradient => AppColorsV2.coolGradient;
  
  // ============================================
  // 🎯 HELPER METHODS
  // ============================================
  
  /// Get adaptive color based on theme mode
  Color adaptiveColor({
    required Color light,
    required Color dark,
  }) {
    return isDarkMode ? dark : light;
  }
  
  /// Create gradient from color
  LinearGradient createGradient({
    required Color color,
    double lighten = 0.2,
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      colors: [
        color,
        Color.lerp(color, Colors.white, lighten) ?? color,
      ],
      begin: begin,
      end: end,
    );
  }
  
  /// Apply opacity to any color
  Color withAlpha(Color color, double opacity) {
    return color.withValues(alpha: opacity);
  }
  
  // ============================================
  // 🎨 ATTRIBUTE & VARIANT SPECIFIC COLORS
  // ============================================
  
  /// Attribute data type colors (adapts to dark/light mode)
  Color get attributeTextColor => isDarkMode 
      ? AppColorsV2.darkInfo 
      : AppColorsV2.info;
  
  Color get attributeNumberColor => isDarkMode 
      ? AppColorsV2.darkSecondary 
      : AppColorsV2.secondary;
  
  Color get attributeSelectColor => isDarkMode 
      ? AppColorsV2.darkPrimary 
      : AppColorsV2.primary;
  
  Color get attributeColorColor => AppColorsV2.accent;
  
  Color get attributeBooleanColor => isDarkMode 
      ? AppColorsV2.darkSuccess 
      : AppColorsV2.success;
  
  Color get attributeDateColor => isDarkMode 
      ? AppColorsV2.darkWarning 
      : AppColorsV2.warning;
  
  /// Variant status colors (adapts to dark/light mode)
  Color get variantActiveColor => isDarkMode 
      ? AppColorsV2.darkSuccess 
      : AppColorsV2.success;
  
  Color get variantLowStockColor => isDarkMode 
      ? AppColorsV2.darkWarning 
      : AppColorsV2.warning;
  
  Color get variantOutOfStockColor => isDarkMode 
      ? AppColorsV2.darkError 
      : AppColorsV2.error;
  
  Color get variantInactiveColor => isDarkMode 
      ? AppColorsV2.darkTextDisabled 
      : AppColorsV2.textDisabled;
  
  /// Attribute scope colors (adapts to dark/light mode)
  Color get scopeFixedColor => isDarkMode 
      ? AppColorsV2.darkInfo 
      : AppColorsV2.info;
  
  Color get scopeVariableColor => isDarkMode 
      ? AppColorsV2.darkWarning 
      : AppColorsV2.warning;
  
  /// Attribute cardinality colors (adapts to dark/light mode)
  Color get cardinalitySingleColor => isDarkMode 
      ? AppColorsV2.darkSecondary 
      : AppColorsV2.secondary;
  
  Color get cardinalityMultipleColor => isDarkMode 
      ? AppColorsV2.darkPrimary 
      : AppColorsV2.primary;
  
  /// Stock level background colors (adapts to dark/light mode)
  Color get stockHighBgColor => isDarkMode 
      ? AppColorsV2.darkSuccess.withValues(alpha: 0.2) 
      : AppColorsV2.successPale;
  
  Color get stockMediumBgColor => isDarkMode 
      ? AppColorsV2.darkWarning.withValues(alpha: 0.2) 
      : AppColorsV2.warningPale;
  
  Color get stockLowBgColor => isDarkMode 
      ? AppColorsV2.darkError.withValues(alpha: 0.2) 
      : AppColorsV2.errorPale;
}
