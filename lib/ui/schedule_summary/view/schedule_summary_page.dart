// lib/ui/schedule_summary/view/schedule_summary_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/schedule_summary_controller.dart';

class ScheduleSummaryPage extends GetView<ScheduleSummaryController> {
  const ScheduleSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'scan.summary.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
        actions: [
          SambhdoButton(onTap: controller.speakSummary),
        ],
      ),
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.setReminders,
          );
        }

        return SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 16.h,
                  children: [
                    const AiDisclaimerBanner(),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
                      ),
                      child: SmartColumn(
                        spacing: 8.h,
                        children: [
                          SmartText(
                            'scan.summary.hero_title'.tr,
                            style: AppTextStyles.heading2,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            'scan.summary.hero_body'.tr,
                            style: AppTextStyles.body2,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    ...controller.medicines.map(
                      (medicine) => Container(
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
                        child: SmartRow(
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
                                    controller.summaryFor(medicine),
                                    style: AppTextStyles.body2,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
              spacing: 12.h,
              children: [
                SambhdoButton(onTap: controller.speakSummary),
                SmartButton(
                  title: 'scan.summary.set_reminders'.tr,
                  isLoading: controller.isLoading.value ||
                      controller.isCheckingInteractions.value,
                  onTap: () => controller.setReminders(),
                  isEnabled: !controller.isLoading.value &&
                      !controller.isCheckingInteractions.value,
                  activeBackgroundColor: AppColors.accent,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
