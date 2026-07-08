// lib/ui/medicine_detail/widgets/prescription_compare_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/prescription_compare_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/medicine_detail_controller.dart';

class PrescriptionCompareSection extends GetView<MedicineDetailController> {
  const PrescriptionCompareSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoadingPrescriptionCompare.value) {
        return _SectionShell(
          child: SmartText(
            'medicines.compare_checking'.tr,
            style: AppTextStyles.body2,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }

      final compare = controller.prescriptionCompare.value;
      if (compare == null) {
        return const SizedBox.shrink();
      }

      final items = compare.significantItems;
      if (items.isEmpty) {
        return _SectionShell(
          child: SmartColumn(
            spacing: 8.h,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SmartRow(
                spacing: 8.w,
                children: [
                  Expanded(
                    child: SmartText(
                      'medicines.compare_title'.tr,
                      style: AppTextStyles.heading3,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SambhdoButton(onTap: controller.speakPrescriptionCompare),
                ],
              ),
              SmartText(
                'medicines.compare_no_changes'.trParams({
                  'label': compare.otherLabel,
                }),
                style: AppTextStyles.body2,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }

      return _SectionShell(
        child: SmartColumn(
          spacing: 12.h,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SmartRow(
              spacing: 8.w,
              children: [
                Expanded(
                  child: SmartText(
                    'medicines.compare_title'.tr,
                    style: AppTextStyles.heading3,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SambhdoButton(onTap: controller.speakPrescriptionCompare),
              ],
            ),
            SmartText(
              'medicines.compare_subtitle'.trParams({
                'label': compare.otherLabel,
              }),
              style: AppTextStyles.body2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            for (final item in items) _DiffRow(item: item),
            SmartText(
              'medicines.compare_disclaimer'.tr,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }
}

class _DiffRow extends GetView<MedicineDetailController> {
  const _DiffRow({required this.item});

  final PrescriptionDiffItem item;

  Color get _bg {
    return switch (item.type) {
      PrescriptionDiffType.added => AppColors.successLight,
      PrescriptionDiffType.removed => AppColors.errorLight,
      PrescriptionDiffType.changed => AppColors.warningLight,
      PrescriptionDiffType.unchanged => AppColors.surface,
    };
  }

  Color get _color {
    return switch (item.type) {
      PrescriptionDiffType.added => AppColors.success,
      PrescriptionDiffType.removed => AppColors.error,
      PrescriptionDiffType.changed => AppColors.warning,
      PrescriptionDiffType.unchanged => AppColors.textSecondary,
    };
  }

  String get _label {
    return switch (item.type) {
      PrescriptionDiffType.added => 'medicines.compare_added'.tr,
      PrescriptionDiffType.removed => 'medicines.compare_removed'.tr,
      PrescriptionDiffType.changed => 'medicines.compare_changed'.tr,
      PrescriptionDiffType.unchanged => 'medicines.compare_unchanged'.tr,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: SmartColumn(
        spacing: 4.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartText(
            _label,
            style: AppTextStyles.label.copyWith(color: _color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SmartText(
            item.displayName,
            style: AppTextStyles.body1,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (item.type == PrescriptionDiffType.changed &&
              item.changedFields.isNotEmpty)
            SmartText(
              controller.changedFieldsLabel(item.changedFields),
              style: AppTextStyles.caption,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
