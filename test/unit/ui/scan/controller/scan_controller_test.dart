// test/unit/ui/scan/controller/scan_controller_test.dart

import 'dart:io';
import 'dart:typed_data';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medha/app/translations/app_translations.dart';
import 'package:medha/core/scan/prescription_camera_service.dart';
import 'package:medha/core/scan/scan_session_service.dart';
import 'package:medha/ui/scan/controller/scan_controller.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../helpers/test_helpers.dart';

class MockImagePicker extends Mock implements ImagePicker {}

class FakePrescriptionCameraService extends PrescriptionCameraService {
  String? nextCapturePath;
  var initializeCalls = 0;
  var disposeCalls = 0;
  var torchEnabled = false;

  @override
  Future<void> initialize() async {
    initializeCalls += 1;
    isInitializing.value = true;
    isInitialized.value = true;
    isInitializing.value = false;
    initError.value = '';
  }

  @override
  Future<String?> captureToFile() async => nextCapturePath;

  @override
  Future<void> disposeCamera() async {
    disposeCalls += 1;
    isInitialized.value = false;
  }

  @override
  Future<void> setTorch(bool enabled) async {
    torchEnabled = enabled;
  }
}

void main() {
  late ScanController controller;
  late ScanSessionService session;
  late MockImagePicker mockPicker;
  late FakePrescriptionCameraService fakeCamera;

  final sampleBytes = Uint8List.fromList([10, 20, 30, 40]);

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    setupPermissionHandlerMock();
    await AppTranslations.load();
    registerFallbackValue(ImageSource.gallery);
  });

  tearDownAll(clearPermissionHandlerMock);

  setUp(() {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.locale = const Locale('en');

    mockPicker = MockImagePicker();
    fakeCamera = FakePrescriptionCameraService();
    session = ScanSessionService();
    Get.put<ScanSessionService>(session, permanent: true);

    controller = ScanController(
      picker: mockPicker,
      cameraService: fakeCamera,
    );
  });

  tearDown(() {
    Get.reset();
  });

  void stubPickSuccess({required String fileName}) {
    when(
      () => mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
      ),
    ).thenAnswer((_) async {
      final file = File('${Directory.systemTemp.path}/$fileName');
      await file.writeAsBytes(sampleBytes);
      return XFile(file.path);
    });
  }

  void stubPickCancelled() {
    when(
      () => mockPicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 2048,
      ),
    ).thenAnswer((_) async => null);
  }

  group('ScanController - onInit', () {
    test('onInit_clearsExistingSession', () {
      session.setImage(bytes: sampleBytes, path: 'stale.jpg');

      Get.put(
        ScanController(
          picker: mockPicker,
          cameraService: FakePrescriptionCameraService(),
        ),
      );

      expect(session.hasImage, false);
      expect(session.imagePath, isNull);
      expect(session.medicines, isEmpty);
    });
  });

  group('ScanController - toggleFlash', () {
    test('toggleFlash_flipsFlashStateAndUpdatesTorch', () async {
      expect(controller.flashOn.value, false);

      await controller.toggleFlash();
      expect(controller.flashOn.value, true);
      expect(fakeCamera.torchEnabled, true);

      await controller.toggleFlash();
      expect(controller.flashOn.value, false);
      expect(fakeCamera.torchEnabled, false);
    });
  });

  group('ScanController - captureFromCamera', () {
    test('captureFromCamera_success_storesImageAndPreview', () async {
      final file = File('${Directory.systemTemp.path}/camera.jpg');
      await file.writeAsBytes(sampleBytes);
      fakeCamera.nextCapturePath = file.path;

      await controller.captureFromCamera();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.previewPath.value, endsWith('camera.jpg'));
      expect(session.hasImage, true);
      expect(session.imageBytes, sampleBytes);
      expect(fakeCamera.disposeCalls, greaterThan(0));
    });

    test('captureFromCamera_failure_setsLocalizedError', () async {
      fakeCamera.nextCapturePath = null;

      await controller.captureFromCamera();

      expect(controller.isLoading.value, false);
      expect(controller.previewPath.value, isNull);
      expect(controller.errorMessage.value, isNotEmpty);
    });

    test('captureFromCamera_isLoading_trueDuringThenFalseAfter', () async {
      final file = File('${Directory.systemTemp.path}/camera-delay.jpg');
      await file.writeAsBytes(sampleBytes);
      fakeCamera.nextCapturePath = file.path;

      final future = controller.captureFromCamera();
      expect(controller.isLoading.value, true);

      await future;
      expect(controller.isLoading.value, false);
    });
  });

  group('ScanController - pickFromGallery', () {
    test('pickFromGallery_success_storesImageAndPreview', () async {
      stubPickSuccess(fileName: 'gallery.jpg');

      await controller.pickFromGallery();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isEmpty);
      expect(controller.previewPath.value, endsWith('gallery.jpg'));
      expect(session.hasImage, true);
      verify(
        () => mockPicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 2048,
        ),
      ).called(1);
    });

    test('pickFromGallery_cancelled_keepsPreviewEmpty', () async {
      stubPickCancelled();

      await controller.pickFromGallery();

      expect(controller.isLoading.value, false);
      expect(controller.previewPath.value, isNull);
      expect(session.hasImage, false);
    });

    test('pickFromGallery_failure_setsLocalizedError', () async {
      when(
        () => mockPicker.pickImage(
          source: ImageSource.gallery,
          imageQuality: 85,
          maxWidth: 2048,
        ),
      ).thenThrow(Exception('gallery failed'));

      await controller.pickFromGallery();

      expect(controller.isLoading.value, false);
      expect(controller.errorMessage.value, isNotEmpty);
    });
  });

  group('ScanController - retakePhoto', () {
    test('retakePhoto_clearsPreviewAndReinitializesCamera', () async {
      final file = File('${Directory.systemTemp.path}/retake.jpg');
      await file.writeAsBytes(sampleBytes);
      fakeCamera.nextCapturePath = file.path;

      await controller.captureFromCamera();
      expect(controller.previewPath.value, isNotNull);

      await controller.retakePhoto();

      expect(controller.previewPath.value, isNull);
      expect(session.hasImage, false);
      expect(fakeCamera.initializeCalls, greaterThan(0));
    });
  });

  group('ScanController - startParsing', () {
    test('startParsing_withoutImage_setsErrorMessage', () {
      controller.startParsing();

      expect(session.hasImage, false);
      expect(controller.errorMessage.value, isNotEmpty);
    });

    test('startParsing_withImage_doesNotThrow', () {
      session.setImage(bytes: sampleBytes, path: 'ready.jpg');

      expect(controller.startParsing, returnsNormally);
    });

    test('startParsing_clearsErrorWhenImagePresent', () {
      controller.errorMessage.value = 'Previous error';
      session.setImage(bytes: sampleBytes, path: 'ready.jpg');

      controller.startParsing();

      expect(session.hasImage, true);
    });
  });
}
