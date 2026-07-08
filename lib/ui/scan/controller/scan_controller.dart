// lib/ui/scan/controller/scan_controller.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes.dart';
import '../../../core/permissions/permission_service.dart';
import '../../../core/scan/prescription_camera_service.dart';
import '../../../core/scan/scan_session_service.dart';
import '../../../ui/onboarding/permissions/model/onboarding_permission.dart';

class ScanController extends GetxController {
  ScanController({
    ImagePicker? picker,
    PrescriptionCameraService? cameraService,
  })  : _picker = picker ?? ImagePicker(),
        _cameraService = cameraService ?? PrescriptionCameraService();

  final isLoading = false.obs;
  final flashOn = false.obs;
  final previewPath = RxnString();
  final errorMessage = ''.obs;
  final isCameraReady = false.obs;
  final isCameraInitializing = false.obs;

  final ImagePicker _picker;
  final PrescriptionCameraService _cameraService;
  final _session = Get.find<ScanSessionService>();

  String get cameraInitError => _cameraService.initError.value;
  CameraController? get cameraController => _cameraService.controller;

  @override
  void onInit() {
    super.onInit();
    _session.clear();
    ever(_cameraService.isInitialized, (ready) {
      isCameraReady.value = ready;
    });
    ever(_cameraService.isInitializing, (loading) {
      isCameraInitializing.value = loading;
    });
  }

  @override
  void onReady() {
    super.onReady();
    if (previewPath.value == null) {
      _initCamera();
    }
  }

  @override
  void onClose() {
    _cameraService.disposeCamera();
    super.onClose();
  }

  Future<void> _initCamera() async {
    errorMessage.value = '';

    if (!await PermissionService.isGranted(OnboardingPermission.camera)) {
      final granted = await PermissionService.request(OnboardingPermission.camera);
      if (!granted) {
        errorMessage.value = 'scan.error_permission'.tr;
        return;
      }
    }

    await _cameraService.initialize();
    if (_cameraService.initError.value.isNotEmpty) {
      errorMessage.value = _cameraService.initError.value;
    }
  }

  Future<void> toggleFlash() async {
    flashOn.value = !flashOn.value;
    await _cameraService.setTorch(flashOn.value);
  }

  Future<void> captureFromCamera() async {
    if (isLoading.value) {
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    if (!_cameraService.isInitialized.value) {
      await _initCamera();
      // Keep the specific permission/init error instead of overwriting it
      // with a generic capture failure below.
      if (!_cameraService.isInitialized.value) {
        isLoading.value = false;
        return;
      }
    }

    final path = await _cameraService.captureToFile();
    if (path == null) {
      errorMessage.value = 'scan.error_capture'.tr;
      isLoading.value = false;
      return;
    }

    try {
      final bytes = await File(path).readAsBytes();
      _storeImage(bytes: bytes, path: path);
      previewPath.value = path;
      flashOn.value = false;
      await _cameraService.disposeCamera();
    } catch (e) {
      errorMessage.value = 'scan.error_capture'.tr;
    }

    isLoading.value = false;
  }

  Future<void> pickFromGallery() async {
    await _pickImage(ImageSource.gallery);
  }

  Future<void> retakePhoto() async {
    previewPath.value = null;
    _session.clear();
    flashOn.value = false;
    errorMessage.value = '';
    await _cameraService.disposeCamera();
    await _initCamera();
  }

  Future<void> _pickImage(ImageSource source) async {
    isLoading.value = true;
    errorMessage.value = '';

    final permission = source == ImageSource.camera
        ? OnboardingPermission.camera
        : OnboardingPermission.photos;

    if (!await PermissionService.isGranted(permission)) {
      final granted = await PermissionService.request(permission);
      if (!granted) {
        errorMessage.value = 'scan.error_permission'.tr;
        isLoading.value = false;
        return;
      }
    }

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 2048,
      );
      if (file == null) {
        isLoading.value = false;
        return;
      }

      final bytes = await file.readAsBytes();
      _storeImage(bytes: bytes, path: file.path);
      previewPath.value = file.path;
      flashOn.value = false;
      await _cameraService.disposeCamera();
    } catch (e) {
      errorMessage.value = 'scan.error_capture'.tr;
    }

    isLoading.value = false;
  }

  void startParsing() {
    if (!_session.hasImage) {
      errorMessage.value = 'scan.error_no_image'.tr;
      return;
    }
    Get.toNamed(Routes.AI_PARSING);
  }

  void _storeImage({required Uint8List bytes, String? path}) {
    _session.setImage(bytes: bytes, path: path);
  }
}
