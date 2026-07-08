// lib/core/widgets/app_error_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      spacing: 16.h,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 56.r,
          color: AppColors.textHint,
        ),
        SmartText(
          'common.error_generic'.tr,
          style: AppTextStyles.heading3,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        SmartText(
          message,
          style: AppTextStyles.body2,
          textAlign: TextAlign.center,
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
        SmartButton(
          title: 'common.retry'.tr,
          onTap: onRetry,
          width: 160.w,
        ),
      ],
    );
  }
}
