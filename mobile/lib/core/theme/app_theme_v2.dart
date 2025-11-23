import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors_v2.dart';

// ============================================
// 🎨 HIVORK THEME V2
// The Most Delicious UI You'll Ever Taste!
// ============================================

class AppThemeV2 {
  // ==========================================
  // ☀️ LIGHT THEME - Warm & Energetic
  // ==========================================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // 🎨 Color Scheme - Carefully crafted for maximum delight
    colorScheme: const ColorScheme.light(
      primary: AppColorsV2.primary,
      primaryContainer: AppColorsV2.primaryPale,
      onPrimary: AppColorsV2.textOnPrimary,
      onPrimaryContainer: AppColorsV2.primaryDark,
      
      secondary: AppColorsV2.secondary,
      secondaryContainer: AppColorsV2.secondaryPale,
      onSecondary: AppColorsV2.textOnSecondary,
      onSecondaryContainer: AppColorsV2.secondaryDark,
      
      tertiary: AppColorsV2.accent,
      tertiaryContainer: AppColorsV2.accentPale,
      onTertiary: AppColorsV2.textOnPrimary,
      onTertiaryContainer: AppColorsV2.accentDark,
      
      surface: AppColorsV2.surface,
      surfaceContainerHighest: AppColorsV2.surfaceElevated,
      surfaceTint: AppColorsV2.primary,
      onSurface: AppColorsV2.textPrimary,
      onSurfaceVariant: AppColorsV2.textSecondary,
      
      error: AppColorsV2.error,
      errorContainer: AppColorsV2.errorPale,
      onError: AppColorsV2.textOnPrimary,
      onErrorContainer: AppColorsV2.errorDark,
      
      outline: AppColorsV2.border,
      outlineVariant: AppColorsV2.borderLight,
      shadow: AppColorsV2.shadow,
      scrim: AppColorsV2.overlay,
      
      inverseSurface: AppColorsV2.textPrimary,
      onInverseSurface: AppColorsV2.surface,
      inversePrimary: AppColorsV2.primaryLight,
    ),
    
    scaffoldBackgroundColor: AppColorsV2.background,
    fontFamily: 'Vazirmatn',
    
