// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF1C2421);
  static const Color accent = Color(0xFF1A8C6E);
  static const Color accentWarm = Color(0xFF2FA98B);
  static const Color accentLight = Color(0xFFE8F4F0);

  static const Color background = Color(0xFFF5F9F7);
  static const Color surface = Color(0xFFEEF4F1);
  static const Color surfaceElevated = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF1C2421);
  static const Color textSecondary = Color(0xFF6B6B6B);
  static const Color textHint = Color(0xFFA8A8A8);

  static const Color border = Color(0xFFE2EAE6);
  static const Color success = Color(0xFF2D7A4F);
  static const Color successLight = Color(0xFFE8F5EE);
  static const Color error = Color(0xFFC0392B);
  static const Color errorLight = Color(0xFFFDECEA);
  static const Color warning = Color(0xFFE67E22);
  static const Color warningLight = Color(0xFFFEF3E2);
  static const Color rating = Color(0xFFF4A422);

  static Color get glassWhite => Colors.white.withOpacity(0.88);
  static Color get glassBorder => Colors.white.withOpacity(0.35);
}
