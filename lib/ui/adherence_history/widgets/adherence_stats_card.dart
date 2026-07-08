// lib/ui/adherence_history/widgets/adherence_stats_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/adherence_month_stats.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class AdherenceStatsCard extends StatelessWidget {
  const AdherenceStatsCard({
    required this.stats,
    super.key,
  });

  final AdherenceMonthStats stats;

  @override
  Widget build(BuildContext context) {
    final percent = stats.adherencePercent.round();

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
      child: SmartRow(
        spacing: 16.w,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88.w,
            height: 88.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Smart widget fallback: determinate ring progress not in SmartCircularProgressIndicator.
                SizedBox(
                  width: 88.w,
                  height: 88.w,
                  child: CircularProgressIndicator(
                    value: stats.totalDoses == 0 ? 0 : stats.adherencePercent / 100,
                    strokeWidth: 8.w,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                  ),
                ),
                SmartColumn(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 2.h,
                  children: [
                    SmartText(
                      '$percent%',
                      style: AppTextStyles.heading2.copyWith(color: AppColors.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'adherence.taken_label'.tr,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SmartColumn(
              spacing: 8.h,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmartText(
                  'adherence.stats_title'.tr,
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  'adherence.stats_body'.trParams({
                    'taken': '${stats.takenDoses}',
                    'total': '${stats.totalDoses}',
                  }),
                  style: AppTextStyles.body2,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  'adherence.streak'.trParams({'days': '${stats.streakDays}'}),
                  style: AppTextStyles.label.copyWith(color: AppColors.accent),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  'adherence.perfect_days'.trParams({
                    'days': '${stats.perfectDays}',
                  }),
                  style: AppTextStyles.caption,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (stats.missedDoses > 0)
                  SmartText(
                    'adherence.stats_missed'.trParams({
                      'count': '${stats.missedDoses}',
                    }),
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (stats.skippedDoses > 0)
                  SmartText(
                    'adherence.stats_skipped'.trParams({
                      'count': '${stats.skippedDoses}',
                    }),
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
