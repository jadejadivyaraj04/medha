// lib/ui/profile/widgets/profile_switch_sheet.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/profile_controller.dart';

class ProfileSwitchSheet {
  ProfileSwitchSheet._();

  static void show(ProfileController controller) {
    Get.bottomSheet(
      Obx(() {
        final bottomInset = MediaQuery.paddingOf(Get.context!).bottom;
        final activeId = controller.activeProfileId;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SmartColumn(
            mainAxisSize: MainAxisSize.min,
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, bottomInset + 16.h),
            spacing: 12.h,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                alignment: Alignment.center,
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              SmartText(
                'profile.switch_title'.tr,
                style: AppTextStyles.heading2,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                'profile.switch_subtitle'.tr,
                style: AppTextStyles.body2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              ...controller.profiles.map((profile) {
                final isActive = profile.id == activeId;
                return SmartRow(
                  onTap: controller.isLoading.value
                      ? null
                      : () => controller.switchProfile(profile),
                  isInkwell: true,
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isActive ? AppColors.accentLight : AppColors.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: isActive ? AppColors.accent : AppColors.border,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  spacing: 12.w,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SmartImage(
                      path: profile.avatarUrl ?? '',
                      width: 48.w,
                      height: 48.w,
                      imageBorderRadius: BorderRadius.circular(100.r),
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: SmartColumn(
                        spacing: 2.h,
                        children: [
                          SmartText(
                            profile.name,
                            style: AppTextStyles.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            'profile.age_label'.trParams({'age': '${profile.age}'}),
                            style: AppTextStyles.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isActive)
                      Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.accent,
                        size: 22.r,
                      ),
                  ],
                );
              }),
              SmartButton(
                title: 'profile.add_patient'.tr,
                onTap: () {
                  Get.back<void>();
                  controller.addProfile();
                },
                height: 52.h,
                activeBackgroundColor: AppColors.accentLight,
                titleStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        );
      }),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.45),
    );
  }
}
