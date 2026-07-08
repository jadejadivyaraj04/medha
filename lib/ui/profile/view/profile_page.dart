// lib/ui/profile/view/profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../controller/profile_controller.dart';
import '../widgets/profile_header_card.dart';
import '../widgets/profile_menu_tile.dart';
import '../widgets/profile_shimmer.dart';
import '../widgets/profile_switch_sheet.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.activeProfile.value == null) {
        return SmartColumn(
          isSafeArea: true,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 16.h),
            SmartText(
              'profile.title'.tr,
              style: AppTextStyles.heading1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 16.h),
            const ProfileShimmer(),
          ],
        );
      }

      if (controller.errorMessage.value.isNotEmpty &&
          controller.activeProfile.value == null) {
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

      final profile = controller.activeProfile.value;
      if (profile == null) {
        return SmartColumn(
          isSafeArea: true,
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          children: [
            SizedBox(height: 16.h),
            SmartText(
              'profile.title'.tr,
              style: AppTextStyles.heading1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Expanded(
              child: Center(
                child: SmartNoDataFound(
                  text: 'profile.empty_title'.tr,
                  subText: 'profile.empty_subtitle'.tr,
                  retryText: 'profile.empty_cta'.tr,
                  onRetry: controller.addProfile,
                ),
              ),
            ),
          ],
        );
      }

      return SmartColumn(
        isSafeArea: true,
        children: [
          Expanded(
            child: SmartSingleChildScrollView(
              onRefresh: controller.refresh,
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SmartColumn(
                spacing: 16.h,
                children: [
            SizedBox(height: 16.h),
            SmartText(
              'profile.title'.tr,
              style: AppTextStyles.heading1,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: SmartText(
                'profile.offline_badge'.tr,
                style: AppTextStyles.label.copyWith(color: AppColors.accent),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ProfileHeaderCard(
              profile: profile,
              onSwitchTap: () => ProfileSwitchSheet.show(controller),
              onSpeakTap: controller.speakProfile,
            ),
            ProfileMenuTile(
              icon: Icons.history_rounded,
              title: 'profile.menu_adherence'.tr,
              subtitle: 'profile.menu_adherence_sub'.tr,
              onTap: controller.openAdherenceHistory,
            ),
            ProfileMenuTile(
              icon: Icons.mic_rounded,
              title: 'doubt.menu_title'.tr,
              subtitle: 'doubt.menu_subtitle'.tr,
              onTap: controller.openDoubtQuery,
            ),
            ProfileMenuTile(
              icon: Icons.family_restroom_rounded,
              title: 'caregiver.menu_title'.tr,
              subtitle: 'caregiver.menu_subtitle'.tr,
              onTap: controller.openCaregiver,
            ),
            ProfileMenuTile(
              icon: Icons.picture_as_pdf_rounded,
              title: 'doctor_export.menu_title'.tr,
              subtitle: 'doctor_export.menu_subtitle'.tr,
              onTap: controller.openDoctorExport,
            ),
            ProfileMenuTile(
              icon: Icons.settings_rounded,
              title: 'profile.menu_settings'.tr,
              subtitle: 'profile.menu_settings_sub'.tr,
              onTap: controller.openSettings,
            ),
            ProfileMenuTile(
              icon: Icons.verified_user_rounded,
              title: 'profile.menu_permissions'.tr,
              subtitle: 'profile.menu_permissions_sub'.tr,
              onTap: () => Get.toNamed(
                Routes.PERMISSION_SUMMARY,
                arguments: {'fromSettings': true},
              ),
            ),
            ProfileMenuTile(
              icon: Icons.info_outline_rounded,
              title: 'profile.menu_about'.tr,
              subtitle: 'profile.menu_about_sub'.tr,
              onTap: controller.openSettings,
            ),
            SmartText(
              'profile.disclaimer'.tr,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }
}
