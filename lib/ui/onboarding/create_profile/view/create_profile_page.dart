// lib/ui/onboarding/create_profile/view/create_profile_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../controller/create_profile_controller.dart';

class CreateProfilePage extends GetView<CreateProfileController> {
  const CreateProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'onboarding.profile.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
      ),
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.saveProfile,
          );
        }

        return SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomInset),
                child: SmartColumn(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20.h,
                  children: [
                    SmartText(
                      'onboarding.profile.subtitle'.tr,
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Container(
                      width: 88.w,
                      height: 88.w,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.accentLight,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 40.r,
                        color: AppColors.accent,
                      ),
                    ),
                    SmartTextField(
                      controller: controller.nameCtrl,
                      hintText: 'onboarding.profile.name_hint'.tr,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.name,
                    ),
                    Obx(
                      () => controller.nameError.value.isEmpty
                          ? const SizedBox.shrink()
                          : SmartText(
                              controller.nameError.value,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.error,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                    ),
                    SmartTextField(
                      controller: controller.ageCtrl,
                      hintText: 'onboarding.profile.age_hint'.tr,
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.number,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: AppColors.warningLight,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.warning.withOpacity(0.3)),
                      ),
                      child: SmartText(
                        'onboarding.profile.disclaimer'.tr,
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding: EdgeInsets.fromLTRB(
                20.w,
                8.h,
                20.w,
                MediaQuery.paddingOf(context).bottom + 16.h,
              ),
              children: [
                SmartButton(
                  title: 'onboarding.profile.save'.tr,
                  isLoading: controller.isLoading.value,
                  onTap: () => controller.saveProfile(),
                  isEnabled: !controller.isLoading.value,
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
