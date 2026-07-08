// lib/core/theme/app_gradients.dart

import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppGradients {
  AppGradients._();

  static const LinearGradient accentBrand = LinearGradient(
    colors: [Color(0xFF1A8C6E), Color(0xFF2FA98B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient imageOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xB8000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.4, 1.0],
  );

  static const LinearGradient heroOverlay = LinearGradient(
    colors: [Color(0x00000000), Color(0x99000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static LinearGradient pageTopFade = LinearGradient(
    colors: [AppColors.background, AppColors.background.withOpacity(0.0)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
