// lib/app/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors for light theme
  static final Color _lightPrimaryColor = Color(0xFF1565C0);
  static final Color _lightPrimaryVariantColor = Color(0xFF0D47A1);
  static final Color _lightSecondaryColor = Color(0xFF26A69A);
  static final Color _lightOnPrimaryColor = Colors.white;
  static final Color _lightBackgroundColor = Colors.white;
  static final Color _lightErrorColor = Color(0xFFB71C1C);

  // Colors for dark theme
  static final Color _darkPrimaryColor = Color(0xFF42A5F5);
  static final Color _darkPrimaryVariantColor = Color(0xFF2196F3);
  static final Color _darkSecondaryColor = Color(0xFF4DB6AC);
  static final Color _darkOnPrimaryColor = Colors.black;
  static final Color _darkBackgroundColor = Color(0xFF121212);
  static final Color _darkErrorColor = Color(0xFFCF6679);

  // Custom colors
  static final Color accentBlue = Color(0xFF448AFF);
  static final Color successGreen = Color(0xFF4CAF50);
  static final Color warningYellow = Color(0xFFFFC107);
  static final Color infoOrange = Color(0xFFFF9800);
  static final Color darkGrey = Color(0xFF263238);
  static final Color mediumGrey = Color(0xFF607D8B);
  static final Color lightGrey = Color(0xFFECEFF1);

  static final _light = ThemeData.light().copyWith(
    primaryColor: _lightPrimaryColor,
    primaryColorDark: _lightPrimaryVariantColor,
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      primaryContainer: _lightPrimaryVariantColor,
      secondary: _lightSecondaryColor,
      onPrimary: _lightOnPrimaryColor,
      error: _lightErrorColor,
      background: _lightBackgroundColor,
    ),
    scaffoldBackgroundColor: _lightBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: _lightPrimaryColor,
      titleTextStyle: GoogleFonts.cairo(
        color: _lightOnPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: _lightOnPrimaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _lightPrimaryColor,
        side: BorderSide(color: _lightPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _lightErrorColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: darkGrey,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: darkGrey,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: darkGrey,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: darkGrey,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: darkGrey,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: darkGrey,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: darkGrey,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: mediumGrey,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: darkGrey,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        color: darkGrey,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        color: mediumGrey,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _lightPrimaryColor,
      foregroundColor: _lightOnPrimaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _lightPrimaryColor.withOpacity(0.3),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: _lightPrimaryColor,
      unselectedItemColor: Colors.grey.shade600,
      selectedLabelStyle: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _lightPrimaryColor,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontSize: 14,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade200,
      thickness: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
  );

  static final _dark = ThemeData.dark().copyWith(
    primaryColor: _darkPrimaryColor,
    primaryColorDark: _darkPrimaryVariantColor,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      primaryContainer: _darkPrimaryVariantColor,
      secondary: _darkSecondaryColor,
      onPrimary: _darkOnPrimaryColor,
      error: _darkErrorColor,
      background: _darkBackgroundColor,
    ),
    scaffoldBackgroundColor: _darkBackgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF1D1D1D),
      titleTextStyle: GoogleFonts.cairo(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Color(0xFF2C2C2C),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: _darkPrimaryColor,
        side: BorderSide(color: _darkPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.cairo(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2C2C2C),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkPrimaryColor),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: _darkErrorColor),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: GoogleFonts.cairo(color: Colors.grey.shade500),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.cairo(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displayMedium: GoogleFonts.cairo(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      displaySmall: GoogleFonts.cairo(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineMedium: GoogleFonts.cairo(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headlineSmall: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      titleLarge: GoogleFonts.cairo(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleMedium: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      titleSmall: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: Colors.grey.shade300,
      ),
      bodyLarge: GoogleFonts.cairo(
        fontSize: 16,
        color: Colors.white,
      ),
      bodyMedium: GoogleFonts.cairo(
        fontSize: 14,
        color: Colors.white,
      ),
      bodySmall: GoogleFonts.cairo(
        fontSize: 12,
        color: Colors.grey.shade300,
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _darkPrimaryColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _darkPrimaryColor.withOpacity(0.3),
      labelTextStyle: MaterialStateProperty.all(
        GoogleFonts.cairo(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1D1D1D),
      selectedItemColor: _darkPrimaryColor,
      unselectedItemColor: Colors.grey.shade500,
      selectedLabelStyle: GoogleFonts.cairo(
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontSize: 12,
      ),
      type: BottomNavigationBarType.fixed,
    ),
    tabBarTheme: TabBarThemeData(
      labelColor: _darkPrimaryColor,
      unselectedLabelColor: Colors.grey.shade500,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: GoogleFonts.cairo(
        fontSize: 14,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelStyle: GoogleFonts.cairo(
        fontSize: 14,
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
    ),
    dividerTheme: DividerThemeData(
      color: Colors.grey.shade800,
      thickness: 1,
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );

  // Theme getters
  static ThemeData get light => _light;
  static ThemeData get dark => _dark;

  // Theme helper
  static ThemeMode getThemeMode(String mode) {
    switch (mode) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
