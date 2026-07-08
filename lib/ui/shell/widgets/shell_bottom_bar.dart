// lib/ui/shell/widgets/shell_bottom_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/shell_controller.dart';

class ShellBottomBar extends GetView<ShellController> {
  const ShellBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selectedIndex = controller.currentIndex.value;

      // Smart widget fallback: no SmartBottomNavigationBar / BottomAppBar wrapper.
      return BottomAppBar(
        height: 68.h,
        color: AppColors.surfaceElevated,
        elevation: 0,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.w,
        child: SmartRow(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: _ShellNavItem(
                icon: Icons.home_rounded,
                label: 'home.tab'.tr,
                isSelected: selectedIndex == 0,
                onTap: () => controller.selectTab(0),
              ),
            ),
            Expanded(
              child: _ShellNavItem(
                icon: Icons.medication_rounded,
                label: 'medicines.tab'.tr,
                isSelected: selectedIndex == 1,
                onTap: () => controller.selectTab(1),
              ),
            ),
            SizedBox(width: 52.w),
            Expanded(
              child: _ShellNavItem(
                icon: Icons.notifications_active_rounded,
                label: 'reminders.tab'.tr,
                isSelected: selectedIndex == 2,
                onTap: () => controller.selectTab(2),
              ),
            ),
            Expanded(
              child: _ShellNavItem(
                icon: Icons.person_rounded,
                label: 'profile.tab'.tr,
                isSelected: selectedIndex == 3,
                onTap: () => controller.selectTab(3),
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _ShellNavItem extends StatelessWidget {
  const _ShellNavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.accent : AppColors.textHint;

    return SmartColumn(
      onTap: onTap,
      isInkwell: true,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      width: double.infinity,
      spacing: 4.h,
      children: [
        AnimatedScale(
          scale: isSelected ? 1.1 : 1.0,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
          child: Icon(icon, size: 22.r, color: color),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: SmartText(
              label,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ],
    );
  }
}
