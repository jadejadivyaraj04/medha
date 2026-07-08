// lib/ui/verify_edit/view/verify_edit_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/ai/tts_service.dart';
import '../../../core/mock/mock_image_urls.dart';
import '../../../core/scan/scan_session_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ai_disclaimer_banner.dart';
import '../../../core/widgets/sambhdo_button.dart';
import '../../interactions/widgets/danger_interaction_acknowledgement_overlay.dart';
import '../controller/verify_edit_controller.dart';
import '../widgets/medicine_edit_row.dart';

class VerifyEditPage extends GetView<VerifyEditController> {
  const VerifyEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;
    final session = Get.find<ScanSessionService>();

    return Obx(
      () => Scaffold(
        backgroundColor: AppColors.background,
        appBar: SmartAppBar(
          title: 'scan.verify.title'.tr,
          isBack: !controller.showDangerOverlay.value,
          onBack: controller.showDangerOverlay.value
              ? null
              : () => Get.back<void>(),
          actions: [
            SambhdoButton(
              onTap: () {
                final names = controller.medicines
                    .map((m) =>
                        controller.controllersFor(m.id)?.nameCtrl.text ?? m.name)
                    .where((name) => name.trim().isNotEmpty)
                    .join(', ');
                Get.find<TtsService>().speak(names);
              },
            ),
          ],
        ),
        body: _buildBody(context, bottomInset, session),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    double bottomInset,
    ScanSessionService session,
  ) {
    return Stack(
          children: [
            SmartColumn(
              children: [
                Expanded(
                  child: SmartSingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + bottomInset),
                    child: SmartColumn(
                      spacing: 16.h,
                      children: [
                        const AiDisclaimerBanner(),
                        _PrescriptionThumbnail(sessionPath: session.imagePath),
                        if (controller.isEmptyState.value)
                          SmartColumn(
                            spacing: 12.h,
                            children: [
                              SmartText(
                                'scan.verify.empty_title'.tr,
                                style: AppTextStyles.heading3,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SmartText(
                                'scan.verify.empty_body'.tr,
                                style: AppTextStyles.body2,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ...controller.medicines.map(
                          (medicine) => MedicineEditRow(medicine: medicine),
                        ),
                        SmartButton(
                          title: 'scan.verify.add_medicine'.tr,
                          onTap: controller.addMedicine,
                          activeBackgroundColor: AppColors.accentLight,
                          titleStyle:
                              AppTextStyles.button.copyWith(color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                ),
                SmartColumn(
                  padding: EdgeInsets.fromLTRB(
                    20.w,
                    8.h,
                    20.w,
                    MediaQuery.paddingOf(context).bottom + 16.h,
                  ),
                  spacing: 8.h,
                  children: [
                    if (!controller.canConfirm)
                      SmartText(
                        'scan.verify.confirm_hint'.tr,
                        style: AppTextStyles.caption.copyWith(color: AppColors.warning),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    SmartButton(
                      title: 'scan.verify.confirm'.tr,
                      onTap: controller.confirmAndContinue,
                      isLoading: controller.isCheckingInteractions.value,
                      isEnabled: controller.canConfirm,
                      activeBackgroundColor: AppColors.accent,
                      disableBackgroundColor: AppColors.border,
                    ),
                  ],
                ),
              ],
            ),
            if (controller.showDangerOverlay.value)
              Positioned.fill(
                child: DangerInteractionAcknowledgementOverlay(
                  interactions: controller.dangerInteractions.toList(),
                  onAcknowledge: controller.acknowledgeDangerAndContinue,
                  onCallDoctor: controller.callDoctor,
                  onSpeak: controller.speakDangerAlert,
                ),
              ),
          ],
        );
  }
}

class _PrescriptionThumbnail extends StatelessWidget {
  const _PrescriptionThumbnail({required this.sessionPath});

  final String? sessionPath;

  @override
  Widget build(BuildContext context) {
    final path = sessionPath;
    return SmartRow(
      spacing: 12.w,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: SmartImage(
            path: path != null && path != 'demo' ? path : MockImageUrls.content(0),
            width: 88.w,
            height: 112.h,
            fit: BoxFit.cover,
          ),
        ),
        Expanded(
          child: SmartText(
            'scan.verify.thumbnail_hint'.tr,
            style: AppTextStyles.body2,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
