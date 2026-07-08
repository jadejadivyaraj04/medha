// lib/core/scan/scan_session_service.dart

import 'dart:typed_data';

import 'package:get/get.dart';

import '../models/medicine_model.dart';

/// Holds prescription image + parsed medicines across the scan flow screens.
class ScanSessionService extends GetxService {
  Uint8List? imageBytes;
  String? imagePath;
  final medicines = <MedicineModel>[].obs;

  bool get hasImage => imageBytes != null && imageBytes!.isNotEmpty;

  void setImage({required Uint8List bytes, String? path}) {
    imageBytes = bytes;
    imagePath = path;
  }

  void setMedicines(List<MedicineModel> items) {
    medicines.assignAll(items);
  }

  void clear() {
    imageBytes = null;
    imagePath = null;
    medicines.clear();
  }
}
