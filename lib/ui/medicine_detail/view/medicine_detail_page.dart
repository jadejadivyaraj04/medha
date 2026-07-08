// lib/ui/medicine_detail/view/medicine_detail_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/medicine_text_helper.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/app_error_widget.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../../interactions/widgets/danger_interaction_acknowledgement_overlay.dart';
import '../../interactions/widgets/danger_interaction_alert_card.dart';
import '../../interactions/widgets/food_rules_section.dart';
import '../../interactions/widgets/interaction_list_section.dart';
import '../../interactions/widgets/side_effects_section.dart';
import '../../doubt_query/widgets/voice_doubt_panel.dart';
import '../widgets/generic_alternative_section.dart';
import '../widgets/prescription_compare_section.dart';
import '../controller/medicine_detail_controller.dart';

class MedicineDetailPage extends GetView<MedicineDetailController> {
  const MedicineDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: SmartAppBar(
          title: controller.medicine.value?.name ?? 'medicines.detail_title'.tr,
          isBack: !controller.showDangerOverlay.value,
          onBack: controller.showDangerOverlay.value
              ? null
              : () => Get.back<void>(),
          actions: [
            Obx(
              () => VoiceMicButton(
                isRecording: controller.voiceDoubt.isRecording,
                isBusy: controller.voiceDoubt.isBusy,
                onTap: controller.voiceDoubt.toggleRecording,
              ),
            ),
            SambhdoButton(onTap: controller.speakMedicine),
          ],
        ),
        body: _buildBody(context),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    if (controller.isLoading.value) {
      return const Center(child: SmartCircularProgressIndicator());
    }

    if (controller.errorMessage.value.isNotEmpty) {
      return AppErrorWidget(
        message: controller.errorMessage.value,
        onRetry: controller.load,
      );
    }

    final medicine = controller.medicine.value;
    if (medicine == null) {
      return AppErrorWidget(
        message: 'medicines.error_not_found'.tr,
        onRetry: controller.load,
      );
    }

    return Stack(
      children: [
        SmartColumn(
          children: [
            Expanded(
              child: SmartSingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                child: SmartColumn(
                  spacing: 16.h,
                  children: [
                    const AiDisclaimerBanner(),
                    VoiceDoubtPanel(
                      delegate: controller.voiceDoubt,
                      showHero: false,
                      compact: true,
                    ),
                    Obx(() {
                      if (!controller.hasDanger || !controller.dangerAcknowledged.value) {
                        return const SizedBox.shrink();
                      }
                      return SmartColumn(
                        spacing: 12.h,
                        children: controller.dangerInteractions
                            .map(
                              (item) => DangerInteractionAlertCard(
                                interaction: item,
                                showDoctorCta: true,
                                onCallDoctor: controller.callDoctor,
                              ),
                            )
                            .toList(),
                      );
                    }),
                    Obx(
                      () => InteractionListSection(
                        interactions: controller.interactions.toList(),
                        isLoading: controller.isLoadingInteractions.value,
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20.w),
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
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: AppColors.accentLight,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              size: 28.r,
                              color: AppColors.accent,
                            ),
                          ),
                          SmartText(
                            medicine.name,
                            style: AppTextStyles.heading1,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SmartText(
                            MedicineTextHelper.doseLabel(medicine),
                            style: AppTextStyles.body1,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Obx(
                            () => _StatusBadge(
                              status: controller.displayStatus(medicine),
                              showDanger: controller.hasDanger,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _InfoRow(
                      icon: Icons.schedule_rounded,
                      label: 'medicines.detail.frequency'.tr,
                      value: MedicineTextHelper.frequencyLabel(medicine.frequency),
                    ),
                    _InfoRow(
                      icon: Icons.restaurant_rounded,
                      label: 'medicines.detail.food'.tr,
                      value: MedicineTextHelper.foodLabel(medicine.withFood),
                    ),
                    _InfoRow(
                      icon: Icons.calendar_today_rounded,
                      label: 'medicines.detail.duration'.tr,
                      value: controller.labelFor(
                        'durationDays',
                        '${medicine.durationDays}',
                      ),
                    ),
                    _InfoRow(
                      icon: Icons.repeat_rounded,
                      label: 'medicines.detail.schedule'.tr,
                      value: MedicineTextHelper.timingLine(medicine),
                    ),
                    Obx(
                      () => FoodRulesSection(
                        foodRules: controller.foodRules.toList(),
                        isLoading: controller.isLoadingRagInsights.value,
                        onSpeak: controller.speakFoodRules,
                      ),
                    ),
                    Obx(
                      () => SideEffectsSection(
                        sideEffects: controller.sideEffects.value,
                        isLoading: controller.isLoadingRagInsights.value,
                        onSpeak: controller.speakSideEffects,
                      ),
                    ),
                    Obx(
                      () => GenericAlternativeSection(
                        alternative: controller.genericAlternative.value,
                        isLoading: controller.isLoadingRagInsights.value,
                        onSpeak: controller.speakGenericAlternatives,
                      ),
                    ),
                    const PrescriptionCompareSection(),
                  ],
                ),
              ),
            ),
            SmartColumn(
              padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, bottomInset + 16.h),
              spacing: 12.h,
              children: [
                if (medicine.isActive) ...[
                  SmartButton(
                    title: 'medicines.mark_taken'.tr,
                    onTap: controller.markTaken,
                    activeBackgroundColor: AppColors.success,
                  ),
                  SmartButton(
                    title: 'medicines.mark_completed'.tr,
                    isLoading: controller.isSaving.value,
                    onTap: () => controller.markCompleted(),
                    isEnabled: !controller.isSaving.value,
                    activeBackgroundColor: AppColors.accentLight,
                    titleStyle:
                        AppTextStyles.button.copyWith(color: AppColors.accent),
                  ),
                ],
              ],
            ),
          ],
        ),
        Obx(() {
          if (!controller.showDangerOverlay.value) {
            return const SizedBox.shrink();
          }
          return Positioned.fill(
            child: DangerInteractionAcknowledgementOverlay(
              interactions: controller.dangerInteractions,
              onAcknowledge: controller.acknowledgeDanger,
              onCallDoctor: controller.callDoctor,
              onSpeak: controller.speakDangerAlert,
            ),
          );
        }),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.status,
    this.showDanger = false,
  });

  final String status;
  final bool showDanger;

  @override
  Widget build(BuildContext context) {
    if (showDanger) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: AppColors.errorLight,
          borderRadius: BorderRadius.circular(100.r),
        ),
        child: SmartText(
          'interactions.danger_badge'.tr,
          style: AppTextStyles.label.copyWith(color: AppColors.error),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }

    final color = switch (status) {
      'completed' => AppColors.success,
      'refill_due' => AppColors.warning,
      _ => AppColors.accent,
    };
    final bg = switch (status) {
      'completed' => AppColors.successLight,
      'refill_due' => AppColors.warningLight,
      _ => AppColors.accentLight,
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: SmartText(
        MedicineTextHelper.statusLabel(status),
        style: AppTextStyles.label.copyWith(color: color),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

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
      child: SmartRow(
        spacing: 12.w,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.accentLight,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 18.r, color: AppColors.accent),
          ),
          Expanded(
            child: SmartColumn(
              spacing: 4.h,
              children: [
                SmartText(
                  label,
                  style: AppTextStyles.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SmartText(
                  value,
                  style: AppTextStyles.body1,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
