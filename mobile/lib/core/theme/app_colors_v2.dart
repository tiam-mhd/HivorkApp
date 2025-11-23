import 'package:flutter/material.dart';

// ============================================
// 🎨 HIVORK COLOR PALETTE V2
// Brand Color: #EF7F1A (Vibrant Orange)
// ============================================
// 
// Design Philosophy:
// - Warm & Inviting: Orange creates energy and friendliness
// - Professional: Balanced with sophisticated neutrals
// - High Contrast: Excellent readability
// - Accessible: WCAG AA+ compliance
// - Delicious: Colors so good you'll want to lick your screen! 🍊
//
// ============================================

class AppColorsV2 {
  // ==========================================
  // 🧡 PRIMARY - VIBRANT ORANGE (Brand)
  // ==========================================
  static const Color primary = Color(0xFFEF7F1A); // Main brand - Pure energy!
  static const Color primaryDark = Color(0xFFD66A0A); // Deeper intensity
  static const Color primaryLight = Color(0xFFFF9842); // Soft glow
  static const Color primaryPale = Color(0xFFFFE5D0); // Gentle whisper
  
  // ==========================================
  // 💙 SECONDARY - DEEP TEAL (Trust & Stability)
  // ==========================================
  static const Color secondary = Color(0xFF0D7C7C); // Professional teal
  static const Color secondaryDark = Color(0xFF06524E); // Ocean depth
  static const Color secondaryLight = Color(0xFF12A5A5); // Fresh mint
  static const Color secondaryPale = Color(0xFFD0F2F2); // Misty morning
  
  // ==========================================
  // ✨ ACCENT - GOLDEN AMBER (Success & Joy)
  // ==========================================
  static const Color accent = Color(0xFFFFC107); // Golden sunshine
  static const Color accentDark = Color(0xFFE5A600); // Rich honey
  static const Color accentLight = Color(0xFFFFD54F); // Warm glow
  static const Color accentPale = Color(0xFFFFF8E1); // Butter cream
  
  // ==========================================
  // 🌅 LIGHT MODE - Warm & Airy
  // ==========================================
  
  // Backgrounds
  static const Color background = Color(0xFFFFFBF7); // Warm cloud white
  static const Color backgroundSubtle = Color(0xFFFFF6EF); // Peachy mist
  static const Color surface = Color(0xFFFFFFFF); // Pure snow
  static const Color surfaceElevated = Color(0xFFFFFAF5); // Lifted silk
  static const Color surfaceHover = Color(0xFFFFF3E8); // Gentle touch
  
  // Text - Rich & Readable
  static const Color textPrimary = Color(0xFF1F1612); // Deep cocoa
  static const Color textSecondary = Color(0xFF5C4A3D); // Rich coffee
  static const Color textTertiary = Color(0xFF8C7865); // Soft caramel
  static const Color textDisabled = Color(0xFFBFB1A3); // Pale latte
  static const Color textOnPrimary = Color(0xFFFFFFFF); // Crisp white
  static const Color textOnSecondary = Color(0xFFFFFFFF); // Pure white
  static const Color textOnDark = Color(0xFFFFFFFF); // Clean white
  
  // Borders & Lines
  static const Color border = Color(0xFFE8DDD0); // Warm sand
  static const Color borderLight = Color(0xFFF5EDE3); // Soft cream
  static const Color borderMedium = Color(0xFFD4C4B3); // Toast edge
  static const Color divider = Color(0xFFF0E6DB); // Subtle line
  
  // Shadows & Overlays
  static const Color shadow = Color(0x14EF7F1A); // Warm glow
  static const Color shadowMedium = Color(0x24EF7F1A); // Soft depth
  static const Color shadowStrong = Color(0x38EF7F1A); // Rich dimension
  static const Color overlay = Color(0x80000000); // Smart blur
  static const Color overlayLight = Color(0x40000000); // Gentle veil
  
  // ==========================================
  // 🌙 DARK MODE - Sophisticated & Cozy
  // ==========================================
  
