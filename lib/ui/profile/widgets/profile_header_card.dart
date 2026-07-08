// lib/ui/profile/widgets/profile_header_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/profile_model.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    required this.profile,
    required this.onSwitchTap,
    required this.onSpeakTap,
    super.key,
  });

  final ProfileModel profile;
  final VoidCallback onSwitchTap;
  final VoidCallback onSpeakTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A000000),
            blurRadius: 16.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SmartColumn(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accentLight.withValues(alpha: 0.65),
                  AppColors.surfaceElevated,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: SmartColumn(
              spacing: 14.h,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _ProfileAvatar(profile: profile),
                SmartText(
                  profile.name,
                  style: AppTextStyles.heading1,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                _MetaChipRow(profile: profile),
              ],
            ),
          ),
          SmartColumn(
            padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
            spacing: 10.h,
            children: [
              SmartButton(
                title: 'scan.sambhdo'.tr,
                onTap: onSpeakTap,
                height: 52.h,
                activeBackgroundColor: AppColors.accentLight,
                borderRadius: BorderRadius.circular(14.r),
                titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
              SmartButton(
                title: 'profile.switch_patient'.tr,
                onTap: onSwitchTap,
                height: 52.h,
                activeBackgroundColor: AppColors.surface,
                borderRadius: BorderRadius.circular(14.r),
                borderColor: AppColors.accent,
                titleStyle: AppTextStyles.label.copyWith(color: AppColors.accent),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaChipRow extends StatelessWidget {
  const _MetaChipRow({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final chips = <Widget>[
      _InfoChip(
        icon: Icons.translate_rounded,
        label: _languageLabel(profile.localeCode),
      ),
      if (profile.age > 0)
        _InfoChip(
          icon: Icons.cake_rounded,
          label: 'profile.age_label'.trParams({'age': '${profile.age}'}),
        ),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8.w,
      runSpacing: 8.h,
      children: chips,
    );
  }

  String _languageLabel(String code) {
    return switch (code) {
      'gu' => 'profile.language_gu'.tr,
      'hi' => 'profile.language_hi'.tr,
      _ => 'profile.language_en'.tr,
    };
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.border),
      ),
      child: SmartRow(
        spacing: 6.w,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: AppColors.accent),
          SmartText(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final ProfileModel profile;

  @override
  Widget build(BuildContext context) {
    final hasAvatar =
        profile.avatarUrl != null && profile.avatarUrl!.trim().isNotEmpty;
    final initials = _initials(profile.name);
    final avatarSize = 96.w;

    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Container(
          width: avatarSize,
          height: avatarSize,
          padding: EdgeInsets.all(3.5.w),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.accentBrand,
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withValues(alpha: 0.18),
                blurRadius: 20.r,
                offset: Offset(0, 6.h),
              ),
            ],
          ),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceElevated,
            ),
            clipBehavior: Clip.antiAlias,
            child: hasAvatar
                ? SmartImage(
                    path: profile.avatarUrl!,
                    width: avatarSize - 7.w,
                    height: avatarSize - 7.w,
                    fit: BoxFit.cover,
                  )
                : Center(
                    child: initials.isNotEmpty
                        ? SmartText(
                            initials,
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.accent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Icon(
                            Icons.person_rounded,
                            size: 40.r,
                            color: AppColors.accent,
                          ),
                  ),
          ),
        ),
        Positioned(
          bottom: -2.h,
          child: _ActiveBadge(),
        ),
      ],
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) {
      return '';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'
        .toUpperCase();
  }
}

class _ActiveBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
      decoration: BoxDecoration(
        gradient: AppGradients.accentBrand,
        borderRadius: BorderRadius.circular(100.r),
        border: Border.all(color: AppColors.surfaceElevated, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: SmartRow(
        spacing: 5.w,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14.r,
            color: Colors.white,
          ),
          SmartText(
            'profile.active_short'.tr,
            style: AppTextStyles.caption.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
