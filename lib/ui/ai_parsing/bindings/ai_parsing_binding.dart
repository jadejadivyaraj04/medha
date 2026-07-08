// lib/ui/ai_parsing/bindings/ai_parsing_binding.dart

import 'package:get/get.dart';

import '../../../core/scan/scan_flow_binding.dart';
import '../controller/ai_parsing_controller.dart';

class AiParsingBinding extends Bindings {
  @override
  void dependencies() {
    ensureScanSession();
    Get.lazyPut(AiParsingController.new);
  }
}
