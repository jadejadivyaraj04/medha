// lib/ui/medicines/widgets/medicine_filter_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/medicines_controller.dart';

class MedicineFilterBar extends GetView<MedicinesController> {
  const MedicineFilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SmartSingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
        child: SmartRow(
          spacing: 8.w,
          children: [
            _FilterChip(
              label: 'medicines.filter.all'.tr,
              selected: controller.selectedFilter.value == MedicineFilter.all,
              onTap: () => controller.selectFilter(MedicineFilter.all),
            ),
            _FilterChip(
              label: 'medicines.filter.active'.tr,
              selected: controller.selectedFilter.value == MedicineFilter.active,
              onTap: () => controller.selectFilter(MedicineFilter.active),
            ),
            _FilterChip(
              label: 'medicines.filter.completed'.tr,
              selected:
                  controller.selectedFilter.value == MedicineFilter.completed,
              onTap: () => controller.selectFilter(MedicineFilter.completed),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmartButton(
      title: label,
      onTap: onTap,
      height: 34.h,
      activeBackgroundColor: selected ? AppColors.accent : AppColors.surfaceElevated,
      titleStyle: AppTextStyles.label.copyWith(
        color: selected ? Colors.white : AppColors.textSecondary,
      ),
      borderRadius: BorderRadius.circular(100.r),
    );
  }
}
