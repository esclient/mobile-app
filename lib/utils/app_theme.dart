import 'package:flutter/material.dart';
import 'constants.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.green,
      scaffoldBackgroundColor: const Color(AppColors.primaryBackground),
      
      // AppBar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(AppColors.primaryBackground),
        foregroundColor: Color(AppColors.textPrimary),
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: AppTextStyles.headingLarge,
          fontWeight: FontWeight.w700,
          fontFamily: AppTextStyles.primaryFont,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: const Color(AppColors.cardBackground),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          side: const BorderSide(color: Color(AppColors.border)),
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(AppColors.primaryBackground),
        selectedItemColor: Color(AppColors.accent),
        unselectedItemColor: Color(AppColors.textMuted),
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(AppColors.cardBackground),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: Color(AppColors.border)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: Color(AppColors.border)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
          borderSide: const BorderSide(color: Color(AppColors.accent)),
        ),
        hintStyle: const TextStyle(
          color: Color(AppColors.placeholder),
          fontSize: AppTextStyles.headingMedium,
        ),
      ),
      
      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.accent),
          foregroundColor: const Color(AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.tagBorderRadius),
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.paddingLarge,
            vertical: AppSizes.paddingMedium,
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(AppColors.accent),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.tagBorderRadius),
          ),
        ),
      ),
      
      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(AppColors.cardBackground),
        contentTextStyle: const TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: AppTextStyles.bodyMedium,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.tagBorderRadius),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(AppColors.cardBackground),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.borderRadius),
        ),
        titleTextStyle: const TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: AppTextStyles.headingMedium,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: const TextStyle(
          color: Color(AppColors.textSecondary),
          fontSize: AppTextStyles.bodyMedium,
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(AppColors.accent),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: AppTextStyles.headingLarge,
          fontWeight: FontWeight.w700,
          fontFamily: AppTextStyles.primaryFont,
        ),
        headlineMedium: TextStyle(
          color: Color(AppColors.textPrimary),
          fontSize: AppTextStyles.headingMedium,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.primaryFont,
        ),
        bodyLarge: TextStyle(
          color: Color(AppColors.textSecondary),
          fontSize: AppTextStyles.bodyMedium,
          fontFamily: AppTextStyles.primaryFont,
        ),
        bodyMedium: TextStyle(
          color: Color(AppColors.textSecondary),
          fontSize: AppTextStyles.bodySmall,
          fontFamily: AppTextStyles.primaryFont,
        ),
        bodySmall: TextStyle(
          color: Color(AppColors.textMuted),
          fontSize: AppTextStyles.caption,
          fontFamily: AppTextStyles.primaryFont,
        ),
        labelMedium: TextStyle(
          color: Color(AppColors.textMuted),
          fontSize: AppTextStyles.tiny,
          fontFamily: AppTextStyles.primaryFont,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: Color(AppColors.textMuted),
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: Color(AppColors.border),
        thickness: 1,
      ),
    );
  }
  
  // Дополнительные цвета для использования в приложении
  static const Color primaryBackground = Color(AppColors.primaryBackground);
  static const Color cardBackground = Color(AppColors.cardBackground);
  static const Color borderColor = Color(AppColors.border);
  static const Color accentColor = Color(AppColors.accent);
  static const Color warningColor = Color(AppColors.warning);
  static const Color textPrimary = Color(AppColors.textPrimary);
  static const Color textSecondary = Color(AppColors.textSecondary);
  static const Color textMuted = Color(AppColors.textMuted);
  static const Color placeholderColor = Color(AppColors.placeholder);
  
  // Удобный доступ к цветам через colors
  static const AppColorsAccess colors = AppColorsAccess();
}

// Класс для удобного доступа к цветам
class AppColorsAccess {
  const AppColorsAccess();
  
  Color get background => const Color(AppColors.primaryBackground);
  Color get surface => const Color(AppColors.cardBackground);
  Color get border => const Color(AppColors.border);
  Color get primary => const Color(AppColors.accent);
  Color get warning => const Color(AppColors.warning);
  Color get onSurface => const Color(AppColors.textPrimary);
  Color get onSurfaceSecondary => const Color(AppColors.textSecondary);
  Color get onSurfaceMuted => const Color(AppColors.textMuted);
  Color get placeholder => const Color(AppColors.placeholder);
}
