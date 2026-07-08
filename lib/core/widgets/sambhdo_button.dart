// lib/core/widgets/sambhdo_button.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class SambhdoButton extends StatelessWidget {
  const SambhdoButton({
    required this.onTap,
    this.fullWidth = false,
    super.key,
  });

  final VoidCallback onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    return SmartButton(
      title: 'scan.sambhdo'.tr,
      onTap: onTap,
      height: 48.h,
      width: fullWidth ? double.infinity : 140.w,
      activeBackgroundColor: AppColors.accentLight,
      borderRadius: BorderRadius.circular(100.r),
      titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
    );
  }
}
