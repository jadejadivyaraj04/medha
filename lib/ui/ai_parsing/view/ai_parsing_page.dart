// lib/ui/ai_parsing/view/ai_parsing_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../controller/ai_parsing_controller.dart';

class AiParsingPage extends GetView<AiParsingController> {
  const AiParsingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty) {
          return SmartColumn(
            isSafeArea: true,
            children: [
              Expanded(
                child: AppErrorWidget(
                  message: controller.errorMessage.value,
                  onRetry: controller.retry,
                ),
              ),
              SmartColumn(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
                spacing: 12.h,
                children: [
                  SmartButton(
                    title: 'scan.parsing.add_manually'.tr,
                    onTap: controller.addManually,
                    activeBackgroundColor: AppColors.accentLight,
                    titleStyle: AppTextStyles.button.copyWith(color: AppColors.accent),
                  ),
                  SmartButton(
                    title: 'scan.parsing.cancel'.tr,
                    onTap: controller.cancel,
                    activeBackgroundColor: AppColors.surface,
                    titleStyle: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          );
        }

        return SmartColumn(
          isSafeArea: true,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          spacing: 20.h,
          children: [
            SizedBox(
              width: 88.w,
              height: 88.w,
              child: const SmartCircularProgressIndicator(),
            ),
            SmartText(
              'scan.parsing.title'.tr,
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              controller.statusKeys[controller.statusIndex.value].tr,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              'scan.parsing.offline_note'.tr,
              style: AppTextStyles.caption,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 32.h),
            SmartButton(
              title: 'scan.parsing.cancel'.tr,
              onTap: controller.cancel,
              width: 160.w,
              activeBackgroundColor: AppColors.surface,
              titleStyle: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }
}
