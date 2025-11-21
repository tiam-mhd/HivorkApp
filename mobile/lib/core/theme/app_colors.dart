import 'package:flutter/material.dart';

// ============================================
// OLD COLOR PALETTE (Commented for backup)
// ============================================
// class AppColors {
//   // Primary Colors
//   static const Color primary = Color(0xFF2563EB);
//   static const Color primaryDark = Color(0xFF1E40AF);
//   static const Color primaryLight = Color(0xFF60A5FA);
//   
//   // Secondary Colors
//   static const Color secondary = Color(0xFF10B981);
//   static const Color secondaryDark = Color(0xFF059669);
//   static const Color secondaryLight = Color(0xFF34D399);
//   
//   // Neutral Colors
//   static const Color background = Color(0xFFF9FAFB);
//   static const Color surface = Color(0xFFFFFFFF);
//   static const Color surfaceVariant = Color(0xFFF3F4F6);
//   
//   // Text Colors
//   static const Color textPrimary = Color(0xFF111827);
//   static const Color textSecondary = Color(0xFF6B7280);
//   static const Color textDisabled = Color(0xFF9CA3AF);
//   
//   // Status Colors
//   static const Color success = Color(0xFF10B981);
//   static const Color warning = Color(0xFFF59E0B);
//   static const Color error = Color(0xFFEF4444);
//   static const Color info = Color(0xFF3B82F6);
//   
//   // Border & Divider
//   static const Color border = Color(0xFFE5E7EB);
//   static const Color divider = Color(0xFFE5E7EB);
//   
//   // Shadows
//   static const Color shadow = Color(0x1A000000);
// }

// ============================================
// NEW COLOR PALETTE (Based on #F47A20)
// Warm & Professional Theme
// ============================================
class AppColors {
  // Primary Colors - Energetic Orange
  static const Color primary = Color(0xFFF47A20); // Main brand color
  static const Color primaryDark = Color(0xFFD66310); // Darker for contrast
  static const Color primaryLight = Color(0xFFFF9E5C); // Lighter for highlights
  
  // Secondary Colors - Complementary Deep Blue
  static const Color secondary = Color(0xFF2D5F8D); // Cool balance to warm orange
  static const Color secondaryDark = Color(0xFF1A4469);
  static const Color secondaryLight = Color(0xFF4A7BAA);
  
  // Accent Colors
  static const Color accent = Color(0xFFFFB84D); // Golden amber for accents
  static const Color accentLight = Color(0xFFFFC976);
  
  // Neutral Colors - Light Mode
  static const Color background = Color(0xFFFFFBF7); // Warm white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceVariant = Color(0xFFFFF3EB); // Very light peach
  static const Color surfaceElevated = Color(0xFFFFF8F2); // Subtle elevation
  
  // Text Colors - Light Mode
  static const Color textPrimary = Color(0xFF2C2416); // Warm dark brown
  static const Color textSecondary = Color(0xFF6B5D4F); // Medium brown
  static const Color textTertiary = Color(0xFF9B8B7A); // Light brown
  static const Color textDisabled = Color(0xFFC4B9AD);
  static const Color textOnPrimary = Color(0xFFFFFFFF); // White text on orange
  static const Color textOnSecondary = Color(0xFFFFFFFF); // White text on blue
  
