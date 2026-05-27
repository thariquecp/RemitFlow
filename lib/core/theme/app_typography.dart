import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  static TextTheme textTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      // Display — large hero numbers (exchange rate, amounts)
      displayLarge: GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.5,
        color: primaryColor,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        letterSpacing: -1.0,
        color: primaryColor,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: primaryColor,
      ),

      // Headlines — section titles
      headlineLarge: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: primaryColor,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),

      // Titles — card titles, list item titles
      titleLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primaryColor,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: primaryColor,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.1,
        color: secondaryColor,
      ),

      // Body — regular content
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primaryColor,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondaryColor,
      ),

      // Labels — buttons, chips, badges
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: primaryColor,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
        color: secondaryColor,
      ),
    );
  }
}
