import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00B894);
  static const Color primaryLight = Color(0xFF55EFC4);
  static const Color accentStart = Color(0xFF00D4AA);
  static const Color accentEnd = Color(0xFF00B4D8);

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentStart, accentEnd],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A1F3A), Color(0xFF0F1328)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dark
  static const Color darkBg = Color(0xFF0A0E21);
  static const Color darkSurface = Color(0xFF111633);
  static const Color darkCard = Color(0xFF161B3A);
  static const Color darkElevated = Color(0xFF1C2147);
  static const Color darkBorder = Color(0xFF2A2F52);

  // Light
  static const Color lightBg = Color(0xFFF5F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE8ECF2);

  //  Text
  static const Color textPrimaryDark = Color(0xFFF1F3F5);
  static const Color textSecondaryDark = Color(0xFF8B92B3);
  static const Color textTertiaryDark = Color(0xFF5A6087);

  static const Color textPrimaryLight = Color(0xFF1A1D2E);
  static const Color textSecondaryLight = Color(0xFF6B7280);
  static const Color textTertiaryLight = Color(0xFF9CA3AF);

  //  Status
  static const Color success = Color(0xFF00C48C);
  static const Color warning = Color(0xFFFFB020);
  static const Color error = Color(0xFFFF4757);
  static const Color info = Color(0xFF3B82F6);

  //  Transaction Status =
  static const Color statusPending = Color(0xFFFFB020);
  static const Color statusProcessing = Color(0xFF3B82F6);
  static const Color statusCompleted = Color(0xFF00C48C);
  static const Color statusFailed = Color(0xFFFF4757);
  static const Color statusRefunded = Color(0xFF8B5CF6);

  //  Glass
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassBorderLight = Color(0x1A000000);
}
