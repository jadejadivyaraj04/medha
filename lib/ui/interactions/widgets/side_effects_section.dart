// lib/ui/interactions/widgets/side_effects_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/side_effect_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';

class SideEffectsSection extends StatelessWidget {
  const SideEffectsSection({
    required this.sideEffects,
    this.isLoading = false,
    this.onSpeak,
    super.key,
  });

  final SideEffectModel? sideEffects;
  final bool isLoading;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _SectionShell(
        child: SmartText(
          'interactions.checking'.tr,
          style: AppTextStyles.body2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final hasEffects = sideEffects != null && sideEffects!.hasEffects;

    return _SectionShell(
      child: SmartColumn(
        spacing: 12.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartRow(
            spacing: 8.w,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: SmartText(
                  'interactions.side_effects_title'.tr,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasEffects && onSpeak != null)
                SambhdoButton(onTap: onSpeak!),
            ],
          ),
          if (!hasEffects)
            SmartText(
              'interactions.no_side_effects'.tr,
              style: AppTextStyles.body2,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          else ...[
            for (final effect in sideEffects!.effects)
              SmartRow(
                spacing: 8.w,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 6.h),
                    child: Icon(
                      Icons.circle,
                      size: 6.r,
                      color: AppColors.accent,
                    ),
                  ),
                  Expanded(
                    child: SmartText(
                      effect,
                      style: AppTextStyles.body2,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            if (sideEffects!.source.trim().isNotEmpty)
              SmartText(
                'interactions.source_label'.trParams({
                  'source': sideEffects!.source,
                }),
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          SmartText(
            'interactions.source_note'.tr,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}
