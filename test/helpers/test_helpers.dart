// test/helpers/test_helpers.dart

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Grants all permission_handler checks in unit tests.
void setupPermissionHandlerMock() {
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, (MethodCall call) async {
    switch (call.method) {
      case 'checkPermissionStatus':
        return 1;
      case 'requestPermissions':
        final permissions = call.arguments as List<dynamic>;
        return {for (final permission in permissions) permission: 1};
      case 'shouldShowRequestPermissionRationale':
        return false;
      default:
        return null;
    }
  });
}

void clearPermissionHandlerMock() {
  const channel = MethodChannel('flutter.baseflow.com/permissions/methods');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(channel, null);
}
