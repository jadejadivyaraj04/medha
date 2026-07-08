// lib/ui/caregiver/view/caregiver_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/caregiver_controller.dart';
import '../widgets/caregiver_shimmer.dart';

class CaregiverPage extends GetView<CaregiverController> {
  const CaregiverPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'caregiver.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
        actions: [
          SambhdoButton(
            onTap: controller.speakPrivacySummary,
            fullWidth: false,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return SmartSingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
            child: const CaregiverShimmer(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.profileId.value.isEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        return SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 20.h,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: SmartColumn(
                        spacing: 8.h,
                        children: [
                          SmartText(
                            'caregiver.privacy_title'.tr,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.accent,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            'caregiver.privacy_body'.tr,
                            style: AppTextStyles.body2,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (controller.hasSavedCaregiver)
                      Container(
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
                              'caregiver.saved_title'.tr,
                              style: AppTextStyles.heading3,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SmartText(
                              'caregiver.saved_body'.trParams({
                                'name': controller.nameCtrl.text,
                                'relation': controller.relationshipLabel(
                                  controller.relationship.value,
                                ),
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
                                    title: 'caregiver.export_cta'.tr,
                                    onTap: controller.openDoctorExport,
                                    height: 44.h,
                                    activeBackgroundColor: AppColors.surface,
                                    titleStyle: AppTextStyles.label,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    SmartText(
                      'caregiver.section_contact'.tr,
                      style: AppTextStyles.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartTextField(
                      controller: controller.nameCtrl,
                      hintText: 'caregiver.name_hint'.tr,
                      errorText: controller.nameError.value.isEmpty
                          ? null
                          : controller.nameError.value,
                    ),
                    SmartTextField(
                      controller: controller.phoneCtrl,
                      hintText: 'caregiver.phone_hint'.tr,
                      keyboardType: TextInputType.phone,
                      errorText: controller.phoneError.value.isEmpty
                          ? null
                          : controller.phoneError.value,
                    ),
                    SmartText(
                      'caregiver.section_relationship'.tr,
                      style: AppTextStyles.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartSingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SmartRow(
                        spacing: 8.w,
                        children: CaregiverController.relationshipOptions
                            .map((code) {
                          final selected =
                              controller.relationship.value == code;
                          return SmartButton(
                            title: controller.relationshipLabel(code),
                            onTap: () => controller.selectRelationship(code),
                            height: 34.h,
                            width: 100.w,
                            activeBackgroundColor: selected
                                ? AppColors.accent
                                : AppColors.surface,
                            titleStyle: AppTextStyles.label.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    SmartText(
                      'caregiver.section_sharing'.tr,
                      style: AppTextStyles.overline,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceElevated,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: SmartRow(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: SmartColumn(
                              spacing: 4.h,
                              children: [
                                SmartText(
                                  'caregiver.share_adherence_title'.tr,
                                  style: AppTextStyles.heading3,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SmartText(
                                  'caregiver.share_adherence_subtitle'.tr,
                                  style: AppTextStyles.caption,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: controller.shareAdherence.value,
                            activeTrackColor: AppColors.accent,
                            onChanged: controller.toggleShareAdherence,
                          ),
                        ],
                      ),
                    ),
                    SmartText(
                      'caregiver.disclaimer'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.warning,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding:
                  EdgeInsets.fromLTRB(20.w, 0, 20.w, bottomInset + 16.h),
              spacing: 12.h,
              children: [
                SmartButton(
                  title: 'caregiver.save_cta'.tr,
                  onTap: () {
                    if (!controller.isSaving.value) {
                      controller.save();
                    }
                  },
                  isLoading: controller.isSaving.value,
                  isEnabled: !controller.isSaving.value,
                ),
                if (controller.hasSavedCaregiver)
                  SmartButton(
                    title: 'caregiver.remove_cta'.tr,
                    onTap: () {
                      if (!controller.isRemoving.value) {
                        controller.removeCaregiver();
                      }
                    },
                    isLoading: controller.isRemoving.value,
                    isEnabled: !controller.isRemoving.value,
                    activeBackgroundColor: AppColors.errorLight,
                    titleStyle:
                        AppTextStyles.button.copyWith(color: AppColors.error),
                  ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
