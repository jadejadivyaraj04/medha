// lib/ui/reminder_alert/view/reminder_alert_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/medicine_text_helper.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/reminder_alert_controller.dart';

class ReminderAlertPage extends GetView<ReminderAlertController> {
  const ReminderAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final dose = controller.dose.value;
        if (dose == null) {
          return Center(
            child: SmartText(
              controller.errorMessage.value.isNotEmpty
                  ? controller.errorMessage.value
                  : 'reminders.error_dose_not_found'.tr,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }

        return SmartColumn(
          isSafeArea: true,
          mainAxisAlignment: MainAxisAlignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          spacing: 20.h,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_active_rounded,
                size: 44.r,
                color: AppColors.accent,
              ),
            ),
            SmartText(
              'reminders.alert.title'.tr,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              dose.medicineName,
              style: AppTextStyles.displayLarge.copyWith(fontSize: 28.sp),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              dose.dosageMg != null
                  ? 'medicines.dose_mg'.trParams({'dose': '${dose.dosageMg}'})
                  : 'medicines.dose_unknown'.tr,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              MedicineTextHelper.foodLabel(dose.withFood),
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SambhdoButton(onTap: controller.speakReminder),
            SizedBox(height: 12.h),
            SmartButton(
              title: 'reminders.taken'.tr,
              isLoading: controller.isLoading.value,
              onTap: () => controller.markTaken(),
              isEnabled: !controller.isLoading.value,
              activeBackgroundColor: AppColors.success,
              height: 56.h,
            ),
            SmartButton(
              title: 'reminders.snooze'.tr,
              onTap: () => controller.snooze(),
              isEnabled: !controller.isLoading.value,
              activeBackgroundColor: AppColors.accentLight,
              titleStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
              height: 56.h,
            ),
            SmartButton(
              title: 'reminders.skip'.tr,
              onTap: () => controller.skip(),
              isEnabled: !controller.isLoading.value,
              activeBackgroundColor: AppColors.surface,
              titleStyle: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
              height: 56.h,
            ),
            SizedBox(height: bottomInset),
          ],
        );
      }),
    );
  }
}