  // Backgrounds
  static const Color darkBackground = Color(0xFF121212); // Deep night
  static const Color darkBackgroundSubtle = Color(0xFF1C1C1E); // Modern charcoal
  static const Color darkSurface = Color(0xFF252529); // Clean slate
  static const Color darkSurfaceElevated = Color(0xFF2C2C31); // Elevated card
  static const Color darkSurfaceHover = Color(0xFF35353A); // Smooth hover
  
  // Primary in Dark - Glowing Orange
  static const Color darkPrimary = Color(0xFFFF9842); // Luminous ember
  static const Color darkPrimaryDark = Color(0xFFEF7F1A); // Core flame
  static const Color darkPrimaryLight = Color(0xFFFFB16D); // Soft radiance
  static const Color darkPrimaryPale = Color(0xFF332615); // Subtle glow
  
  // Secondary in Dark - Cool Teal
  static const Color darkSecondary = Color(0xFF12A5A5); // Crystal water
  static const Color darkSecondaryDark = Color(0xFF0D7C7C); // Deep pool
  static const Color darkSecondaryLight = Color(0xFF4DBDBD); // Frosted mint
  static const Color darkSecondaryPale = Color(0xFF0F2D2D); // Ocean floor
  
  // Text in Dark
  static const Color darkTextPrimary = Color(0xFFFFFBF7); // Warm ivory
  static const Color darkTextSecondary = Color(0xFFE5E5E7); // Soft silver
  static const Color darkTextTertiary = Color(0xFF98989D); // Muted gray
  static const Color darkTextDisabled = Color(0xFF636366); // Cool dim
  
  // Borders in Dark
  static const Color darkBorder = Color(0xFF38383D); // Subtle edge
  static const Color darkBorderLight = Color(0xFF2C2C31); // Faint line
  static const Color darkBorderMedium = Color(0xFF48484D); // Defined edge
  static const Color darkDivider = Color(0xFF2C2C31); // Soft separation
  
  // Shadows in Dark
  static const Color darkShadow = Color(0x60000000); // Deep dimension
  static const Color darkShadowMedium = Color(0x40000000); // Medium depth
  static const Color darkShadowStrong = Color(0x80000000); // Rich contrast
  
  // ==========================================
  // 🎯 STATUS COLORS (Universal)
  // ==========================================
  
  // Success - Fresh Green
  static const Color success = Color(0xFF10B981); // Vibrant life
  static const Color successDark = Color(0xFF059669); // Deep forest
  static const Color successLight = Color(0xFF34D399); // Spring leaf
  static const Color successPale = Color(0xFFD1FAE5); // Mint cream
  static const Color darkSuccess = Color(0xFF34D399); // Night garden
  
  // Warning - Golden Alert
  static const Color warning = Color(0xFFFFC107); // Attention gold
  static const Color warningDark = Color(0xFFE5A600); // Amber alert
  static const Color warningLight = Color(0xFFFFD54F); // Soft caution
  static const Color warningPale = Color(0xFFFFF8E1); // Gentle notice
  static const Color darkWarning = Color(0xFFFFD54F); // Night beacon
  
  // Error - Bold Red
  static const Color error = Color(0xFFDC2626); // Clear danger
  static const Color errorDark = Color(0xFFB91C1C); // Deep alert
  static const Color errorLight = Color(0xFFEF4444); // Bright warning
  static const Color errorPale = Color(0xFFFEE2E2); // Soft pink
  static const Color darkError = Color(0xFFF87171); // Night alert
  
  // Info - Cool Blue
  static const Color info = Color(0xFF0D7C7C); // Calm information
  static const Color infoDark = Color(0xFF06524E); // Deep knowledge
  static const Color infoLight = Color(0xFF12A5A5); // Clear message
  static const Color infoPale = Color(0xFFD0F2F2); // Soft notice
  static const Color darkInfo = Color(0xFF4DBDBD); // Night guide
  
