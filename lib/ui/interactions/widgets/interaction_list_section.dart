// lib/ui/interactions/widgets/interaction_list_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Non-blocking interaction rows (moderate/minor) below the danger banner.
class InteractionListSection extends StatelessWidget {
  const InteractionListSection({
    required this.interactions,
    required this.isLoading,
    super.key,
  });

  final List<DrugInteractionModel> interactions;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SizedBox.shrink();
    }

    final warnings = interactions.where((item) => !item.isDanger).toList();
    if (warnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.35)),
      ),
      child: SmartColumn(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartText(
            'interactions.warning_list_title'.tr,
            style: AppTextStyles.heading3.copyWith(color: AppColors.warning),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          ...warnings.map((item) => _InteractionRow(interaction: item)),
        ],
      ),
    );
  }
}

class _InteractionRow extends StatelessWidget {
  const _InteractionRow({required this.interaction});

  final DrugInteractionModel interaction;

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      spacing: 4.h,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SmartRow(
          spacing: 8.w,
          children: [
            Expanded(
              child: SmartText(
                InteractionHelper.interactionTitle(interaction),
                style: AppTextStyles.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: SmartText(
                InteractionHelper.severityLabel(interaction.severity),
                style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SmartText(
          interaction.description,
          style: AppTextStyles.body2,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