    // 📱 AppBar - Elegant & Clean
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsV2.surface,
      foregroundColor: AppColorsV2.textPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shadowColor: AppColorsV2.shadowMedium,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColorsV2.surface,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      iconTheme: IconThemeData(
        color: AppColorsV2.primary,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColorsV2.textSecondary,
        size: 22,
      ),
    ),
    
    // 📦 Card - Beautiful containers
    cardTheme: CardThemeData(
      color: AppColorsV2.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 3,
      shadowColor: AppColorsV2.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColorsV2.borderLight,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    
    // ✏️ Input Fields - Smooth & Inviting
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColorsV2.surface,
      hoverColor: AppColorsV2.surfaceHover,
      focusColor: AppColorsV2.primaryPale,
      
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.primary, width: 2.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.error, width: 2.5),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColorsV2.borderLight, width: 1),
      ),
      
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      
      hintStyle: const TextStyle(
        color: AppColorsV2.textTertiary,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: const TextStyle(
        color: AppColorsV2.textSecondary,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      floatingLabelStyle: const TextStyle(
        color: AppColorsV2.primary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      errorStyle: const TextStyle(
        color: AppColorsV2.error,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      
      prefixIconColor: AppColorsV2.textTertiary,
      suffixIconColor: AppColorsV2.textTertiary,
    ),
    
    // 🔘 Elevated Button - Bold & Confident
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColorsV2.primary,
        foregroundColor: AppColorsV2.textOnPrimary,
        disabledBackgroundColor: AppColorsV2.borderMedium,
        disabledForegroundColor: AppColorsV2.textDisabled,
        
        elevation: 4,
        shadowColor: AppColorsV2.shadowMedium,
        
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        minimumSize: const Size(120, 50),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        
        // Hover & Press effects
        overlayColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColorsV2.primaryDark.withValues(alpha: 0.2);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColorsV2.primaryLight.withValues(alpha: 0.1);
          }
          return AppColorsV2.primary.withValues(alpha: 0.05);
        }),
      ),
    ),
    
    // 🔘 Outlined Button - Refined & Elegant
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColorsV2.primary,
        disabledForegroundColor: AppColorsV2.textDisabled,
        
        side: const BorderSide(color: AppColorsV2.primary, width: 2),
        
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
        minimumSize: const Size(120, 50),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          height: 1.2,
        ),
        
        overlayColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColorsV2.primary.withValues(alpha: 0.15);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColorsV2.primary.withValues(alpha: 0.08);
          }
          return AppColorsV2.primary.withValues(alpha: 0.05);
        }),
      ),
    ),
    
    // 🔘 Text Button - Subtle & Smart
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColorsV2.primary,
        disabledForegroundColor: AppColorsV2.textDisabled,
        
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        minimumSize: const Size(80, 44),
        
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        
        textStyle: const TextStyle(
          fontFamily: 'Vazirmatn',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
        
        overlayColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return AppColorsV2.primary.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return AppColorsV2.primary.withValues(alpha: 0.06);
          }
          return AppColorsV2.primary.withValues(alpha: 0.03);
        }),
      ),
    ),
    
    // 🔘 Icon Button - Clean & Minimal
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: AppColorsV2.textSecondary,
        hoverColor: AppColorsV2.hover,
        highlightColor: AppColorsV2.pressed,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
      ),
    ),
    
    // ➕ Floating Action Button - Eye-catching!
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsV2.primary,
      foregroundColor: AppColorsV2.textOnPrimary,
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      extendedTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    
    // 🎚️ Switch - Smooth Toggle
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsV2.primary;
        }
        return AppColorsV2.borderMedium;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsV2.primaryLight.withValues(alpha: 0.5);
        }
        return AppColorsV2.border;
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),
    
    // ☑️ Checkbox - Clear Selection
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsV2.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(AppColorsV2.textOnPrimary),
      side: const BorderSide(color: AppColorsV2.border, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    ),
    
    // 🔘 Radio - Clean Choice
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColorsV2.primary;
        }
        return AppColorsV2.border;
      }),
    ),
    
    // 📊 Progress Indicators
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColorsV2.primary,
      linearTrackColor: AppColorsV2.primaryPale,
      circularTrackColor: AppColorsV2.primaryPale,
    ),
    
    // 📜 List Tile - Organized Content
    listTileTheme: const ListTileThemeData(
      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      titleTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        height: 1.4,
      ),
      subtitleTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColorsV2.textSecondary,
        height: 1.4,
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textTertiary,
      ),
      iconColor: AppColorsV2.primary,
      tileColor: Colors.transparent,
    ),
    
    // 🎭 Chip - Cute Tags
    chipTheme: ChipThemeData(
      backgroundColor: AppColorsV2.primaryPale,
      deleteIconColor: AppColorsV2.primary,
      disabledColor: AppColorsV2.borderLight,
      selectedColor: AppColorsV2.primary,
      secondarySelectedColor: AppColorsV2.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      labelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.primary,
      ),
      secondaryLabelStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textOnPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: AppColorsV2.primary,
          width: 1.5,
        ),
      ),
      brightness: Brightness.light,
    ),
    
    // 🎯 Divider - Subtle Separation
    dividerTheme: const DividerThemeData(
      color: AppColorsV2.divider,
      thickness: 1,
      space: 20,
    ),
    
    // 📱 Bottom Navigation Bar
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColorsV2.surface,
      selectedItemColor: AppColorsV2.primary,
      unselectedItemColor: AppColorsV2.textTertiary,
      selectedIconTheme: IconThemeData(
        color: AppColorsV2.primary,
        size: 26,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColorsV2.textTertiary,
        size: 24,
      ),
      selectedLabelStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // 🎨 Text Theme - Beautiful Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColorsV2.textPrimary,
        letterSpacing: -1,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.8,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.6,
        height: 1.3,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.4,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.3,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textSecondary,
        letterSpacing: -0.2,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.1,
        height: 1.6,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.1,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColorsV2.textSecondary,
        letterSpacing: 0,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.1,
        height: 1.3,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColorsV2.textSecondary,
        letterSpacing: 0,
        height: 1.3,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.textTertiary,
        letterSpacing: 0.1,
        height: 1.3,
      ),
    ),
    
    // 🎪 Dialogs & Bottom Sheets
    dialogTheme: DialogThemeData(
      backgroundColor: AppColorsV2.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shadowColor: AppColorsV2.shadowStrong,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.textPrimary,
        letterSpacing: -0.4,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColorsV2.textSecondary,
        height: 1.5,
      ),
    ),
    
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColorsV2.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      modalElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      showDragHandle: true,
      dragHandleColor: AppColorsV2.borderMedium,
    ),
    
    // 🎪 Snackbar - Quick Feedback
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColorsV2.textPrimary,
      contentTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.surface,
      ),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 6,
      actionTextColor: AppColorsV2.primary,
    ),
    
    // 🎯 Tooltip - Helpful Hints
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: AppColorsV2.textPrimary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColorsV2.surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      waitDuration: const Duration(milliseconds: 500),
    ),
    
    // 🎨 More UI Elements...
    tabBarTheme: const TabBarThemeData(
      labelColor: AppColorsV2.primary,
      unselectedLabelColor: AppColorsV2.textTertiary,
      indicatorColor: AppColorsV2.primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
      unselectedLabelStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 15,
        fontWeight: FontWeight.w500,
        letterSpacing: -0.2,
      ),
    ),
    
    expansionTileTheme: const ExpansionTileThemeData(
      textColor: AppColorsV2.textPrimary,
      iconColor: AppColorsV2.primary,
      collapsedTextColor: AppColorsV2.textSecondary,
      collapsedIconColor: AppColorsV2.textTertiary,
      backgroundColor: AppColorsV2.surface,
      collapsedBackgroundColor: AppColorsV2.surface,
      tilePadding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      childrenPadding: EdgeInsets.all(20),
    ),
    
    // Other properties...
    splashColor: AppColorsV2.primary.withValues(alpha: 0.12),
    highlightColor: AppColorsV2.primary.withValues(alpha: 0.08),
    focusColor: AppColorsV2.focusRing,
    hoverColor: AppColorsV2.hover,
    
    visualDensity: VisualDensity.adaptivePlatformDensity,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
  );
  
  // ==========================================
  // 🌙 DARK THEME - Sophisticated & Cozy
  // ==========================================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // 🎨 Dark Color Scheme
    colorScheme: const ColorScheme.dark(
      primary: AppColorsV2.darkPrimary,
      primaryContainer: AppColorsV2.darkPrimaryPale,
      onPrimary: AppColorsV2.textPrimary,
      onPrimaryContainer: AppColorsV2.darkPrimaryLight,
      
      secondary: AppColorsV2.darkSecondary,
      secondaryContainer: AppColorsV2.darkSecondaryPale,
      onSecondary: AppColorsV2.textPrimary,
      onSecondaryContainer: AppColorsV2.darkSecondaryLight,
      
      tertiary: AppColorsV2.darkWarning,
      tertiaryContainer: AppColorsV2.warningDark,
      onTertiary: AppColorsV2.textPrimary,
      
      surface: AppColorsV2.darkSurface,
      surfaceContainerHighest: AppColorsV2.darkSurfaceElevated,
      surfaceTint: AppColorsV2.darkPrimary,
      onSurface: AppColorsV2.darkTextPrimary,
      onSurfaceVariant: AppColorsV2.darkTextSecondary,
      
      error: AppColorsV2.darkError,
      errorContainer: AppColorsV2.errorDark,
      onError: AppColorsV2.textPrimary,
      
      outline: AppColorsV2.darkBorder,
      outlineVariant: AppColorsV2.darkBorderLight,
      shadow: AppColorsV2.darkShadow,
      scrim: AppColorsV2.overlay,
      
      inverseSurface: AppColorsV2.surface,
      onInverseSurface: AppColorsV2.textPrimary,
      inversePrimary: AppColorsV2.primary,
    ),
    
    scaffoldBackgroundColor: AppColorsV2.darkBackground,
    fontFamily: 'Vazirmatn',
    
    // 📱 Dark AppBar
    appBarTheme: AppBarTheme(
      backgroundColor: AppColorsV2.darkSurface,
      foregroundColor: AppColorsV2.darkTextPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      shadowColor: AppColorsV2.darkShadowMedium,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: AppColorsV2.darkSurface,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      titleTextStyle: const TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 19,
        fontWeight: FontWeight.w700,
        color: AppColorsV2.darkTextPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      ),
      iconTheme: IconThemeData(
        color: AppColorsV2.darkPrimary,
        size: 24,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColorsV2.darkTextSecondary,
        size: 22,
      ),
    ),
    
    // Similar dark mode configurations for other components...
    // (Card, Input, Buttons, etc. with dark colors)
    
    cardTheme: CardThemeData(
      color: AppColorsV2.darkSurface,
      surfaceTintColor: Colors.transparent,
      elevation: 4,
      shadowColor: AppColorsV2.darkShadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: AppColorsV2.darkBorderLight,
          width: 1,
        ),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
    ),
    
    // Continue with all other theme properties using dark colors...
    // (Following the same pattern as light theme but with AppColorsV2.dark* colors)
    
    // ➕ Floating Action Button - Dark Mode
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColorsV2.darkPrimary,
      foregroundColor: AppColorsV2.textPrimary,
      elevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(18)),
      ),
      extendedPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      extendedTextStyle: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
    ),
    
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Vazirmatn',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: AppColorsV2.darkTextPrimary,
        letterSpacing: -1,
        height: 1.2,
      ),
      // ... other text styles with dark colors
    ),
    
    splashColor: AppColorsV2.darkPrimary.withValues(alpha: 0.12),
    highlightColor: AppColorsV2.darkPrimary.withValues(alpha: 0.08),
    focusColor: AppColorsV2.darkFocusRing,
    hoverColor: AppColorsV2.darkHover,
    
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );
}
