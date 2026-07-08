// lib/ui/onboarding/language/view/language_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controller/language_controller.dart';

class LanguagePage extends GetView<LanguageController> {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SmartColumn(
        isSafeArea: true,
        children: [
          Expanded(
            child: SmartSingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
              child: SmartColumn(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 24.h,
                children: [
                  SmartText(
                    'onboarding.language.title'.tr,
                    style: AppTextStyles.heading1,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    'onboarding.language.subtitle'.tr,
                    style: AppTextStyles.body2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Obx(
                    () => SmartColumn(
                      spacing: 12.h,
                      children: controller.languages.map((option) {
                        final isSelected = controller.selectedCode.value == option.code;
                        return SmartButton(
                          title: option.labelKey.tr,
                          onTap: () => controller.selectLanguage(option.code),
                          height: 64.h,
                          activeBackgroundColor:
                              isSelected ? AppColors.accentLight : AppColors.surfaceElevated,
                          titleStyle: AppTextStyles.heading3.copyWith(
                            color: isSelected ? AppColors.accent : AppColors.textPrimary,
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Obx(
            () => SmartColumn(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
              children: [
                SmartButton(
                  title: 'onboarding.common.next'.tr,
                  onTap: controller.continueNext,
                  isEnabled: controller.canContinue,
                  activeBackgroundColor: AppColors.accent,
                  disableBackgroundColor: AppColors.border,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
