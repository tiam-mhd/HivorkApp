// import 'package:flutter/material.dart';
// import 'app_colors.dart';

// // ============================================
// // OLD THEME (Commented for backup)
// // ============================================
// // class AppTheme {
// //   static ThemeData lightTheme = ThemeData(
// //     useMaterial3: true,
// //     brightness: Brightness.light,
// //     colorScheme: ColorScheme.light(
// //       primary: AppColors.primary,
// //       secondary: AppColors.secondary,
// //       surface: AppColors.surface,
// //       error: AppColors.error,
// //       onPrimary: Colors.white,
// //       onSecondary: Colors.white,
// //       onSurface: AppColors.textPrimary,
// //       onError: Colors.white,
// //     ),
// //     scaffoldBackgroundColor: AppColors.background,
// //     fontFamily: 'Vazirmatn',
// //     
// //     appBarTheme: const AppBarTheme(...),
// //     cardTheme: CardThemeData(...),
// //     inputDecorationTheme: InputDecorationTheme(...),
// //     elevatedButtonTheme: ElevatedButtonThemeData(...),
// //     textButtonTheme: TextButtonThemeData(...),
// //     floatingActionButtonTheme: const FloatingActionButtonThemeData(...),
// //   );
// //   
// //   static ThemeData darkTheme = ThemeData(...);
// // }

// // ============================================
// // NEW THEME (Warm & Professional)
// // ============================================
// class AppTheme {
//   // ==================== LIGHT THEME ====================
//   static ThemeData lightTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.light,
    
//     // Color Scheme
//     colorScheme: const ColorScheme.light(
//       primary: AppColors.primary,
//       primaryContainer: AppColors.primaryLight,
//       secondary: AppColors.secondary,
//       secondaryContainer: AppColors.secondaryLight,
//       tertiary: AppColors.accent,
//       tertiaryContainer: AppColors.accentLight,
//       surface: AppColors.surface,
//       surfaceContainerHighest: AppColors.surfaceVariant,
//       error: AppColors.error,
//       errorContainer: AppColors.errorLight,
//       onPrimary: AppColors.textOnPrimary,
//       onSecondary: AppColors.textOnSecondary,
//       onSurface: AppColors.textPrimary,
//       onSurfaceVariant: AppColors.textSecondary,
//       onError: Colors.white,
//       outline: AppColors.border,
//       shadow: AppColors.shadow,
//     ),
    
//     scaffoldBackgroundColor: AppColors.background,
//     fontFamily: 'Vazirmatn',
    
//     // AppBar Theme
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.surface,
//       foregroundColor: AppColors.textPrimary,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       shadowColor: AppColors.shadowLight,
//       titleTextStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: AppColors.textPrimary,
//         letterSpacing: -0.3,
//       ),
//       iconTheme: IconThemeData(
//         color: AppColors.primary,
//         size: 24,
//       ),
//     ),
    
//     // Card Theme
//     cardTheme: CardThemeData(
//       color: AppColors.surface,
//       surfaceTintColor: Colors.transparent,
//       elevation: 2,
//       shadowColor: AppColors.shadowLight,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: const BorderSide(
//           color: AppColors.borderLight,
//           width: 1,
//         ),
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     ),
    
//     // Input Decoration Theme
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.surface,
//       hoverColor: AppColors.surfaceVariant,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.border, width: 1.5),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.border, width: 1.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.primary, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.error, width: 1.5),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.error, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       hintStyle: const TextStyle(
//         color: AppColors.textTertiary,
//         fontSize: 14,
//       ),
//       labelStyle: const TextStyle(
//         color: AppColors.textSecondary,
//         fontSize: 14,
//       ),
//       floatingLabelStyle: const TextStyle(
//         color: AppColors.primary,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
    
//     // Elevated Button Theme
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.primary,
//         foregroundColor: AppColors.textOnPrimary,
//         elevation: 4,
//         shadowColor: AppColors.shadow,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Outlined Button Theme
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         side: const BorderSide(color: AppColors.primary, width: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Text Button Theme
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: AppColors.primary,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Floating Action Button Theme
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: AppColors.primary,
//       foregroundColor: AppColors.textOnPrimary,
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//     ),
    
//     // Chip Theme
//     chipTheme: ChipThemeData(
//       backgroundColor: AppColors.surfaceVariant,
//       selectedColor: AppColors.primaryLight,
//       secondarySelectedColor: AppColors.secondaryLight,
//       labelStyle: const TextStyle(
//         color: AppColors.textPrimary,
//         fontFamily: 'Vazirmatn',
//       ),
//       secondaryLabelStyle: const TextStyle(
//         color: AppColors.textOnPrimary,
//         fontFamily: 'Vazirmatn',
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8),
//       ),
//     ),
    
//     // Divider Theme
//     dividerTheme: const DividerThemeData(
//       color: AppColors.divider,
//       thickness: 1,
//       space: 1,
//     ),
    
//     // Bottom Navigation Bar Theme
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: AppColors.surface,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: AppColors.textSecondary,
//       selectedLabelStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//       ),
//       unselectedLabelStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 12,
//         fontWeight: FontWeight.normal,
//       ),
//       type: BottomNavigationBarType.fixed,
//       elevation: 8,
//     ),
    
//     // Snackbar Theme
//     snackBarTheme: SnackBarThemeData(
//       backgroundColor: AppColors.textPrimary,
//       contentTextStyle: const TextStyle(
//         color: Colors.white,
//         fontFamily: 'Vazirmatn',
//         fontSize: 14,
//       ),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//   );
  
//   // ==================== DARK THEME ====================
//   static ThemeData darkTheme = ThemeData(
//     useMaterial3: true,
//     brightness: Brightness.dark,
    
