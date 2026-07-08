// lib/ui/interactions/widgets/danger_interaction_acknowledgement_overlay.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/drug_interaction_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/sambhdo_button.dart';
import 'danger_interaction_alert_card.dart';

/// Blocking overlay — requires explicit acknowledgement; never auto-dismisses.
class DangerInteractionAcknowledgementOverlay extends StatelessWidget {
  const DangerInteractionAcknowledgementOverlay({
    required this.interactions,
    required this.onAcknowledge,
    required this.onCallDoctor,
    this.onSpeak,
    super.key,
  });

  final List<DrugInteractionModel> interactions;
  final VoidCallback onAcknowledge;
  final VoidCallback onCallDoctor;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return PopScope(
      canPop: false,
      child: Material(
        color: AppColors.background.withValues(alpha: 0.98),
        child: SmartColumn(
          isSafeArea: true,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: const AiDisclaimerBanner(),
            ),
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 16.h,
                  children: [
                    SmartText(
                      'interactions.danger_title'.tr,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
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
                    for (final item in interactions)
                      DangerInteractionAlertCard(interaction: item),
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
                if (onSpeak != null)
                  SambhdoButton(onTap: onSpeak!, fullWidth: true),
                SmartButton(
                  title: 'interactions.doctor_call_cta'.tr,
                  onTap: onCallDoctor,
                  height: 56.h,
                  activeBackgroundColor: AppColors.error,
                ),
                SmartButton(
                  title: 'interactions.acknowledge_continue'.tr,
                  onTap: onAcknowledge,
                  height: 56.h,
                  activeBackgroundColor: AppColors.accentLight,
                  titleStyle:
                      AppTextStyles.button.copyWith(color: AppColors.accent),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
