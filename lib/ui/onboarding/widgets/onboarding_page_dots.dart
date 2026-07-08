// lib/ui/onboarding/widgets/onboarding_page_dots.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';

class OnboardingPageDots extends StatelessWidget {
  const OnboardingPageDots({
    required this.count,
    required this.currentIndex,
    super.key,
  });

  final int count;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return SmartRow(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 8.w,
      children: List.generate(count, (index) {
        final isActive = index == currentIndex;
        // Smart widget fallback: animated dot width transition needs AnimatedContainer.
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: isActive ? 24.w : 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: isActive ? AppColors.accent : AppColors.border,
            borderRadius: BorderRadius.circular(100.r),
          ),
        );
      }),
    );
  }
}
