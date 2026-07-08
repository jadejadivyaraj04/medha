// lib/core/theme/app_text_styles.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
// ignore: unused_import — kept for locale-aware expansion per @app_theme
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // Locale-aware helpers. Medha is English/Gujarati/Hindi (LTR) — Google Fonts
  // Lora & DM Sans both cover Devanagari + Latin well, so the same methods serve
  // all three locales. (Kept locale-aware for future expansion.)
  static TextStyle _heading({
    required double size,
    FontWeight weight = FontWeight.w600,
    Color? color,
    double height = 1.2,
    FontStyle? fontStyle,
    double? letterSpacing,
  }) {
    return GoogleFonts.lora(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? AppColors.textPrimary,
      fontStyle: fontStyle,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle _body({
    required double size,
    FontWeight weight = FontWeight.w400,
    Color? color,
    double height = 1.5,
    double? letterSpacing,
  }) {
    return GoogleFonts.dmSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color ?? AppColors.textPrimary,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle get displayLarge => _heading(
        size: 32.sp,
        weight: FontWeight.w600,
        height: 1.1,
        fontStyle: FontStyle.italic,
      );

  static TextStyle get heading1 => _heading(size: 24.sp, height: 1.2);

  static TextStyle get heading2 => _heading(size: 20.sp, height: 1.25);

  static TextStyle get heading3 =>
      _body(size: 16.sp, weight: FontWeight.w600, height: 1.3);

  static TextStyle get body1 => _body(size: 15.sp);

  static TextStyle get body2 =>
      _body(size: 13.sp, color: AppColors.textSecondary);

  static TextStyle get label =>
      _body(size: 12.sp, weight: FontWeight.w500, height: 1.4);

  static TextStyle get caption =>
      _body(size: 11.sp, color: AppColors.textSecondary, height: 1.4);

  static TextStyle get button => _body(
        size: 14.sp,
        weight: FontWeight.w600,
        color: Colors.white,
        letterSpacing: 0.2,
      );

  static TextStyle get overline => _body(
        size: 10.sp,
        weight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 1.4,
        height: 1.4,
      );
}
