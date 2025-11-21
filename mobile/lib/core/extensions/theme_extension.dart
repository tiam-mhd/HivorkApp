import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

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
  
  // ============================================
  // ATTRIBUTE & VARIANT SPECIFIC COLORS
  // ============================================
  
  /// Attribute data type colors (adapts to dark/light mode)
  Color get attributeTextColor => isDarkMode 
      ? AppColors.darkAttributeText 
      : AppColors.attributeText;
  
  Color get attributeNumberColor => isDarkMode 
      ? AppColors.darkAttributeNumber 
      : AppColors.attributeNumber;
  
  Color get attributeSelectColor => isDarkMode 
      ? AppColors.darkAttributeSelect 
      : AppColors.attributeSelect;
  
  Color get attributeColorColor => isDarkMode 
      ? AppColors.darkAttributeColor 
      : AppColors.attributeColor;
  
  Color get attributeBooleanColor => isDarkMode 
      ? AppColors.darkAttributeBoolean 
      : AppColors.attributeBoolean;
  
  Color get attributeDateColor => isDarkMode 
      ? AppColors.darkAttributeDate 
      : AppColors.attributeDate;
  
  /// Variant status colors (adapts to dark/light mode)
  Color get variantActiveColor => isDarkMode 
      ? AppColors.darkVariantActive 
      : AppColors.variantActive;
  
  Color get variantLowStockColor => isDarkMode 
      ? AppColors.darkVariantLowStock 
      : AppColors.variantLowStock;
  
  Color get variantOutOfStockColor => isDarkMode 
      ? AppColors.darkVariantOutOfStock 
      : AppColors.variantOutOfStock;
  
  Color get variantInactiveColor => isDarkMode 
      ? AppColors.darkVariantInactive 
      : AppColors.variantInactive;
  
  /// Attribute scope colors (adapts to dark/light mode)
  Color get scopeFixedColor => isDarkMode 
      ? AppColors.darkScopeFixed 
      : AppColors.scopeFixed;
  
  Color get scopeVariableColor => isDarkMode 
      ? AppColors.darkScopeVariable 
      : AppColors.scopeVariable;
  
  /// Attribute cardinality colors (adapts to dark/light mode)
  Color get cardinalitySingleColor => isDarkMode 
      ? AppColors.darkCardinalitySingle 
      : AppColors.cardinalitySingle;
  
  Color get cardinalityMultipleColor => isDarkMode 
      ? AppColors.darkCardinalityMultiple 
      : AppColors.cardinalityMultiple;
  
  /// Stock level background colors (adapts to dark/light mode)
  Color get stockHighBgColor => isDarkMode 
      ? AppColors.darkStockHighBg 
      : AppColors.stockHighBg;
  
  Color get stockMediumBgColor => isDarkMode 
      ? AppColors.darkStockMediumBg 
      : AppColors.stockMediumBg;
  
  Color get stockLowBgColor => isDarkMode 
      ? AppColors.darkStockLowBg 
      : AppColors.stockLowBg;
}

