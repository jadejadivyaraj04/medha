// lib/ui/doctor_export/widgets/doctor_export_preview_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/doctor_export_report.dart';
import '../../../core/models/medicine_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/repositories/reminder_repository.dart';
import '../controller/doctor_export_controller.dart';

class DoctorExportPreviewCard extends GetView<DoctorExportController> {
  const DoctorExportPreviewCard({
    required this.report,
    super.key,
  });

  final DoctorExportReport report;

  @override
  Widget build(BuildContext context) {
    final stats = report.monthStats;

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
          SmartText(
            'doctor_export.preview_patient'.trParams({
              'name': report.profile.name,
              'age': '${report.profile.age}',
            }),
            style: AppTextStyles.heading3,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SmartText(
            'doctor_export.preview_month'.trParams({
              'month': controller.monthLabel,
            }),
            style: AppTextStyles.body2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (report.hasAdherenceData)
            SmartText(
              'doctor_export.preview_stats'.trParams({
                'percent': '${stats.adherencePercent.round()}',
                'taken': '${stats.takenDoses}',
                'total': '${stats.totalDoses}',
                'streak': '${stats.streakDays}',
              }),
              style: AppTextStyles.body2,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          if (report.activeMedicines.isNotEmpty) ...[
            SmartText(
              'doctor_export.preview_medicines_title'.tr,
              style: AppTextStyles.overline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            ...report.activeMedicines.take(6).map(_medicineRow),
            if (report.activeMedicines.length > 6)
              SmartText(
                'doctor_export.preview_more_meds'.trParams({
                  'count': '${report.activeMedicines.length - 6}',
                }),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          if (report.daySummaries.isNotEmpty) ...[
            SmartText(
              'doctor_export.preview_daily_title'.tr,
              style: AppTextStyles.overline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            ...report.daySummaries.take(5).map(_dayRow),
            if (report.daySummaries.length > 5)
              SmartText(
                'doctor_export.preview_more_days'.trParams({
                  'count': '${report.daySummaries.length - 5}',
                }),
                style: AppTextStyles.caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ],
      ),
    );
  }

  Widget _medicineRow(MedicineModel medicine) {
    final dose = medicine.dosageMg != null ? '${medicine.dosageMg} mg' : '—';
    return SmartRow(
      spacing: 8.w,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.medication_rounded, size: 16.r, color: AppColors.accent),
        Expanded(
          child: SmartColumn(
            spacing: 2.h,
            children: [
              SmartText(
                medicine.name,
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                'doctor_export.medicine_line'.trParams({
                  'dose': dose,
                  'frequency': medicine.frequency,
                  'food': controller.foodLabel(medicine.withFood),
                }),
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dayRow(AdherenceDaySummary day) {
    return SmartRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmartText(
          day.dateKey,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SmartText(
          'doctor_export.day_line'.trParams({
            'taken': '${day.takenCount}',
            'total': '${day.totalCount}',
          }),
          style: AppTextStyles.caption.copyWith(color: AppColors.accent),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
