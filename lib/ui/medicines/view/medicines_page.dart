// lib/ui/medicines/view/medicines_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../controller/medicines_controller.dart';
import '../widgets/medicine_card.dart';
import '../widgets/medicine_filter_bar.dart';
import '../widgets/medicine_list_shimmer.dart';

class MedicinesPage extends GetView<MedicinesController> {
  const MedicinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.items.isEmpty) {
        return SmartColumn(
          isSafeArea: true,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8.h,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SmartText(
                'medicines.title'.tr,
                style: AppTextStyles.heading1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const MedicineFilterBar(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: const MedicineListShimmer(),
            ),
          ],
        );
      }

      if (controller.errorMessage.value.isNotEmpty && controller.items.isEmpty) {
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

      if (controller.filteredItems.isEmpty) {
        return SmartColumn(
          isSafeArea: true,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SmartText(
                'medicines.title'.tr,
                style: AppTextStyles.heading1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const MedicineFilterBar(),
            Expanded(
              child: Center(
                child: SmartNoDataFound(
                  text: 'medicines.empty_title'.tr,
                  subText: 'medicines.empty_subtitle'.tr,
                  retryText: 'medicines.empty_cta'.tr,
                  onRetry: controller.openScan,
                ),
              ),
            ),
          ],
        );
      }

      final groups = controller.groupedItems;

      return SmartColumn(
        isSafeArea: true,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: SmartText(
              'medicines.title'.tr,
              style: AppTextStyles.heading1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const MedicineFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.refresh,
              color: AppColors.accent,
              // Smart widget fallback: RefreshIndicator not available on SmartSingleChildScrollView for nested list.
              child: ListView(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                children: [
                  for (final entry in groups.entries) ...[
                    Padding(
                      padding: EdgeInsets.only(bottom: 8.h, top: 4.h),
                      child: SmartText(
                        controller.groupTitle(entry.key),
                        style: AppTextStyles.overline,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    for (final medicine in entry.value) ...[
                      MedicineCard(medicine: medicine),
                      SizedBox(height: 12.h),
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
