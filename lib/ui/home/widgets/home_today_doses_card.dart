// lib/ui/home/widgets/home_today_doses_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/dose_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/home_controller.dart';

class HomeTodayDosesCard extends GetView<HomeController> {
  const HomeTodayDosesCard({super.key});

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
        child: SmartColumn(
          spacing: 16.h,
          children: [
            SmartRow(
              spacing: 16.w,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 72.w,
                  height: 72.w,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Smart widget fallback: determinate ring progress not in SmartCircularProgressIndicator.
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
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.accent,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SmartColumn(
                    spacing: 4.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmartText(
                        'home.today_doses_title'.tr,
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
                      if (controller.streakDays.value > 0)
                        SmartText(
                          'adherence.streak'.trParams({
                            'days': '${controller.streakDays.value}',
                          }),
                          style: AppTextStyles.label.copyWith(
                            color: AppColors.accent,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (controller.upcomingDoses.isNotEmpty)
              SmartColumn(
                spacing: 8.h,
                children: [
                  for (final dose in controller.upcomingDoses)
                    _UpcomingDoseRow(dose: dose),
                ],
              ),
            SmartButton(
              title: 'home.view_schedule'.tr,
              onTap: controller.openRemindersTab,
              height: 48.h,
              activeBackgroundColor: AppColors.accent,
            ),
          ],
        ),
      );
    });
  }
}

class _UpcomingDoseRow extends GetView<HomeController> {
  const _UpcomingDoseRow({required this.dose});

  final DoseModel dose;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SmartRow(
        spacing: 10.w,
        children: [
          Icon(Icons.medication_rounded, size: 18.r, color: AppColors.accent),
          Expanded(
            child: SmartText(
              dose.medicineName,
              style: AppTextStyles.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SmartText(
            controller.timeLabel(dose),
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
