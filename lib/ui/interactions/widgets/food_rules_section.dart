// lib/ui/interactions/widgets/food_rules_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/models/food_rule_model.dart';
import '../../../core/models/interaction_severity.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/sambhdo_button.dart';

class FoodRulesSection extends StatelessWidget {
  const FoodRulesSection({
    required this.foodRules,
    required this.isLoading,
    this.onSpeak,
    super.key,
  });

  final List<FoodRuleModel> foodRules;
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
                  'interactions.food_rules_title'.tr,
                  style: AppTextStyles.heading3,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (foodRules.isNotEmpty && onSpeak != null)
                SambhdoButton(onTap: onSpeak!),
            ],
          ),
          if (foodRules.isEmpty)
            SmartText(
              'interactions.no_food_rules'.tr,
              style: AppTextStyles.body2,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            )
          else
            ...foodRules.map((rule) => _FoodRuleRow(rule: rule)),
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

class _FoodRuleRow extends StatelessWidget {
  const _FoodRuleRow({required this.rule});

  final FoodRuleModel rule;

  @override
  Widget build(BuildContext context) {
    final severityColor = switch (rule.severity) {
      InteractionSeverity.major ||
      InteractionSeverity.contraindicated =>
        AppColors.warning,
      _ => AppColors.accent,
    };

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: SmartColumn(
        spacing: 6.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SmartRow(
            spacing: 10.w,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.restaurant_rounded, size: 18.r, color: severityColor),
              Expanded(
                child: SmartColumn(
                  spacing: 4.h,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SmartText(
                      FoodRuleLabels.label(rule.rule),
                      style: AppTextStyles.label.copyWith(color: severityColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SmartText(
                      rule.message,
                      style: AppTextStyles.body2,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (rule.source.trim().isNotEmpty)
            SmartText(
              'interactions.source_label'.trParams({'source': rule.source}),
              style: AppTextStyles.caption,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}

class FoodRuleLabels {
  FoodRuleLabels._();

  static String label(String rule) {
    return switch (rule) {
      'before_food' => 'interactions.food_rule.before_food'.tr,
      'after_food' => 'interactions.food_rule.after_food'.tr,
      'empty_stomach' => 'interactions.food_rule.empty_stomach'.tr,
      'evening' => 'interactions.food_rule.evening'.tr,
      'avoid_dairy' => 'interactions.food_rule.avoid_dairy'.tr,
      _ => 'interactions.food_rule.any_time'.tr,
    };
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
