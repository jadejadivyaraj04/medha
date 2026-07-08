// lib/ui/reminders/view/reminders_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../controller/reminders_controller.dart';
import '../widgets/dose_row.dart';
import '../widgets/reminders_shimmer.dart';
import '../widgets/reminders_streak_chip.dart';
import '../widgets/today_progress_card.dart';

class RemindersPage extends GetView<RemindersController> {
  const RemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.doses.isEmpty) {
        return SmartColumn(
          isSafeArea: true,
          crossAxisAlignment: CrossAxisAlignment.start,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          spacing: 16.h,
          children: [
            SizedBox(height: 16.h),
            _Header(),
            const RemindersShimmer(),
          ],
        );
      }

      if (controller.errorMessage.value.isNotEmpty && controller.doses.isEmpty) {
        return SmartColumn(
          isSafeArea: true,
          children: [
            Expanded(
              child: AppErrorWidget(
                message: controller.errorMessage.value,
                onRetry: controller.load,
              ),
            ),
          ],
        );
      }

      if (controller.doses.isEmpty) {
        return SmartColumn(
          isSafeArea: true,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: _Header(),
            ),
            Expanded(
              child: Center(
                child: SmartNoDataFound(
                  text: 'reminders.empty_title'.tr,
                  subText: 'reminders.empty_subtitle'.tr,
                  retryText: 'reminders.empty_cta'.tr,
                  onRetry: () => Get.toNamed(Routes.SCAN),
                ),
              ),
            ),
          ],
        );
      }

      final grouped = controller.groupedDoses;

      return SmartColumn(
        isSafeArea: true,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.accent,
              // Smart widget fallback: nested timeline list needs RefreshIndicator wrapper.
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                children: [
                  _Header(),
                  SizedBox(height: 16.h),
                  const TodayProgressCard(),
                  SizedBox(height: 12.h),
                  const RemindersStreakChip(),
                  SizedBox(height: 12.h),
                  SmartButton(
                    title: 'reminders.history_cta'.tr,
                    onTap: controller.openHistory,
                    height: 44.h,
                    activeBackgroundColor: AppColors.accentLight,
                    titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
                  ),
                  SizedBox(height: 20.h),
                  for (final slot in const ['morning', 'afternoon', 'night']) ...[
                    if ((grouped[slot] ?? []).isNotEmpty) ...[
                      SmartText(
                        controller.slotTitle(slot),
                        style: AppTextStyles.overline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 8.h),
                      for (final dose in grouped[slot]!) ...[
                        DoseRow(dose: dose),
                        SizedBox(height: 12.h),
                      ],
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _Header extends GetView<RemindersController> {
  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 4.h,
      children: [
        SmartText(
          'reminders.greeting'.trParams({'name': controller.greetingName}),
          style: AppTextStyles.heading1,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SmartText(
          controller.todayLabel,
          style: AppTextStyles.body2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
