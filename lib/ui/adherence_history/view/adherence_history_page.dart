// lib/ui/adherence_history/view/adherence_history_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/adherence_history_controller.dart';
import '../widgets/adherence_calendar_grid.dart';
import '../widgets/adherence_day_tile.dart';
import '../widgets/adherence_shimmer.dart';
import '../widgets/adherence_stats_card.dart';

class AdherenceHistoryPage extends GetView<AdherenceHistoryController> {
  const AdherenceHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'adherence.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
        actions: [
          SambhdoButton(
            onTap: controller.speakMonthSummary,
            fullWidth: false,
          ),
        ],
      ),
      body: Obx(() {
        final showInitialLoad =
            controller.isLoading.value && controller.monthSummaries.isEmpty;
        final showError = controller.errorMessage.value.isNotEmpty &&
            controller.monthSummaries.isEmpty;

        if (showError) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return Stack(
          children: [
            SmartSingleChildScrollView(
              onRefresh: controller.refresh,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: SmartColumn(
                spacing: 16.h,
                children: [
                  const _MonthSwitcher(),
                  _StatsSection(),
                  Obx(
                    () => AdherenceCalendarGrid(
                      month: controller.selectedMonth.value,
                      summaries: controller.summaryByDate,
                    ),
                  ),
                  SmartText(
                    'adherence.daily_log_title'.tr,
                    style: AppTextStyles.overline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const _DailyLogSection(),
                ],
              ),
            ),
            if (showInitialLoad)
              ColoredBox(
                color: AppColors.background,
                child: SmartSingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                  child: const AdherenceShimmer(),
                ),
              ),
          ],
        );
      }),
    );
  }
}

class _StatsSection extends GetView<AdherenceHistoryController> {
  const _StatsSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final stats = controller.monthStats.value;
      if (stats == null || stats.totalDoses == 0) {
        return const SizedBox.shrink();
      }

      return SmartColumn(
        spacing: 12.h,
        children: [
          AdherenceStatsCard(stats: stats),
          SmartButton(
            title: 'doctor_export.history_cta'.tr,
            onTap: controller.openDoctorExport,
            height: 48.h,
            activeBackgroundColor: AppColors.accentLight,
            titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
          ),
        ],
      );
    });
  }
}

class _DailyLogSection extends GetView<AdherenceHistoryController> {
  const _DailyLogSection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.monthSummaries.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 32.h),
          child: SmartNoDataFound(
            text: 'adherence.empty_title'.tr,
            subText: 'adherence.empty_subtitle'.tr,
          ),
        );
      }

      final items = controller.monthSummaries.toList()
        ..sort((a, b) => b.dateKey.compareTo(a.dateKey));

      return SmartColumn(
        spacing: 12.h,
        children: [
          for (final summary in items) AdherenceDayTile(summary: summary),
        ],
      );
    });
  }
}

class _MonthSwitcher extends GetView<AdherenceHistoryController> {
  const _MonthSwitcher();

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SmartRow(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SmartButton(
            title: 'adherence.prev_month'.tr,
            onTap: controller.previousMonth,
            height: 44.h,
            width: 44.w,
            activeBackgroundColor: AppColors.surface,
            titleStyle: AppTextStyles.heading3,
          ),
          // Smart widget fallback: SmartText has no expanded prop in this row.
          Expanded(
            child: SmartText(
              controller.monthLabel,
              style: AppTextStyles.heading3,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SmartButton(
            title: 'adherence.next_month'.tr,
            onTap: controller.nextMonth,
            isEnabled: !controller.isCurrentMonth,
            height: 44.h,
            width: 44.w,
            activeBackgroundColor: AppColors.surface,
            titleStyle: AppTextStyles.heading3.copyWith(
              color: controller.isCurrentMonth
                  ? AppColors.textHint
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
