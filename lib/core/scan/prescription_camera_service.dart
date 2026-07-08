// lib/core/scan/prescription_camera_service.dart

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Manages the back-camera preview used on the prescription scan screen.
class PrescriptionCameraService extends GetxService {
  CameraController? _controller;

  final isInitialized = false.obs;
  final isInitializing = false.obs;
  final initError = ''.obs;

  CameraController? get controller => _controller;

  Future<void> initialize() async {
    if (isInitializing.value || isInitialized.value) {
      return;
    }

    isInitializing.value = true;
    initError.value = '';

    try {
      await disposeCamera();

      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        initError.value = 'scan.camera_unavailable'.tr;
        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final cameraController = CameraController(
        backCamera,
        ResolutionPreset.veryHigh,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await cameraController.initialize();
      await cameraController.setFocusMode(FocusMode.auto);
      await cameraController.setExposureMode(ExposureMode.auto);

      _controller = cameraController;
      isInitialized.value = true;
    } catch (e) {
      initError.value = 'scan.camera_unavailable'.tr;
      await disposeCamera();
    } finally {
      isInitializing.value = false;
    }
  }

  Future<String?> captureToFile() async {
    final camera = _controller;
    if (camera == null || !camera.value.isInitialized) {
      return null;
    }

    if (camera.value.isTakingPicture) {
      return null;
    }

    try {
      final file = await camera.takePicture();
      return file.path;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('PrescriptionCameraService.captureToFile failed: $e');
      }
      return null;
    }
  }

  Future<void> setTorch(bool enabled) async {
    final camera = _controller;
    if (camera == null || !camera.value.isInitialized) {
      return;
    }

    if (camera.description.lensDirection != CameraLensDirection.back) {
      return;
    }

    try {
      await camera.setFlashMode(enabled ? FlashMode.torch : FlashMode.off);
    } catch (_) {
      // Torch not supported on this device / simulator.
    }
  }

  Future<void> disposeCamera() async {
    isInitialized.value = false;
    final camera = _controller;
    _controller = null;
    if (camera != null) {
      await camera.dispose();
    }
  }
}
