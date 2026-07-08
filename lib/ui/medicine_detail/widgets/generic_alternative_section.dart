// lib/ui/medicine_detail/widgets/generic_alternative_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/generic_alternative_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';

class GenericAlternativeSection extends StatelessWidget {
  const GenericAlternativeSection({
    required this.alternative,
    this.isLoading = false,
    this.onSpeak,
    super.key,
  });

  final GenericAlternativeModel? alternative;
  final bool isLoading;
  final VoidCallback? onSpeak;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _SectionShell(
        child: SmartText(
          'medicines.generic_checking'.tr,
          style: AppTextStyles.body2,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final hasData = alternative != null && alternative!.hasAlternatives;

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
                  'medicines.generic_title'.tr,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasData && onSpeak != null) SambhdoButton(onTap: onSpeak!),
            ],
          ),
          if (!hasData)
            SmartText(
              'medicines.generic_empty'.tr,
              style: AppTextStyles.body2,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          else ...[
            SmartText(
              'medicines.generic_name'.trParams({
                'name': alternative!.genericName,
              }),
              style: AppTextStyles.body1,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            for (final option in alternative!.alternatives)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: SmartColumn(
                  spacing: 4.h,
                  children: [
                    SmartText(
                      option.name,
                      style: AppTextStyles.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      option.note,
                      style: AppTextStyles.caption,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            if (alternative!.source.trim().isNotEmpty)
              SmartText(
                'interactions.source_label'.trParams({
                  'source': alternative!.source,
                }),
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
          SmartText(
            'medicines.generic_disclaimer'.tr,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
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
