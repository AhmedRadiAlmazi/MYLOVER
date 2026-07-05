import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getTheme({required Color seedColor, required bool isDark}) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: isDark ? Brightness.dark : Brightness.light,
      surface: isDark ? AppColors.surface : Colors.white,
    );

    final backgroundColor = isDark ? AppColors.background : const Color(0xFFF5F5F7);
    final cardColor = isDark ? AppColors.card : Colors.white;
    final textPrimary = isDark ? AppColors.textPrimary : const Color(0xFF1A1A2E);
    final textSecondary = isDark ? AppColors.textSecondary : const Color(0xFF6B6B80);
    final textHint = isDark ? AppColors.textHint : const Color(0xFFA0A0B0);
    final dividerColor = isDark ? AppColors.divider : const Color(0xFFE5E5EA);

    return ThemeData(
      useMaterial3: true,
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: colorScheme,
      textTheme: _buildTextTheme(textPrimary, textSecondary, textHint),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: textHint,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: isDark ? 0 : 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.card : const Color(0xFFF5F5F7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        hintStyle: GoogleFonts.tajawal(
          color: textHint,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.tajawal(
          color: textSecondary,
          fontSize: 14,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          elevation: isDark ? 0 : 2,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.primary,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: colorScheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: GoogleFonts.tajawal(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          textStyle: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.card : const Color(0xFFF5F5F7),
        selectedColor: colorScheme.primary.withOpacity(0.3),
        labelStyle: GoogleFonts.tajawal(
          color: textPrimary,
          fontSize: 13,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: dividerColor),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary.withOpacity(0.4);
          }
          return dividerColor;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return colorScheme.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: BorderSide(color: dividerColor, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? AppColors.card : const Color(0xFF1A1A2E), // Always dark for snackbar
        contentTextStyle: GoogleFonts.tajawal(
          color: Colors.white,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogTheme(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: isDark ? AppColors.surface : Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
      ),
    );
  }

  static TextTheme _buildTextTheme(Color primary, Color secondary, Color hint) {
    return TextTheme(
      displayLarge: GoogleFonts.tajawal(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.tajawal(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.tajawal(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.tajawal(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: primary,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.tajawal(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.tajawal(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.tajawal(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.5,
        letterSpacing: 0.15,
      ),
      titleSmall: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      bodyLarge: GoogleFonts.tajawal(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.5,
        letterSpacing: 0.5,
      ),
      bodyMedium: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: primary,
        height: 1.43,
        letterSpacing: 0.25,
      ),
      bodySmall: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
        height: 1.33,
        letterSpacing: 0.4,
      ),
      labelLarge: GoogleFonts.tajawal(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
        height: 1.43,
        letterSpacing: 0.1,
      ),
      labelMedium: GoogleFonts.tajawal(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.33,
        letterSpacing: 0.5,
      ),
      labelSmall: GoogleFonts.tajawal(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: hint,
        height: 1.45,
        letterSpacing: 0.5,
      ),
    );
  }
}
