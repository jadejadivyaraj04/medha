// lib/ui/onboarding/splash/view/splash_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/ai/gemma_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../controller/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final gemma = Get.find<GemmaService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.errorMessage.value.isNotEmpty) {
          return AppErrorWidget(
            message: controller.errorMessage.value,
            onRetry: controller.retry,
          );
        }

        return SmartColumn(
          isSafeArea: true,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          spacing: 12.h,
          children: [
            const Spacer(),
            SmartText(
              'app.name'.tr,
              style: AppTextStyles.displayLarge,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SmartText(
              'app.tagline'.tr,
              style: AppTextStyles.body2,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            if (controller.isLoading.value || gemma.isDownloading.value) ...[
              SizedBox(
                width: 72.w,
                height: 72.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 72.w,
                      height: 72.w,
                      child: CircularProgressIndicator(
                        value: gemma.downloadProgress.value > 0
                            ? gemma.downloadProgress.value
                            : null,
                        strokeWidth: 3.5,
                        color: AppColors.accent,
                        backgroundColor: AppColors.border,
                      ),
                    ),
                    SmartText(
                      '${(gemma.downloadProgress.value * 100).round()}%',
                      style: AppTextStyles.label.copyWith(color: AppColors.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SmartText(
                'onboarding.splash.setup_title'.tr,
                style: AppTextStyles.heading3,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                'onboarding.splash.setup_body'.tr,
                style: AppTextStyles.body2,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                'onboarding.splash.wifi_hint'.tr,
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SmartButton(
                title: 'onboarding.splash.cancel'.tr,
                onTap: controller.cancelDownload,
                width: 160.w,
                activeBackgroundColor: AppColors.surface,
                titleStyle: AppTextStyles.button.copyWith(color: AppColors.textSecondary),
              ),
            ],
            SizedBox(height: MediaQuery.paddingOf(context).bottom + 24.h),
          ],
        );
      }),
    );
  }
}
