// lib/ui/doubt_query/widgets/voice_doubt_panel.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/ai/voice_doubt_delegate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/sambhdo_button.dart';

class VoiceDoubtPanel extends StatelessWidget {
  const VoiceDoubtPanel({
    required this.delegate,
    this.showHero = true,
    this.compact = false,
    super.key,
  });

  final VoiceDoubtDelegate delegate;
  final bool showHero;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isRecording = delegate.isRecording;
      final isBusy = delegate.isBusy;

      return SmartColumn(
        spacing: 12.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!compact) const AiDisclaimerBanner(),
          if (showHero && !compact)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.accentLight,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: AppColors.accent.withValues(alpha: 0.2),
                ),
              ),
              child: SmartColumn(
                spacing: 8.h,
                children: [
                  SmartText(
                    'doubt.hero_title'.tr,
                    style: AppTextStyles.heading2,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    'doubt.hero_body'.tr,
                    style: AppTextStyles.body2,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    'doubt.offline_note'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.accent,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          if (delegate.medicineContext.value.isNotEmpty)
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartText(
                    'doubt.context_title'.tr,
                    style: AppTextStyles.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    delegate.medicineContext.value,
                    style: AppTextStyles.body2,
                    maxLines: compact ? 3 : 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          if (compact &&
              !isRecording &&
              !isBusy &&
              delegate.answer.value.isEmpty &&
              delegate.errorMessage.value.isEmpty)
            SmartText(
              'doubt.medicine_ask_hint'.tr,
              style: AppTextStyles.body2,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          if (isRecording) _StateCard(
            color: AppColors.warningLight,
            borderColor: AppColors.warning,
            icon: Icons.mic_rounded,
            iconColor: AppColors.warning,
            text: 'doubt.listening'.trParams({
              'time': delegate.recordingDuration,
            }),
            textColor: AppColors.warning,
          ),
          if (isBusy)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
              ),
              child: SmartColumn(
                spacing: 12.h,
                children: [
                  const SmartCircularProgressIndicator(),
                  SmartText(
                    'doubt.thinking'.tr,
                    style: AppTextStyles.body2,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          if (delegate.errorMessage.value.isNotEmpty)
            _StateCard(
              color: AppColors.errorLight,
              borderColor: AppColors.error,
              icon: Icons.error_outline_rounded,
              iconColor: AppColors.error,
              text: delegate.errorMessage.value,
              textColor: AppColors.error,
            ),
          if (delegate.answer.value.isNotEmpty)
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0A000000),
                    blurRadius: 16.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: SmartColumn(
                spacing: 12.h,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SmartText(
                    'doubt.answer_title'.tr,
                    style: AppTextStyles.heading3,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SmartText(
                    delegate.answer.value,
                    style: AppTextStyles.body1,
                    maxLines: 12,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SambhdoButton(
                    onTap: delegate.speakAnswer,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          if (!compact) ...[
            if (isRecording)
              SmartButton(
                title: 'doubt.cancel'.tr,
                onTap: delegate.cancelRecording,
                height: 48.h,
                activeBackgroundColor: AppColors.surface,
                titleStyle: AppTextStyles.button.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            SmartButton(
              title: isRecording
                  ? 'doubt.stop_and_ask'.tr
                  : 'doubt.tap_to_speak'.tr,
              onTap: () {
                if (!isBusy) {
                  delegate.toggleRecording();
                }
              },
              isEnabled: !isBusy,
              isLoading: isBusy,
              height: 56.h,
              activeBackgroundColor:
                  isRecording ? AppColors.error : AppColors.accent,
            ),
          ],
        ],
      );
    });
  }
}

class VoiceMicButton extends StatelessWidget {
  const VoiceMicButton({
    required this.onTap,
    this.isRecording = false,
    this.isBusy = false,
    super.key,
  });

  final VoidCallback? onTap;
  final bool isRecording;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    // Smart widget fallback: SmartButton has no compact circular icon-only mic variant.
    return GestureDetector(
      onTap: isBusy ? null : onTap,
      child: Container(
        width: 48.w,
        height: 48.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isRecording ? AppColors.errorLight : AppColors.accentLight,
          shape: BoxShape.circle,
          border: Border.all(
            color: isRecording ? AppColors.error : AppColors.accent,
            width: 1.5,
          ),
        ),
        child: Icon(
          isRecording ? Icons.stop_rounded : Icons.mic_rounded,
          size: 22.r,
          color: isRecording ? AppColors.error : AppColors.accent,
          semanticLabel: 'doubt.tap_to_speak'.tr,
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
  });

  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: borderColor),
      ),
      child: SmartRow(
        spacing: 12.w,
        children: [
          Icon(icon, color: iconColor, size: 22.r),
          Expanded(
            child: SmartText(
              text,
              style: AppTextStyles.body1.copyWith(color: textColor),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
