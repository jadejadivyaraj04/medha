// lib/ui/shell/widgets/rag_indexing_banner.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/ai/rag_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class RagIndexingBanner extends StatelessWidget {
  const RagIndexingBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final rag = Get.find<RagService>();

    return Obx(() {
      if (!rag.isIndexing.value) {
        return const SizedBox.shrink();
      }

      return Material(
        color: AppColors.surfaceElevated,
        elevation: 4,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 10.h),
            child: SmartColumn(
              spacing: 8.h,
              mainAxisSize: MainAxisSize.min,
              children: [
                SmartRow(
                  spacing: 10.w,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 22.w,
                      height: 22.w,
                      child: const SmartCircularProgressIndicator(),
                    ),
                    Expanded(
                      child: SmartText(
                        rag.indexStatusMessage.value.isNotEmpty
                            ? rag.indexStatusMessage.value
                            : 'rag.indexing_loading'.tr,
                        style: AppTextStyles.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SmartText(
                      '${(rag.indexProgress.value * 100).round()}%',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: rag.indexProgress.value.clamp(0, 1),
                  backgroundColor: AppColors.border,
                  color: AppColors.accent,
                  minHeight: 4.h,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
