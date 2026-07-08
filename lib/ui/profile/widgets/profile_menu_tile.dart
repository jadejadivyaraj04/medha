// lib/ui/profile/widgets/profile_menu_tile.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmartRow(
      onTap: onTap,
      isInkwell: true,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      spacing: 12.w,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: AppColors.accentLight,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: AppColors.accent, size: 20.r),
        ),
        Expanded(
          child: SmartColumn(
            spacing: 4.h,
            children: [
              SmartText(
                title,
                style: AppTextStyles.heading3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SmartText(
                subtitle,
                style: AppTextStyles.caption,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14.r,
          color: AppColors.textHint,
        ),
      ],
    );
  }
}
