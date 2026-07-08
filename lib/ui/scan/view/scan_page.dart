// lib/ui/scan/view/scan_page.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:smart_dev_widgets/smart_dev_widgets.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_gradients.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/scan_controller.dart';

class ScanPage extends GetView<ScanController> {
  const ScanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AppColors.primary,
      appBar: SmartAppBar(
        title: 'scan.title'.tr,
        isBack: true,
        onBack: () => Get.back<void>(),
        backgroundColor: AppColors.surfaceElevated,
      ),
      body: Obx(() {
        final hasPreview = controller.previewPath.value != null;

        return SmartColumn(
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _PreviewArea(controller: controller),
                  if (!hasPreview) const _FrameOverlay(),
                  if (controller.isLoading.value || controller.isCameraInitializing.value)
                    Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: const SmartCircularProgressIndicator(),
                    ),
                ],
              ),
            ),
            SmartColumn(
              color: AppColors.background,
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, bottomInset + 16.h),
              spacing: 12.h,
              children: [
                SmartText(
                  hasPreview ? 'scan.preview_hint'.tr : 'scan.guidance'.tr,
                  style: AppTextStyles.body2,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: AppColors.accentLight,
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                  child: SmartText(
                    'home.offline_badge'.tr,
                    style: AppTextStyles.label.copyWith(color: AppColors.accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (controller.errorMessage.value.isNotEmpty)
                  SmartText(
                    controller.errorMessage.value,
                    style: AppTextStyles.caption.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                if (!hasPreview) ...[
                  SmartRow(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _RoundIconButton(
                        icon: Icons.photo_library_rounded,
                        label: 'scan.gallery'.tr,
                        onTap: controller.isLoading.value
                            ? () {}
                            : controller.pickFromGallery,
                      ),
                      _CaptureButton(
                        onTap: controller.isLoading.value
                            ? () {}
                            : controller.captureFromCamera,
                      ),
                      _RoundIconButton(
                        icon: controller.flashOn.value
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        label: 'scan.flash'.tr,
                        onTap: controller.isLoading.value
                            ? () {}
                            : controller.toggleFlash,
                      ),
                    ],
                  ),
                ] else ...[
                  SmartButton(
                    title: 'scan.use_photo'.tr,
                    onTap: controller.startParsing,
                    activeBackgroundColor: AppColors.accent,
                  ),
                  SmartButton(
                    title: 'scan.retake'.tr,
                    onTap: controller.isLoading.value ? () {} : controller.retakePhoto,
                    activeBackgroundColor: AppColors.surface,
                    titleStyle: AppTextStyles.button.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        );
      }),
    );
  }
}

class _PreviewArea extends StatelessWidget {
  const _PreviewArea({required this.controller});

  final ScanController controller;

  @override
  Widget build(BuildContext context) {
    final previewPath = controller.previewPath.value;

    if (previewPath != null) {
      return SmartImage(
        path: previewPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }

    if (controller.isCameraReady.value && controller.cameraController != null) {
      return _LiveCameraPreview(controller: controller.cameraController!);
    }

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: AppColors.primary,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SmartColumn(
        spacing: 12.h,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_camera_rounded,
            size: 48.r,
            color: AppColors.textHint,
          ),
          SmartText(
            controller.cameraInitError.isNotEmpty
                ? controller.cameraInitError
                : 'scan.camera_loading'.tr,
            style: AppTextStyles.body2.copyWith(color: AppColors.textHint),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _LiveCameraPreview extends StatelessWidget {
  const _LiveCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    // Smart widget fallback: live camera preview requires CameraPreview from camera package.
    return ClipRect(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller.value.previewSize?.height ?? 1,
          height: controller.value.previewSize?.width ?? 1,
          child: CameraPreview(controller),
        ),
      ),
    );
  }
}

class _FrameOverlay extends StatelessWidget {
  const _FrameOverlay();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 2),
          borderRadius: BorderRadius.circular(16.r),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  const _CaptureButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72.w,
        height: 72.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppGradients.accentBrand,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withValues(alpha: 0.35),
              blurRadius: 16.r,
              offset: Offset(0, 6.h),
            ),
          ],
        ),
        child: Icon(Icons.document_scanner_rounded, color: Colors.white, size: 30.r),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SmartColumn(
      spacing: 6.h,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Smart widget fallback: circular icon-only control needs custom tap target.
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.textPrimary, size: 22.r),
          ),
        ),
        SmartText(
          label,
          style: AppTextStyles.caption,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
