// lib/ui/settings/view/settings_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../controller/settings_controller.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: SmartAppBar(
        title: 'settings.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: SmartCircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.load,
          );
        }

        final settings = controller.settings.value;

        return SmartSingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomInset + 24.h),
          child: SmartColumn(
            spacing: 20.h,
            children: [
              _sectionTitle('settings.section_language'.tr),
              SmartSingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SmartRow(
                  spacing: 8.w,
                  children: SettingsController.languageOptions.map((code) {
                    final selected = settings.languageCode == code;
                    return SmartButton(
                      title: controller.languageLabel(code),
                      onTap: () => controller.setLanguage(code),
                      height: 34.h,
                      width: 110.w,
                      activeBackgroundColor:
                          selected ? AppColors.accent : AppColors.surface,
                      titleStyle: AppTextStyles.label.copyWith(
                        color: selected ? Colors.white : AppColors.textPrimary,
                      ),
                    );
                  }).toList(),
                ),
              ),
              _sectionTitle('settings.section_text_size'.tr),
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: SmartColumn(
                  spacing: 8.h,
                  children: [
                    SmartRow(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SmartText(
                          'settings.text_size_preview'.tr,
                          style: AppTextStyles.body2,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SmartText(
                          '${settings.textScale.toStringAsFixed(1)}×',
                          style: AppTextStyles.label.copyWith(color: AppColors.accent),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Slider(
                      value: settings.textScale,
                      min: 1.3,
                      max: 1.5,
                      divisions: 4,
                      activeColor: AppColors.accent,
                      onChanged: controller.setTextScale,
                    ),
                    SmartText(
                      'settings.text_size_hint'.tr,
                      style: AppTextStyles.caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _sectionTitle('settings.section_voice'.tr),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                            'settings.voice_title'.tr,
                            style: AppTextStyles.heading3,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            'settings.voice_subtitle'.tr,
                            style: AppTextStyles.caption,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: settings.voiceEnabled,
                      activeColor: AppColors.accent,
                      onChanged: controller.toggleVoice,
                    ),
                  ],
                ),
              ),
              _sectionTitle('settings.section_permissions'.tr),
              SmartButton(
                title: 'settings.permissions_cta'.tr,
                onTap: controller.openPermissions,
                height: 52.h,
                activeBackgroundColor: AppColors.surfaceElevated,
                titleStyle: AppTextStyles.label.copyWith(color: AppColors.textPrimary),
              ),
              _sectionTitle('settings.section_model'.tr),
              Container(
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
                      controller.modelStatusLabel,
                      style: AppTextStyles.body2,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (controller.modelDownloading.value)
                      LinearProgressIndicator(
                        value: controller.modelProgress.value,
                        backgroundColor: AppColors.border,
                        color: AppColors.accent,
                        minHeight: 6.h,
                      ),
                    SmartButton(
                      title: 'settings.model_redownload'.tr,
                      onTap: controller.modelDownloading.value
                          ? () {}
                          : () {
                              controller.redownloadModel();
                            },
                      isLoading: controller.modelDownloading.value,
                      height: 48.h,
                      activeBackgroundColor: AppColors.accentLight,
                      titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
                    ),
                    SmartText(
                      'settings.model_hint'.tr,
                      style: AppTextStyles.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _sectionTitle('settings.section_about'.tr),
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
                      'settings.about_title'.tr,
                      style: AppTextStyles.heading3,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'settings.about_body'.tr,
                      style: AppTextStyles.body2,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      'settings.disclaimer'.tr,
                      style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _sectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: SmartText(
        title,
        style: AppTextStyles.overline,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
