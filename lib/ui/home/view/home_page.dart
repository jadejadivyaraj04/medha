// lib/ui/home/view/home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/home_controller.dart';
import '../widgets/home_pucho_card.dart';
import '../widgets/home_refill_nudge_card.dart';
import '../widgets/home_shimmer.dart';
import '../widgets/home_today_doses_card.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SmartColumn(
        isSafeArea: true,
        children: [
          Expanded(
            child: SmartSingleChildScrollView(
              onRefresh: controller.refresh,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
              child: SmartColumn(
                spacing: 16.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartRow(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SmartColumn(
                          spacing: 4.h,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SmartText(
                              'home.greeting'
                                  .trParams({'name': controller.greetingName}),
                              style: AppTextStyles.heading1,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SmartText(
                              controller.todayLabel,
                              style: AppTextStyles.body2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      SambhdoButton(
                        onTap: controller.speakTodaySummary,
                        fullWidth: false,
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(100.r),
                    ),
                    child: SmartText(
                      'home.offline_badge'.tr,
                      style:
                          AppTextStyles.label.copyWith(color: AppColors.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const HomePuchoCard(),
                  if (controller.isLoading.value && controller.doses.isEmpty)
                    const HomeShimmer()
                  else if (controller.doses.isEmpty)
                    SmartNoDataFound(
                      text: 'home.empty_doses_title'.tr,
                      subText: 'home.empty_doses_subtitle'.tr,
                      retryText: 'home.empty_doses_cta'.tr,
                      onRetry: () => Get.toNamed(Routes.SCAN),
                    )
            else
              const HomeTodayDosesCard(),
            const HomeRefillNudgeCard(),
            SmartButton(
                    title: 'reminders.history_cta'.tr,
                    onTap: controller.openHistory,
                    height: 48.h,
                    activeBackgroundColor: AppColors.accentLight,
                    titleStyle:
                        AppTextStyles.label.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
