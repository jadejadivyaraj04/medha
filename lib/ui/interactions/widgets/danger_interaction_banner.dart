// lib/ui/interactions/widgets/danger_interaction_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class DangerInteractionBanner extends StatelessWidget {
  const DangerInteractionBanner({
    required this.interactions,
    super.key,
  });

  final List<DrugInteractionModel> interactions;

  @override
  Widget build(BuildContext context) {
    final dangers = InteractionHelper.dangerOnly(interactions);
    if (dangers.isEmpty) {
      return const SizedBox.shrink();
    }

    final headline = dangers.length == 1
        ? InteractionHelper.interactionTitle(dangers.first)
        : 'interactions.multiple_danger'.trParams({'count': '${dangers.length}'});

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error, width: 1.5),
      ),
      child: SmartRow(
        spacing: 12.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_rounded, size: 22.r, color: AppColors.error),
          Expanded(
            child: SmartColumn(
              spacing: 4.h,
              children: [
                SmartText(
                  'interactions.danger_banner_title'.tr,
                  style: AppTextStyles.heading3.copyWith(color: AppColors.error),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  headline,
                  style: AppTextStyles.body2,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
