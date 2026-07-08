// lib/ui/adherence_history/widgets/adherence_day_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/dose_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/adherence_history_controller.dart';

class AdherenceDayTile extends GetView<AdherenceHistoryController> {
  const AdherenceDayTile({
    required this.summary,
    super.key,
  });

  final AdherenceDaySummary summary;

  Color get _ratioColor {
    final ratio = summary.ratio;
    if (ratio >= 1) {
      return AppColors.success;
    }
    if (ratio >= 0.5) {
      return AppColors.warning;
    }
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isExpanded = controller.expandedDayDoses.containsKey(summary.dateKey);
      final isLoading = controller.loadingDayKeys.contains(summary.dateKey);
      final doses = controller.expandedDayDoses[summary.dateKey] ?? [];

      return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: SmartColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          SmartRow(
            onTap: () => controller.toggleDayExpansion(summary.dateKey),
            isInkwell: true,
            padding: EdgeInsets.all(16.w),
            spacing: 12.w,
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _ratioColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SmartText(
                  summary.dateKey.split('-').last,
                  style: AppTextStyles.heading3.copyWith(color: _ratioColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Expanded(
                child: SmartColumn(
                  spacing: 4.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmartText(
                      controller.dayLabel(summary.dateKey),
                      style: AppTextStyles.body1,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'adherence.day_progress'.trParams({
                        'taken': '${summary.takenCount}',
                        'total': '${summary.totalCount}',
                      }),
                      style: AppTextStyles.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                isExpanded
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                size: 22.r,
                color: AppColors.textHint,
              ),
            ],
          ),
          if (isExpanded) ...[
            Divider(height: 1, color: AppColors.border),
            if (isLoading)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: const Center(child: SmartCircularProgressIndicator()),
              )
            else if (doses.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.w),
                child: SmartText(
                  'adherence.day_empty'.tr,
                  style: AppTextStyles.body2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            else
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
                child: SmartColumn(
                  spacing: 8.h,
                  children: [
                    for (final dose in doses) _DoseRow(dose: dose),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
    });
  }
}

class _DoseRow extends GetView<AdherenceHistoryController> {
  const _DoseRow({required this.dose});

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
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SmartRow(
        spacing: 10.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.medication_rounded,
              size: 16.r,
              color: AppColors.accent,
            ),
          ),
          Expanded(
            child: SmartColumn(
              spacing: 2.h,
              children: [
                SmartText(
                  dose.medicineName,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  '${controller.slotLabel(dose.slot)} · ${controller.timeLabel(dose)}',
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: _statusBg,
              borderRadius: BorderRadius.circular(100.r),
            ),
            child: SmartText(
              controller.statusLabel(dose.status),
              style: AppTextStyles.caption.copyWith(color: _statusColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
