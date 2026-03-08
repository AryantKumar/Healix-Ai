import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary palette
  static const Color primary = Color(0xFF0D9488);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF0F766E);
  static const Color primarySurface = Color(0xFF042F2E);

  // Accent
  static const Color accent = Color(0xFF6366F1);
  static const Color accentLight = Color(0xFF818CF8);

  // Background
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF111827);
  static const Color surfaceLight = Color(0xFF1F2937);
  static const Color surfaceCard = Color(0xFF1A2332);

  // Glass
  static const Color glassBg = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassHighlight = Color(0x0DFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFFF9FAFB);
  static const Color textSecondary = Color(0xFF9CA3AF);
  static const Color textTertiary = Color(0xFF6B7280);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Emergency
  static const Color emergency = Color(0xFFDC2626);
  static const Color emergencyDark = Color(0xFF991B1B);

  // Feature card gradients
  static const List<Color> chatGradient = [Color(0xFF6366F1), Color(0xFF8B5CF6)];
  static const List<Color> hospitalGradient = [Color(0xFF0EA5E9), Color(0xFF06B6D4)];
  static const List<Color> recordsGradient = [Color(0xFF10B981), Color(0xFF059669)];
  static const List<Color> emergencyGradient = [Color(0xFFEF4444), Color(0xFFDC2626)];
  static const List<Color> medicineGradient = [Color(0xFFF59E0B), Color(0xFFD97706)];
  static const List<Color> historyGradient = [Color(0xFF8B5CF6), Color(0xFF7C3AED)];
  static const List<Color> primaryGradient = [Color(0xFF0D9488), Color(0xFF14B8A6)];
}
