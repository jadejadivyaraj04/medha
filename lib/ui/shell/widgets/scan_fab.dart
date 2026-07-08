// lib/ui/shell/widgets/scan_fab.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';

class ScanFab extends StatelessWidget {
  const ScanFab({
    required this.onTap,
    super.key,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      onTap: onTap,
      isInkwell: true,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      spacing: 4.h,
      children: [
        Container(
          width: 56.w,
          height: 56.w,
          decoration: BoxDecoration(
            gradient: AppGradients.accentBrand,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.32),
                blurRadius: 16.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.document_scanner_rounded,
            size: 26.r,
            color: Colors.white,
            semanticLabel: 'scan.fab'.tr,
          ),
        ),
        SmartText(
          'scan.fab'.tr,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.accent,
            fontSize: 10.sp,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
