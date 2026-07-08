// lib/ui/doctor_export/view/doctor_export_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/doctor_export_controller.dart';
import '../widgets/doctor_export_preview_card.dart';

class DoctorExportPage extends GetView<DoctorExportController> {
  const DoctorExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'doctor_export.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
        actions: [
          SambhdoButton(
            onTap: controller.speakPreview,
            fullWidth: false,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.report.value == null) {
          return const Center(child: SmartCircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.report.value == null) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        final report = controller.report.value;

        return SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                onRefresh: controller.refresh,
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 16.h,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: SmartText(
                        'doctor_export.offline_note'.tr,
                        style: AppTextStyles.label.copyWith(
                          color: AppColors.accent,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    _MonthSwitcher(),
                    if (report == null)
                      SmartNoDataFound(
                        text: 'doctor_export.empty_title'.tr,
                        subText: 'doctor_export.empty_subtitle'.tr,
                      )
                    else if (!controller.hasExportableData)
                      SmartNoDataFound(
                        text: 'doctor_export.empty_title'.tr,
                        subText: 'doctor_export.empty_subtitle'.tr,
                      )
                    else ...[
                      if (report.hasCaregiver)
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: SmartColumn(
                            spacing: 8.h,
                            children: [
                              SmartText(
                                'doctor_export.caregiver_title'.tr,
                                style: AppTextStyles.heading3,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SmartText(
                                report.includeAdherenceForCaregiver
                                    ? 'doctor_export.caregiver_with_adherence'
                                        .trParams({
                                        'name': report.caregiver!.name,
                                      })
                                    : 'doctor_export.caregiver_contact'
                                        .trParams({
                                        'name': report.caregiver!.name,
                                      }),
                                style: AppTextStyles.body2,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SmartRow(
                                spacing: 8.w,
                                children: [
                                  // Smart widget fallback: SmartButton has no expanded prop.
                                  Expanded(
                                    child: SmartButton(
                                      title: 'caregiver.call_cta'.tr,
                                      onTap: controller.callCaregiver,
                                      height: 44.h,
                                      activeBackgroundColor: AppColors.accentLight,
                                      titleStyle: AppTextStyles.label.copyWith(
                                        color: AppColors.accent,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: SmartButton(
                                      title: 'doctor_export.share_caregiver_cta'
                                          .tr,
                                      onTap: () => controller.exportAndShare(
                                        forCaregiver: true,
                                      ),
                                      height: 44.h,
                                      isLoading: controller.isExporting.value,
                                      isEnabled: !controller.isExporting.value,
                                      activeBackgroundColor: AppColors.surface,
                                      titleStyle: AppTextStyles.label,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      DoctorExportPreviewCard(report: report),
                      SmartText(
                        'doctor_export.share_hint'.tr,
                        style: AppTextStyles.caption,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      SmartText(
                        'doctor_export.disclaimer'.tr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.warning,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (report != null && controller.hasExportableData)
              SmartColumn(
                padding:
                    EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomInset + 16.h),
                children: [
                  SmartButton(
                    title: 'doctor_export.export_cta'.tr,
                    onTap: () {
                      if (!controller.isExporting.value) {
                        controller.exportAndShare();
                      }
                    },
                    isLoading: controller.isExporting.value,
                    isEnabled: !controller.isExporting.value,
                  ),
                ],
              ),
          ],
        );
      }),
    );
  }
}

class _MonthSwitcher extends GetView<DoctorExportController> {
  @override
  Widget build(BuildContext context) {
    return SmartRow(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SmartButton(
          title: 'adherence.prev_month'.tr,
          onTap: controller.previousMonth,
          height: 40.h,
          width: 44.w,
          activeBackgroundColor: AppColors.surfaceElevated,
          titleStyle:
              AppTextStyles.label.copyWith(color: AppColors.textPrimary),
        ),
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
          onTap: controller.isCurrentMonth ? () {} : controller.nextMonth,
          height: 40.h,
          width: 44.w,
          isEnabled: !controller.isCurrentMonth,
          activeBackgroundColor: AppColors.surfaceElevated,
          titleStyle: AppTextStyles.label.copyWith(
            color: controller.isCurrentMonth
                ? AppColors.textHint
                : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
