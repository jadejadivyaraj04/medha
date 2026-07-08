// lib/ui/reminders/widgets/today_progress_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/reminders_controller.dart';

class TodayProgressCard extends GetView<RemindersController> {
  const TodayProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final total = controller.totalCount;
      final taken = controller.takenCount;
      final progress = total == 0 ? 0.0 : taken / total;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: AppColors.surfaceElevated,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 16.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: SmartRow(
          spacing: 16.w,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 6,
                      color: AppColors.accent,
                      backgroundColor: AppColors.border,
                    ),
                  ),
                  SmartText(
                    '$taken/$total',
                    style: AppTextStyles.heading3.copyWith(color: AppColors.accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Expanded(
              child: SmartColumn(
                spacing: 4.h,
                children: [
                  SmartText(
                    'reminders.progress_title'.tr,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    'reminders.progress_body'.trParams({
                      'taken': '$taken',
                      'total': '$total',
                    }),
                    style: AppTextStyles.body2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