//     // Color Scheme
//     colorScheme: const ColorScheme.dark(
//       primary: AppColors.darkPrimary,
//       primaryContainer: AppColors.darkPrimaryLight,
//       secondary: AppColors.darkSecondary,
//       secondaryContainer: AppColors.darkSecondaryLight,
//       tertiary: AppColors.accentLight,
//       surface: AppColors.darkSurface,
//       surfaceContainerHighest: AppColors.darkSurfaceVariant,
//       error: AppColors.darkError,
//       onPrimary: AppColors.textPrimary,
//       onSecondary: Colors.white,
//       onSurface: AppColors.darkTextPrimary,
//       onSurfaceVariant: AppColors.darkTextSecondary,
//       onError: Colors.white,
//       outline: AppColors.darkBorder,
//       shadow: AppColors.darkShadow,
//     ),
    
//     scaffoldBackgroundColor: AppColors.darkBackground,
//     fontFamily: 'Vazirmatn',
    
//     // AppBar Theme
//     appBarTheme: const AppBarTheme(
//       backgroundColor: AppColors.darkSurface,
//       foregroundColor: AppColors.darkTextPrimary,
//       surfaceTintColor: Colors.transparent,
//       elevation: 0,
//       centerTitle: true,
//       shadowColor: AppColors.darkShadowLight,
//       titleTextStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 18,
//         fontWeight: FontWeight.bold,
//         color: AppColors.darkTextPrimary,
//         letterSpacing: -0.3,
//       ),
//       iconTheme: IconThemeData(
//         color: AppColors.darkPrimary,
//         size: 24,
//       ),
//     ),
    
//     // Card Theme
//     cardTheme: CardThemeData(
//       color: AppColors.darkSurface,
//       surfaceTintColor: Colors.transparent,
//       elevation: 4,
//       shadowColor: AppColors.darkShadow,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//         side: const BorderSide(
//           color: AppColors.darkBorderLight,
//           width: 1,
//         ),
//       ),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//     ),
    
//     // Input Decoration Theme
//     inputDecorationTheme: InputDecorationTheme(
//       filled: true,
//       fillColor: AppColors.darkSurfaceVariant,
//       border: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
//       ),
//       enabledBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.darkBorder, width: 1.5),
//       ),
//       focusedBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.darkPrimary, width: 2),
//       ),
//       errorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.darkError, width: 1.5),
//       ),
//       focusedErrorBorder: OutlineInputBorder(
//         borderRadius: BorderRadius.circular(12),
//         borderSide: const BorderSide(color: AppColors.darkError, width: 2),
//       ),
//       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       hintStyle: const TextStyle(
//         color: AppColors.darkTextTertiary,
//         fontSize: 14,
//       ),
//       labelStyle: const TextStyle(
//         color: AppColors.darkTextSecondary,
//         fontSize: 14,
//       ),
//       floatingLabelStyle: const TextStyle(
//         color: AppColors.darkPrimary,
//         fontSize: 16,
//         fontWeight: FontWeight.w600,
//       ),
//     ),
    
//     // Elevated Button Theme
//     elevatedButtonTheme: ElevatedButtonThemeData(
//       style: ElevatedButton.styleFrom(
//         backgroundColor: AppColors.darkPrimary,
//         foregroundColor: AppColors.textPrimary,
//         elevation: 4,
//         shadowColor: AppColors.darkShadow,
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Outlined Button Theme
//     outlinedButtonTheme: OutlinedButtonThemeData(
//       style: OutlinedButton.styleFrom(
//         foregroundColor: AppColors.darkPrimary,
//         side: const BorderSide(color: AppColors.darkPrimary, width: 2),
//         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12),
//         ),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Text Button Theme
//     textButtonTheme: TextButtonThemeData(
//       style: TextButton.styleFrom(
//         foregroundColor: AppColors.darkPrimary,
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         textStyle: const TextStyle(
//           fontFamily: 'Vazirmatn',
//           fontSize: 16,
//           fontWeight: FontWeight.w600,
//           letterSpacing: -0.2,
//         ),
//       ),
//     ),
    
//     // Floating Action Button Theme
//     floatingActionButtonTheme: const FloatingActionButtonThemeData(
//       backgroundColor: AppColors.darkPrimary,
//       foregroundColor: AppColors.textPrimary,
//       elevation: 6,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.all(Radius.circular(16)),
//       ),
//     ),
    
//     // Divider Theme
//     dividerTheme: const DividerThemeData(
//       color: AppColors.darkDivider,
//       thickness: 1,
//       space: 1,
//     ),
    
//     // Bottom Navigation Bar Theme
//     bottomNavigationBarTheme: const BottomNavigationBarThemeData(
//       backgroundColor: AppColors.darkSurface,
//       selectedItemColor: AppColors.darkPrimary,
//       unselectedItemColor: AppColors.darkTextSecondary,
//       selectedLabelStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 12,
//         fontWeight: FontWeight.w600,
//       ),
//       unselectedLabelStyle: TextStyle(
//         fontFamily: 'Vazirmatn',
//         fontSize: 12,
//         fontWeight: FontWeight.normal,
//       ),
//       type: BottomNavigationBarType.fixed,
//       elevation: 8,
//     ),
    
//     // Snackbar Theme
//     snackBarTheme: SnackBarThemeData(
//       backgroundColor: AppColors.darkSurfaceElevated,
//       contentTextStyle: const TextStyle(
//         color: AppColors.darkTextPrimary,
//         fontFamily: 'Vazirmatn',
//         fontSize: 14,
//       ),
//       behavior: SnackBarBehavior.floating,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12),
//       ),
//     ),
//   );
// }
