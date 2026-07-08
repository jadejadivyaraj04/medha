// lib/ui/onboarding/permissions/view/permission_slide_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/mock/mock_image_urls.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/onboarding_page_dots.dart';
import '../controller/permission_slide_controller.dart';
import '../model/onboarding_permission.dart';

class PermissionSlidePage extends GetView<PermissionSlideController> {
  const PermissionSlidePage({super.key});

  IconData _iconFor(OnboardingPermission permission) {
    return switch (permission) {
      OnboardingPermission.camera => Icons.photo_camera_rounded,
      OnboardingPermission.notifications => Icons.notifications_active_rounded,
      OnboardingPermission.photos => Icons.photo_library_rounded,
      OnboardingPermission.microphone => Icons.mic_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        final permission = controller.permission.value;

        return SmartColumn(
          isSafeArea: true,
          children: [
            SmartColumn(
              padding: EdgeInsets.only(top: 12.h),
              children: [
                OnboardingPageDots(
                  count: OnboardingPermission.totalSlides,
                  currentIndex: permission.slideIndex,
                ),
              ],
            ),
            // Smart widget fallback: SmartSingleChildScrollView has no expanded prop.
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 16.h),
                child: SmartColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20.h,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20.r),
                      child: Stack(
                        children: [
                          SmartImage(
                            path: MockImageUrls.content(permission.slideIndex),
                            width: double.infinity,
                            height: 280.h,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            left: 16.w,
                            bottom: 16.h,
                            child: Container(
                              width: 56.w,
                              height: 56.w,
                              decoration: BoxDecoration(
                                color: AppColors.glassWhite,
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: Icon(
                                _iconFor(permission),
                                color: AppColors.accent,
                                size: 28.r,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SmartText(
                      'onboarding.permission.${permission.id}.title'.tr,
                      style: AppTextStyles.heading1,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'onboarding.permission.${permission.id}.body'.tr,
                      style: AppTextStyles.body1,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'onboarding.permission.privacy_note'.tr,
                      style: AppTextStyles.body2.copyWith(color: AppColors.accent),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
              spacing: 12.h,
              children: [
                SmartButton(
                  title: 'onboarding.permission.allow'.tr,
                  isLoading: controller.isRequesting.value,
                  onTap: controller.allow,
                  isEnabled: !controller.isRequesting.value,
                  activeBackgroundColor: AppColors.accent,
                ),
                SmartButton(
                  title: 'onboarding.permission.later'.tr,
                  onTap: controller.skip,
                  activeBackgroundColor: AppColors.accentLight,
                  titleStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ],
        );
      }),
    );
  }
}