  // ==========================================
  // 🎨 SPECIAL COLORS (UI Enhancements)
  // ==========================================
  
  // Gradients - Light Mode
  static const List<Color> primaryGradient = [
    Color(0xFFEF7F1A), // Brand orange
    Color(0xFFFF9842), // Warm glow
  ];
  
  static const List<Color> secondaryGradient = [
    Color(0xFF0D7C7C), // Deep teal
    Color(0xFF12A5A5), // Fresh mint
  ];
  
  static const List<Color> accentGradient = [
    Color(0xFFFFC107), // Golden
    Color(0xFFFFD54F), // Sunshine
  ];
  
  static const List<Color> warmGradient = [
    Color(0xFFEF7F1A), // Orange
    Color(0xFFFFC107), // Gold
  ];
  
  static const List<Color> coolGradient = [
    Color(0xFF0D7C7C), // Teal
    Color(0xFF12A5A5), // Mint
  ];
  
  // Gradients - Dark Mode
  static const List<Color> darkPrimaryGradient = [
    Color(0xFFFF9842),
    Color(0xFFFFB16D),
  ];
  
  static const List<Color> darkSecondaryGradient = [
    Color(0xFF12A5A5),
    Color(0xFF4DBDBD),
  ];
  
  // Chart Colors (Data Visualization)
  static const List<Color> chartColors = [
    Color(0xFFEF7F1A), // Orange
    Color(0xFF0D7C7C), // Teal
    Color(0xFFFFC107), // Gold
    Color(0xFF10B981), // Green
    Color(0xFFDC2626), // Red
    Color(0xFF8B5CF6), // Purple
    Color(0xFFEC4899), // Pink
    Color(0xFF06B6D4), // Cyan
  ];
  
  // ==========================================
  // 🎭 SEMANTIC COLORS (Contextual Use)
  // ==========================================
  
  // Highlights & Selections
  static const Color highlight = Color(0xFFFFE5D0); // Soft peach
  static const Color highlightStrong = Color(0xFFFFB97D); // Bold selection
  static const Color darkHighlight = Color(0xFF4A3118); // Night selection
  static const Color darkHighlightStrong = Color(0xFF6B4726); // Bold dark
  
  // Focus & Active States
  static const Color focus = Color(0xFFEF7F1A); // Brand focus
  static const Color focusRing = Color(0x40EF7F1A); // Soft glow ring
  static const Color darkFocus = Color(0xFFFF9842); // Night focus
  static const Color darkFocusRing = Color(0x40FF9842); // Dark glow
  
  // Interactive States
  static const Color hover = Color(0xFFFFF3E8); // Gentle hover
  static const Color pressed = Color(0xFFFFE5D0); // Pressed state
  static const Color darkHover = Color(0xFF342D25); // Dark hover
  static const Color darkPressed = Color(0xFF3E362C); // Dark pressed
  
  // Badges & Tags
  static const Color badge = Color(0xFFEF7F1A); // Primary badge
  static const Color badgeSuccess = Color(0xFF10B981); // Success tag
  static const Color badgeWarning = Color(0xFFFFC107); // Warning badge
  static const Color badgeError = Color(0xFFDC2626); // Error tag
  static const Color badgeInfo = Color(0xFF0D7C7C); // Info badge
  
  // ==========================================
  // 🌈 HELPER METHODS
  // ==========================================
  
  /// Get adaptive color based on brightness
  static Color adaptive(BuildContext context, Color light, Color dark) {
    return Theme.of(context).brightness == Brightness.dark ? dark : light;
  }
  
  /// Get primary color based on theme
  static Color getPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkPrimary 
        : primary;
  }
  
  /// Get background color based on theme
  static Color getBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkBackground 
        : background;
  }
  
  /// Get surface color based on theme
  static Color getSurface(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkSurface 
        : surface;
  }
  
  /// Get text primary color based on theme
  static Color getTextPrimary(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark 
        ? darkTextPrimary 
        : textPrimary;
  }
}
