// lib/ui/reminders/widgets/dose_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/dose_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/reminders_controller.dart';

class DoseRow extends GetView<RemindersController> {
  const DoseRow({
    required this.dose,
    super.key,
  });

  final DoseModel dose;

  Color get _statusBg {
    return switch (dose.status) {
      'taken' => AppColors.successLight,
      'missed' => AppColors.errorLight,
      'skipped' => AppColors.surface,
      'due_soon' => AppColors.warningLight,
      _ => AppColors.accentLight,
    };
  }

  Color get _statusColor {
    return switch (dose.status) {
      'taken' => AppColors.success,
      'missed' => AppColors.error,
      'skipped' => AppColors.textHint,
      'due_soon' => AppColors.warning,
      _ => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final canAct = !dose.isTaken && !dose.isSkipped;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: dose.status == 'due_soon' ? AppColors.warning : AppColors.border,
          width: dose.status == 'due_soon' ? 1.5 : 1,
        ),
      ),
      child: SmartColumn(
        spacing: 12.h,
        children: [
          SmartRow(
            spacing: 12.w,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.medication_rounded,
                  size: 18.r,
                  color: AppColors.accent,
                ),
              ),
              Expanded(
                child: SmartColumn(
                  spacing: 4.h,
                  children: [
                    SmartText(
                      dose.medicineName,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      controller.timeLabel(dose),
                      style: AppTextStyles.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _statusBg,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: SmartText(
                  controller.statusLabel(dose.status),
                  style: AppTextStyles.label.copyWith(color: _statusColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SmartColumn(
            spacing: 8.h,
            children: [
              SambhdoButton(
                onTap: () => controller.speakDose(dose),
                fullWidth: true,
              ),
              if (canAct)
                SmartColumn(
                  spacing: 8.h,
                  children: [
                    SmartButton(
                      title: 'reminders.snooze'.tr,
                      onTap: () => controller.snoozeDose(dose),
                      height: 48.h,
                      activeBackgroundColor: AppColors.warningLight,
                      titleStyle: AppTextStyles.label.copyWith(
                        color: AppColors.warning,
                      ),
                    ),
                    SmartRow(
                      spacing: 8.w,
                      children: [
                    // Smart widget fallback: SmartButton has no expanded prop.
                    Expanded(
                      child: SmartButton(
                        title: 'reminders.skip'.tr,
                        onTap: () => controller.markSkipped(dose),
                        height: 48.h,
                        width: double.infinity,
                        activeBackgroundColor: AppColors.surface,
                        titleStyle: AppTextStyles.label.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: SmartButton(
                        title: 'reminders.taken'.tr,
                        onTap: () => controller.markTaken(dose),
                        height: 48.h,
                        width: double.infinity,
                        activeBackgroundColor: AppColors.success,
                      ),
                    ),
                  ],
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
