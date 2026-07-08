// lib/core/permissions/permission_service.dart

import 'package:permission_handler/permission_handler.dart';

import '../../ui/onboarding/permissions/model/onboarding_permission.dart';
import '../storage/storage_manager.dart';

class PermissionService {
  PermissionService._();

  static Permission _handler(OnboardingPermission type) {
    return switch (type) {
      OnboardingPermission.camera => Permission.camera,
      OnboardingPermission.notifications => Permission.notification,
      OnboardingPermission.photos => Permission.photos,
      OnboardingPermission.microphone => Permission.microphone,
    };
  }

  static bool _isEffectivelyGranted(PermissionStatus status) {
    return status.isGranted || status.isLimited;
  }

  static String _statusFromPermission(PermissionStatus status) {
    if (_isEffectivelyGranted(status)) {
      return 'granted';
    }
    if (status.isPermanentlyDenied) {
      return 'denied';
    }
    if (status.isDenied) {
      return 'denied';
    }
    return 'pending';
  }

  static Future<bool> isGranted(OnboardingPermission type) async {
    final status = await _handler(type).status;
    return _isEffectivelyGranted(status);
  }

  static Future<bool> isPermanentlyDenied(OnboardingPermission type) async {
    final status = await _handler(type).status;
    return status.isPermanentlyDenied;
  }

  /// Reads live OS permission state and merges with locally stored skip flags.
  static Future<Map<String, String>> syncAllStatuses() async {
    final stored = StorageManager.getPermissionStatuses();
    final result = <String, String>{};

    for (final type in OnboardingPermission.slideOrder) {
      final osStatus = await _handler(type).status;
      if (_isEffectivelyGranted(osStatus)) {
        result[type.id] = 'granted';
        await StorageManager.savePermissionStatus(type.id, 'granted');
        continue;
      }

      if (stored[type.id] == 'skipped') {
        result[type.id] = 'skipped';
        continue;
      }

      final mapped = _statusFromPermission(osStatus);
      result[type.id] = mapped == 'pending' ? (stored[type.id] ?? 'pending') : mapped;
      if (mapped != 'pending') {
        await StorageManager.savePermissionStatus(type.id, mapped);
      }
    }

    return result;
  }

  static Future<bool> request(OnboardingPermission type) async {
    final permission = _handler(type);
    var status = await permission.status;

    if (status.isPermanentlyDenied) {
      await openAppSettings();
      status = await permission.status;
    } else if (!_isEffectivelyGranted(status)) {
      status = await permission.request();
    }

    final granted = _isEffectivelyGranted(status);
    final storedStatus = granted
        ? 'granted'
        : status.isPermanentlyDenied || status.isDenied
            ? 'denied'
            : 'pending';
    await StorageManager.savePermissionStatus(type.id, storedStatus);
    return granted;
  }

  static Future<void> markSkipped(OnboardingPermission type) async {
    final granted = await isGranted(type);
    if (granted) {
      await StorageManager.savePermissionStatus(type.id, 'granted');
      return;
    }
    await StorageManager.savePermissionStatus(type.id, 'skipped');
  }

  static Future<void> openSettings() => openAppSettings();
}
