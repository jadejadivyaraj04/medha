// lib/ui/adherence_history/widgets/adherence_calendar_grid.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/reminder_repository.dart';

class AdherenceCalendarGrid extends StatelessWidget {
  const AdherenceCalendarGrid({
    required this.month,
    required this.summaries,
    super.key,
  });

  final DateTime month;
  final Map<String, AdherenceDaySummary> summaries;

  @override
  Widget build(BuildContext context) {
    final firstDay = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = firstDay.weekday - 1;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: SmartColumn(
        spacing: 12.h,
        children: [
          SmartText(
            'adherence.calendar_title'.tr,
            style: AppTextStyles.heading3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SmartRow(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              return Expanded(
                child: SmartText(
                  'adherence.weekdays.${index + 1}'.tr,
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final cellSize = (constraints.maxWidth - (6 * 6.w)) / 7;

              return Wrap(
                spacing: 6.w,
                runSpacing: 6.h,
                children: List.generate(leadingEmpty + daysInMonth, (index) {
                  if (index < leadingEmpty) {
                    return SizedBox(width: cellSize, height: cellSize);
                  }

                  final day = index - leadingEmpty + 1;
                  final dateKey =
                      '${month.year}-${month.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                  final summary = summaries[dateKey];

                  return _DayCell(
                    day: day,
                    summary: summary,
                    size: cellSize,
                  );
                }),
              );
            },
          ),
          SmartRow(
            children: [
              Expanded(
                child: _LegendDot(
                  color: AppColors.success,
                  label: 'adherence.legend.taken'.tr,
                ),
              ),
              Expanded(
                child: _LegendDot(
                  color: AppColors.warning,
                  label: 'adherence.legend.partial'.tr,
                ),
              ),
              Expanded(
                child: _LegendDot(
                  color: AppColors.error,
                  label: 'adherence.legend.missed'.tr,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.summary,
    required this.size,
  });

  final int day;
  final AdherenceDaySummary? summary;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ratio = summary?.ratio ?? -1;
    final color = summary == null
        ? AppColors.surface
        : ratio >= 1
            ? AppColors.success
            : ratio >= 0.5
                ? AppColors.warning
                : AppColors.error;

    final borderColor = summary == null ? AppColors.border : color;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: summary == null
            ? AppColors.surface
            : color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: borderColor.withValues(alpha: summary == null ? 1 : 0.55),
        ),
      ),
      child: SmartText(
        '$day',
        style: AppTextStyles.label.copyWith(
          color: summary == null ? AppColors.textHint : color,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
  });

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SmartRow(
      spacing: 6.w,
      children: [
        Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: SmartText(
            label,
            style: AppTextStyles.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
