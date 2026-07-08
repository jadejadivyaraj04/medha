// lib/ui/interactions/widgets/danger_interaction_alert_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/interactions/interaction_helper.dart';
import '../../../core/models/drug_interaction_model.dart';
import '../../../core/models/interaction_severity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// Full-width bold red alert for a single dangerous drug interaction.
class DangerInteractionAlertCard extends StatelessWidget {
  const DangerInteractionAlertCard({
    required this.interaction,
    this.showDoctorCta = false,
    this.onCallDoctor,
    super.key,
  });

  final DrugInteractionModel interaction;
  final bool showDoctorCta;
  final VoidCallback? onCallDoctor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.errorLight,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.error, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.18),
            blurRadius: 12.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: SmartColumn(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartRow(
            spacing: 8.w,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.warning_rounded, size: 24.r, color: AppColors.error),
              Expanded(
                child: SmartText(
                  InteractionHelper.interactionTitle(interaction),
                  style: AppTextStyles.heading3.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _DangerBadge(severity: interaction.severity),
            ],
          ),
          SmartText(
            interaction.description,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
          if (interaction.recommendation.isNotEmpty)
            SmartText(
              interaction.recommendation,
              style: AppTextStyles.label.copyWith(color: AppColors.error),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          if (showDoctorCta && onCallDoctor != null)
            SmartButton(
              title: 'interactions.doctor_call_cta'.tr,
              onTap: onCallDoctor!,
              height: 52.h,
              activeBackgroundColor: AppColors.error,
            ),
        ],
      ),
    );
  }
}

class _DangerBadge extends StatelessWidget {
  const _DangerBadge({required this.severity});

  final InteractionSeverity severity;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.error,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: SmartText(
        'interactions.danger_badge'.tr,
        style: AppTextStyles.label.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
