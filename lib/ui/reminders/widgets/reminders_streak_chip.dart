// lib/ui/reminders/widgets/reminders_streak_chip.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/reminders_controller.dart';

class RemindersStreakChip extends GetView<RemindersController> {
  const RemindersStreakChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.streakDays.value <= 0) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.accentLight,
          borderRadius: BorderRadius.circular(100.r),
          border: Border.all(color: AppColors.accent.withValues(alpha: 0.25)),
        ),
        child: SmartRow(
          spacing: 8.w,
          children: [
            Icon(Icons.local_fire_department_rounded,
                size: 18.r, color: AppColors.accent),
            Expanded(
              child: SmartText(
                'adherence.streak'.trParams({
                  'days': '${controller.streakDays.value}',
                }),
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    });
  }
}
