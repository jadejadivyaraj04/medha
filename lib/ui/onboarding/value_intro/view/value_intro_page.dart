// lib/ui/onboarding/value_intro/view/value_intro_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../widgets/onboarding_page_dots.dart';
import '../controller/value_intro_controller.dart';

class ValueIntroPage extends GetView<ValueIntroController> {
  const ValueIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SmartColumn(
        isSafeArea: true,
        children: [
          SmartRow(
            mainAxisAlignment: MainAxisAlignment.end,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            children: [
              SmartButton(
                title: 'onboarding.common.skip'.tr,
                onTap: controller.skip,
                width: 96.w,
                height: 40.h,
                activeBackgroundColor: AppColors.surface,
                titleStyle: AppTextStyles.label.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          Expanded(
            // Smart widget fallback: no SmartPageView; onboarding swipe needs PageView.
            child: PageView.builder(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              itemCount: controller.slides.length,
              itemBuilder: (_, index) {
                final slide = controller.slides[index];
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final imageHeight = (constraints.maxHeight * 0.52)
                        .clamp(200.h, 300.h)
                        .toDouble();

                    return SmartSingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: SmartColumn(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 16.h,
                        children: [
                          SmartImage(
                            path: slide.imageUrl,
                            width: double.infinity,
                            height: imageHeight,
                            fit: BoxFit.cover,
                            imageBorderRadius: BorderRadius.circular(20.r),
                          ),
                          SmartText(
                            slide.titleKey.tr,
                            style: AppTextStyles.heading1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            slide.bodyKey.tr,
                            style: AppTextStyles.body2,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Obx(
            () => SmartColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, bottomInset + 16.h),
              spacing: 20.h,
              children: [
                OnboardingPageDots(
                  count: controller.slides.length,
                  currentIndex: controller.currentPage.value,
                ),
                SmartButton(
                  title: controller.isLastPage
                      ? 'onboarding.common.start'.tr
                      : 'onboarding.common.next'.tr,
                  onTap: controller.next,
                  activeBackgroundColor: AppColors.accent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
