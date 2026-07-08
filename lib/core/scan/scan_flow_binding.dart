// lib/core/scan/scan_flow_binding.dart

import 'package:get/get.dart';

import 'scan_session_service.dart';

void ensureScanSession() {
  if (!Get.isRegistered<ScanSessionService>()) {
    Get.put(ScanSessionService());
  }
}
