// lib/ui/interactions/bindings/interaction_alert_binding.dart

import 'package:get/get.dart';

import '../controller/interaction_alert_controller.dart';

class InteractionAlertBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(InteractionAlertController.new);
  }
}
