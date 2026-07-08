// lib/core/widgets/ai_disclaimer_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AiDisclaimerBanner extends StatelessWidget {
  const AiDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: SmartRow(
        spacing: 8.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18.r, color: AppColors.warning),
          Expanded(
            child: SmartText(
              'scan.disclaimer'.tr,
              style: AppTextStyles.caption.copyWith(color: AppColors.warning),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
