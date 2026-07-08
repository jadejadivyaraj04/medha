// lib/ui/home/widgets/home_pucho_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';

class HomePuchoCard extends StatelessWidget {
  const HomePuchoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return SmartRow(
      onTap: () => Get.toNamed(Routes.DOUBT_QUERY),
      isInkwell: true,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: AppGradients.accentBrand,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.28),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      spacing: 14.w,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 52.w,
          height: 52.w,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.mic_rounded,
            size: 28.r,
            color: Colors.white,
            semanticLabel: 'doubt.pucho'.tr,
          ),
        ),
        Expanded(
          child: SmartColumn(
            spacing: 4.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmartText(
                'doubt.pucho'.tr,
                style: AppTextStyles.heading3.copyWith(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                'doubt.pucho_subtitle'.tr,
                style: AppTextStyles.body2.copyWith(
                  color: Colors.white.withValues(alpha: 0.92),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 16.r,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ],
    );
  }
}
