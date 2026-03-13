import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color cardBackground = Color(0xFF1E1E1E);

  // Action colors
  static const Color delete = Color(0xFFE53935);
  static const Color keep = Color(0xFF43A047);
  static const Color favorite = Color(0xFFFFB300);

  // Action overlays (semi-transparent)
  static const Color deleteOverlay = Color(0xCCE53935);
  static const Color keepOverlay = Color(0xCC43A047);
  static const Color favoriteOverlay = Color(0xCCFFB300);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF616161);

  // Accent
  static const Color accent = Color(0xFFFFB300);
  static const Color accentMuted = Color(0xFF332800);

  // Streak / gamification
  static const Color streakFlame = Color(0xFFFF6D00);

  // Border / divider
  static const Color border = Color(0xFF2C2C2C);
  static const Color divider = Color(0xFF1F1F1F);

  // Gradient for login hero
  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF0F0F0F), Color(0xFF0F0F0F), Color(0xFF141414)],
    stops: [0.0, 0.6, 1.0],
  );

  // Button colors
  static const Color googleButton = Color(0xFFFFFFFF);
  static const Color appleButton = Color(0xFFFFFFFF);
  static const Color primaryButton = Color(0xFFFFFFFF);
}
