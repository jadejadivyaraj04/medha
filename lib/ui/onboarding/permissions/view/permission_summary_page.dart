// lib/ui/onboarding/permissions/view/permission_summary_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controller/permission_summary_controller.dart';
import '../model/onboarding_permission.dart';

class PermissionSummaryPage extends GetView<PermissionSummaryController> {
  const PermissionSummaryPage({super.key});

  IconData _iconFor(OnboardingPermission permission) {
    return switch (permission) {
      OnboardingPermission.camera => Icons.photo_camera_rounded,
      OnboardingPermission.notifications => Icons.notifications_active_rounded,
      OnboardingPermission.photos => Icons.photo_library_rounded,
      OnboardingPermission.microphone => Icons.mic_rounded,
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'granted' => AppColors.success,
      'skipped' => AppColors.textHint,
      _ => AppColors.warning,
    };
  }

  String _statusLabel(String status) {
    return switch (status) {
      'granted' => 'onboarding.permission.status_granted'.tr,
      'skipped' => 'onboarding.permission.status_skipped'.tr,
      'denied' => 'onboarding.permission.status_denied'.tr,
      _ => 'onboarding.permission.status_pending'.tr,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'onboarding.permission.summary_title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: SmartCircularProgressIndicator());
        }

        return SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 12.h,
                  children: [
                    SmartText(
                      'onboarding.permission.summary_body'.tr,
                      style: AppTextStyles.body2,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    ...OnboardingPermission.slideOrder.map((permission) {
                      final status = controller.statusFor(permission);
                      return Container(
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
                        child: SmartRow(
                          spacing: 12.w,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: AppColors.accentLight,
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              child: Icon(
                                _iconFor(permission),
                                color: AppColors.accent,
                                size: 20.r,
                              ),
                            ),
                            Expanded(
                              child: SmartColumn(
                                spacing: 4.h,
                                children: [
                                  SmartText(
                                    'onboarding.permission.${permission.id}.title'.tr,
                                    style: AppTextStyles.heading3,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SmartText(
                                    _statusLabel(status),
                                    style: AppTextStyles.caption.copyWith(
                                      color: _statusColor(status),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (status != 'granted')
                              SmartButton(
                                title: 'onboarding.permission.retry'.tr,
                                onTap: () => controller.retryPermission(permission),
                                width: 88.w,
                                height: 36.h,
                                activeBackgroundColor: AppColors.accentLight,
                                titleStyle: AppTextStyles.label.copyWith(
                                  color: AppColors.accent,
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                    SmartButton(
                      title: 'onboarding.permission.open_settings'.tr,
                      onTap: controller.openSettings,
                      activeBackgroundColor: AppColors.surface,
                      titleStyle: AppTextStyles.label.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
              children: [
                SmartButton(
                  title: (Get.arguments is Map &&
                          (Get.arguments as Map)['fromSettings'] == true)
                      ? 'settings.done'.tr
                      : 'onboarding.common.continue'.tr,
                  onTap: controller.continueNext,
                  activeBackgroundColor: AppColors.accent,
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
