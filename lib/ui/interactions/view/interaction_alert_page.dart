// lib/ui/interactions/view/interaction_alert_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../controller/interaction_alert_controller.dart';

class InteractionAlertPage extends GetView<InteractionAlertController> {
  const InteractionAlertPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Obx(() {
          final items = controller.interactions;

          return SmartColumn(
            isSafeArea: true,
            children: [
              Expanded(
                child: SmartSingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                  child: SmartColumn(
                    spacing: 16.h,
                    children: [
                      Container(
                        width: 72.w,
                        height: 72.w,
                        decoration: BoxDecoration(
                          color: AppColors.errorLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.warning_rounded,
                          size: 36.r,
                          color: AppColors.error,
                        ),
                      ),
                      SmartText(
                        'interactions.danger_title'.tr,
                        style: AppTextStyles.heading1.copyWith(
                          color: AppColors.error,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SmartText(
                        'interactions.danger_body'.tr,
                        style: AppTextStyles.body1,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const AiDisclaimerBanner(),
                      for (final item in items) _InteractionCard(item: item),
                      SmartText(
                        'interactions.source_note'.tr,
                        style: AppTextStyles.caption,
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
                  SambhdoButton(
                    onTap: controller.speakAlert,
                    fullWidth: true,
                  ),
                  SmartButton(
                    title: 'interactions.doctor_call_cta'.tr,
                    onTap: controller.callDoctor,
                    height: 56.h,
                    activeBackgroundColor: AppColors.error,
                  ),
                  SmartButton(
                    title: 'interactions.acknowledge_continue'.tr,
                    onTap: controller.acknowledge,
                    height: 56.h,
                    activeBackgroundColor: AppColors.accentLight,
                    titleStyle:
                        AppTextStyles.button.copyWith(color: AppColors.accent),
                  ),
                ],
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _InteractionCard extends StatelessWidget {
  const _InteractionCard({required this.item});

  final DrugInteractionModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: SmartColumn(
        spacing: 8.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartRow(
            spacing: 8.w,
            children: [
              Expanded(
                child: SmartText(
                  InteractionHelper.interactionTitle(item),
                  style: AppTextStyles.heading3.copyWith(color: AppColors.error),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(100.r),
                ),
                child: SmartText(
                  InteractionHelper.severityLabel(item.severity),
                  style: AppTextStyles.label.copyWith(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SmartText(
            item.description,
            style: AppTextStyles.body2,
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          SmartText(
            item.recommendation,
            style: AppTextStyles.label.copyWith(color: AppColors.error),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
