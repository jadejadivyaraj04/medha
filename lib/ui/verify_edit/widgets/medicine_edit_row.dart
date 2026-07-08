// lib/ui/verify_edit/widgets/medicine_edit_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/medicine_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/verify_edit_controller.dart';

class MedicineEditRow extends GetView<VerifyEditController> {
  const MedicineEditRow({
    required this.medicine,
    super.key,
  });

  final MedicineModel medicine;

  @override
  Widget build(BuildContext context) {
    final fields = controller.controllersFor(medicine.id);
    if (fields == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: medicine.hasLowConfidence ? AppColors.warning : AppColors.border,
          width: medicine.hasLowConfidence ? 1.5 : 1,
        ),
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
          SmartRow(
            spacing: 8.w,
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
                child: SmartText(
                  'scan.verify.medicine_title'.trParams({'index': '${controller.medicines.indexOf(medicine) + 1}'}),
                  style: AppTextStyles.heading3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (controller.medicines.length > 1)
                // Smart widget fallback: icon-only delete control needs compact tap target.
                GestureDetector(
                  onTap: () => controller.removeMedicine(medicine.id),
                  child: Container(
                    width: 36.w,
                    height: 36.w,
                    decoration: BoxDecoration(
                      color: AppColors.errorLight,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 18.r,
                      color: AppColors.error,
                    ),
                  ),
                ),
            ],
          ),
          _Field(
            label: 'scan.verify.name'.tr,
            child: SmartTextField(
              controller: fields.nameCtrl,
              hintText: 'scan.verify.name_hint'.tr,
            ),
            flagged: controller.isFieldFlagged(medicine, 'name'),
            reviewed: controller.isFieldReviewed(medicine.id, 'name'),
          ),
          _Field(
            label: 'scan.verify.dose'.tr,
            child: SmartTextField(
              controller: fields.doseCtrl,
              hintText: 'scan.verify.dose_hint'.tr,
              keyboardType: TextInputType.number,
            ),
            flagged: controller.isFieldFlagged(medicine, 'dosageMg'),
            reviewed: controller.isFieldReviewed(medicine.id, 'dosageMg'),
          ),
          _Field(
            label: 'scan.verify.frequency'.tr,
            child: SmartTextField(
              controller: fields.frequencyCtrl,
              hintText: 'scan.verify.frequency_hint'.tr,
            ),
            flagged: controller.isFieldFlagged(medicine, 'frequency'),
            reviewed: controller.isFieldReviewed(medicine.id, 'frequency'),
          ),
          _FoodSelector(
            value: fields.withFood,
            flagged: controller.isFieldFlagged(medicine, 'withFood'),
            reviewed: controller.isFieldReviewed(medicine.id, 'withFood'),
            onChanged: (value) {
              fields.withFood.value = value;
              if (controller.isFieldFlagged(medicine, 'withFood')) {
                controller.markFieldReviewed(medicine.id, 'withFood');
              }
            },
          ),
          _Field(
            label: 'scan.verify.duration'.tr,
            child: SmartTextField(
              controller: fields.durationCtrl,
              hintText: 'scan.verify.duration_hint'.tr,
              keyboardType: TextInputType.number,
            ),
            flagged: controller.isFieldFlagged(medicine, 'durationDays'),
            reviewed: controller.isFieldReviewed(medicine.id, 'durationDays'),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.flagged,
    required this.reviewed,
    required this.child,
  });

  final String label;
  final bool flagged;
  final bool reviewed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      spacing: 6.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartText(
          label,
          style: AppTextStyles.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        child,
        if (flagged && !reviewed)
          SmartText(
            'scan.verify.check_field'.tr,
            style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}

class _FoodSelector extends StatelessWidget {
  const _FoodSelector({
    required this.value,
    required this.flagged,
    required this.reviewed,
    required this.onChanged,
  });

  final RxString value;
  final bool flagged;
  final bool reviewed;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('before', 'scan.food.before'.tr),
      ('after', 'scan.food.after'.tr),
      ('any', 'scan.food.any'.tr),
    ];

    return SmartColumn(
      spacing: 8.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartText(
          'scan.verify.food'.tr,
          style: AppTextStyles.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Obx(
          () => SmartSingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SmartRow(
              spacing: 8.w,
              children: options.map((option) {
                final isSelected = value.value == option.$1;
                return SmartButton(
                  title: option.$2,
                  onTap: () => onChanged(option.$1),
                  height: 34.h,
                  activeBackgroundColor:
                      isSelected ? AppColors.accent : AppColors.surface,
                  titleStyle: AppTextStyles.label.copyWith(
                    color: isSelected ? Colors.white : AppColors.textSecondary,
                  ),
                  borderRadius: BorderRadius.circular(100.r),
                );
              }).toList(),
            ),
          ),
        ),
        if (flagged && !reviewed)
          SmartText(
            'scan.verify.check_field'.tr,
            style: AppTextStyles.caption.copyWith(color: AppColors.warning),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
      ],
    );
  }
}