  // Status Colors
  static const Color success = Color(0xFF10B981); // Keep green for success
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Keep amber for warning
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFDC2626); // Keep red for error
  static const Color errorLight = Color(0xFFEF4444);
  static const Color info = Color(0xFF2D5F8D); // Use secondary blue
  static const Color infoLight = Color(0xFF4A7BAA);
  
  // Border & Divider - Light Mode
  static const Color border = Color(0xFFE8DDD0); // Warm beige
  static const Color borderLight = Color(0xFFF3EDE3);
  static const Color divider = Color(0xFFEFE6DB);
  
  // Shadows - Light Mode
  static const Color shadow = Color(0x1AF47A20); // Orange tinted shadow
  static const Color shadowLight = Color(0x0DF47A20);
  
  // Gradients - Light Mode
  static const List<Color> primaryGradient = [
    Color(0xFFF47A20),
    Color(0xFFFF9E5C),
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF2D5F8D),
    Color(0xFF4A7BAA),
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFFB84D),
    Color(0xFFFFC976),
  ];
  
  // ============================================
  // DARK MODE COLORS
  // Sophisticated Dark Theme
  // ============================================
  
  // Background Colors - Dark Mode
  static const Color darkBackground = Color(0xFF1A1410); // Very dark warm brown
  static const Color darkSurface = Color(0xFF2C2416); // Dark brown surface
  static const Color darkSurfaceVariant = Color(0xFF3D3325); // Medium brown
  static const Color darkSurfaceElevated = Color(0xFF4A3F31); // Elevated brown
  
  // Primary Colors - Dark Mode (Slightly muted)
  static const Color darkPrimary = Color(0xFFFF9E5C); // Brighter orange for dark bg
  static const Color darkPrimaryDark = Color(0xFFF47A20);
  static const Color darkPrimaryLight = Color(0xFFFFB97D);
  
  // Secondary Colors - Dark Mode
  static const Color darkSecondary = Color(0xFF5B8DB8); // Lighter blue for dark bg
  static const Color darkSecondaryDark = Color(0xFF4A7BAA);
  static const Color darkSecondaryLight = Color(0xFF7AADCE);
  
  // Text Colors - Dark Mode
  static const Color darkTextPrimary = Color(0xFFFFF8F2); // Warm white
  static const Color darkTextSecondary = Color(0xFFD4C4B3); // Light beige
  static const Color darkTextTertiary = Color(0xFFA89683); // Medium beige
  static const Color darkTextDisabled = Color(0xFF6B5D4F);
  
  // Border & Divider - Dark Mode
  static const Color darkBorder = Color(0xFF4A3F31);
  static const Color darkBorderLight = Color(0xFF3D3325);
  static const Color darkDivider = Color(0xFF3D3325);
  
  // Shadows - Dark Mode
  static const Color darkShadow = Color(0x40000000); // Deeper shadow
  static const Color darkShadowLight = Color(0x20000000);
  
  // Status Colors - Dark Mode (Adjusted for visibility)
  static const Color darkSuccess = Color(0xFF34D399);
  static const Color darkWarning = Color(0xFFFBBF24);
  static const Color darkError = Color(0xFFF87171);
  static const Color darkInfo = Color(0xFF7AADCE);
  
  // ============================================
  // ATTRIBUTE & VARIANT SPECIFIC COLORS
  // For Product Attributes & Variants System
  // ============================================
  
  // Attribute Type Colors - Light Mode
  static const Color attributeText = Color(0xFF6366F1); // Indigo for text
  static const Color attributeNumber = Color(0xFF10B981); // Green for number
  static const Color attributeSelect = Color(0xFF8B5CF6); // Purple for select
  static const Color attributeColor = Color(0xFFEC4899); // Pink for color
  static const Color attributeBoolean = Color(0xFF06B6D4); // Cyan for boolean
  static const Color attributeDate = Color(0xFFF59E0B); // Amber for date
  
  // Attribute Type Colors - Dark Mode
  static const Color darkAttributeText = Color(0xFF818CF8);
  static const Color darkAttributeNumber = Color(0xFF34D399);
  static const Color darkAttributeSelect = Color(0xFFA78BFA);
  static const Color darkAttributeColor = Color(0xFFF472B6);
  static const Color darkAttributeBoolean = Color(0xFF22D3EE);
  static const Color darkAttributeDate = Color(0xFFFBBF24);
  
  // Variant Status Colors - Light Mode
  static const Color variantActive = Color(0xFF10B981); // Green
  static const Color variantLowStock = Color(0xFFF59E0B); // Amber
  static const Color variantOutOfStock = Color(0xFFDC2626); // Red
  static const Color variantInactive = Color(0xFF6B7280); // Gray
  
  // Variant Status Colors - Dark Mode
  static const Color darkVariantActive = Color(0xFF34D399);
  static const Color darkVariantLowStock = Color(0xFFFBBF24);
  static const Color darkVariantOutOfStock = Color(0xFFF87171);
  static const Color darkVariantInactive = Color(0xFF9CA3AF);
  
  // Attribute Scope Colors - Light Mode
  static const Color scopeFixed = Color(0xFF2D5F8D); // Secondary blue for fixed
  static const Color scopeVariable = Color(0xFFF47A20); // Primary orange for variable
  
  // Attribute Scope Colors - Dark Mode
  static const Color darkScopeFixed = Color(0xFF5B8DB8);
  static const Color darkScopeVariable = Color(0xFFFF9E5C);
  
  // Cardinality Colors - Light Mode
  static const Color cardinalitySingle = Color(0xFF6366F1); // Indigo
  static const Color cardinalityMultiple = Color(0xFF8B5CF6); // Purple
  
  // Cardinality Colors - Dark Mode
  static const Color darkCardinalitySingle = Color(0xFF818CF8);
  static const Color darkCardinalityMultiple = Color(0xFFA78BFA);
  
  // Stock Level Backgrounds - Light Mode
  static const Color stockHighBg = Color(0xFFD1FAE5); // Light green
  static const Color stockMediumBg = Color(0xFFFEF3C7); // Light amber
  static const Color stockLowBg = Color(0xFFFEE2E2); // Light red
  
  // Stock Level Backgrounds - Dark Mode
  static const Color darkStockHighBg = Color(0xFF064E3B);
  static const Color darkStockMediumBg = Color(0xFF78350F);
  static const Color darkStockLowBg = Color(0xFF7F1D1D);
}
