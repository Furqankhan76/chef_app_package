import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Import Google Fonts

class AppTheme {
  // Define custom colors based on requirements
  static const Color softFieryRed = Color(0xFFE57373); // Example hex, adjust as needed
  static const Color appleGreen = Color(0xFF81C784); // Example hex, adjust as needed
  static const Color lightGray = Color(0xFFEEEEEE);
  static const Color white = Colors.white;
  static const Color black = Colors.black;

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: softFieryRed,
      hintColor: appleGreen, // Using accent color for hint/secondary elements
      scaffoldBackgroundColor: white,
      fontFamily: GoogleFonts.cairo().fontFamily, // Set default font to Cairo
      appBarTheme: AppBarTheme(
        backgroundColor: softFieryRed,
        foregroundColor: white,
        titleTextStyle: GoogleFonts.cairo(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: white,
        ),
        iconTheme: const IconThemeData(
          color: white,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.cairo(fontSize: 96, fontWeight: FontWeight.w300, letterSpacing: -1.5, color: black),
        displayMedium: GoogleFonts.cairo(fontSize: 60, fontWeight: FontWeight.w300, letterSpacing: -0.5, color: black),
        displaySmall: GoogleFonts.cairo(fontSize: 48, fontWeight: FontWeight.w400, color: black),
        headlineMedium: GoogleFonts.cairo(fontSize: 34, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: black),
        headlineSmall: GoogleFonts.cairo(fontSize: 24, fontWeight: FontWeight.w400, color: black),
        titleLarge: GoogleFonts.cairo(fontSize: 20, fontWeight: FontWeight.w500, letterSpacing: 0.15, color: black),
        titleMedium: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.15, color: black),
        titleSmall: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 0.1, color: black),
        bodyLarge: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.w400, letterSpacing: 0.5, color: black),
        bodyMedium: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.25, color: black),
        labelLarge: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25, color: black),
        bodySmall: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w400, letterSpacing: 0.4, color: black),
        labelSmall: GoogleFonts.cairo(fontSize: 10, fontWeight: FontWeight.w400, letterSpacing: 1.5, color: black),
      ),
      buttonTheme: ButtonThemeData(
        buttonColor: softFieryRed,
        textTheme: ButtonTextTheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: softFieryRed,
          foregroundColor: white,
          textStyle: GoogleFonts.cairo(fontSize: 14, fontWeight: FontWeight.w500),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: lightGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
          borderSide: const BorderSide(color: softFieryRed),
        ),
        labelStyle: GoogleFonts.cairo(color: black.withOpacity(0.6)),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      // Add other theme properties as needed
    );
  }

  // Add dark theme if needed, adapting colors and fonts
  // static ThemeData get darkTheme { ... }
}

