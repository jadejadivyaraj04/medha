// lib/ui/medicines/widgets/medicine_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/medicine_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/medicine_text_helper.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/medicines_controller.dart';

class MedicineCard extends GetView<MedicinesController> {
  const MedicineCard({
    required this.medicine,
    super.key,
  });

  final MedicineModel medicine;

  Color get _statusBg {
    if (controller.hasDangerInteraction(medicine)) {
      return AppColors.errorLight;
    }
    return switch (controller.displayStatus(medicine)) {
      'completed' => AppColors.successLight,
      'refill_due' => AppColors.warningLight,
      _ => AppColors.accentLight,
    };
  }

  Color get _statusColor {
    if (controller.hasDangerInteraction(medicine)) {
      return AppColors.error;
    }
    return switch (controller.displayStatus(medicine)) {
      'completed' => AppColors.success,
      'refill_due' => AppColors.warning,
      _ => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
                      medicine.name,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      MedicineTextHelper.doseLabel(medicine),
                      style: AppTextStyles.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      MedicineTextHelper.timingLine(medicine),
                      style: AppTextStyles.caption,
                      maxLines: 2,
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
                  controller.hasDangerInteraction(medicine)
                      ? 'interactions.danger_badge'.tr
                      : MedicineTextHelper.statusLabel(
                          controller.displayStatus(medicine),
                        ),
                  style: AppTextStyles.label.copyWith(color: _statusColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SmartRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SambhdoButton(onTap: () => controller.speakMedicine(medicine)),
              SmartButton(
                title: 'medicines.view_details'.tr,
                onTap: () => controller.openDetail(medicine),
                height: 40.h,
                width: 120.w,
                activeBackgroundColor: AppColors.accentLight,
                titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
