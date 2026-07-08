// lib/ui/home/widgets/home_refill_nudge_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../app/routes.dart';
import '../../../core/models/refill_info_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/home_controller.dart';

class HomeRefillNudgeCard extends GetView<HomeController> {
  const HomeRefillNudgeCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final refills = controller.refillDueMedicines;
      if (refills.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.warningLight,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.warning, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.warning.withValues(alpha: 0.15),
              blurRadius: 12.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: SmartColumn(
          spacing: 12.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmartRow(
              spacing: 10.w,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.notifications_active_rounded,
                  size: 22.r,
                  color: AppColors.warning,
                ),
                Expanded(
                  child: SmartColumn(
                    spacing: 4.h,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SmartText(
                        'refill.nudge_title'.tr,
                        style: AppTextStyles.heading3.copyWith(
                          color: AppColors.warning,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SmartText(
                        'refill.nudge_body'.trParams({
                          'count': '${refills.length}',
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
            for (final info in refills) _RefillRow(info: info),
            SmartButton(
              title: 'refill.view_medicines'.tr,
              onTap: controller.openMedicinesTab,
              height: 48.h,
              activeBackgroundColor: AppColors.warning,
            ),
          ],
        ),
      );
    });
  }
}

class _RefillRow extends StatelessWidget {
  const _RefillRow({required this.info});

  final RefillInfo info;

  @override
  Widget build(BuildContext context) {
    return SmartRow(
      onTap: () => Get.toNamed(
        Routes.MEDICINE_DETAILS,
        arguments: {'id': info.medicine.id},
      ),
      isInkwell: true,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12.r),
      ),
      spacing: 10.w,
      children: [
        Icon(Icons.medication_rounded, size: 18.r, color: AppColors.warning),
        Expanded(
          child: SmartText(
            info.medicine.name,
            style: AppTextStyles.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.warning,
            borderRadius: BorderRadius.circular(100.r),
          ),
          child: SmartText(
            'medicines.status.refill_due'.tr,
            style: AppTextStyles.caption.copyWith(color: Colors.white),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SmartText(
          'refill.days_left'.trParams({'days': '${info.remainingDays}'}),
          style: AppTextStyles.caption.copyWith(color: AppColors.warning),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
