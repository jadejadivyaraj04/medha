// lib/ui/shell/bindings/main_shell_binding.dart

import 'package:get/get.dart';

import '../../home/bindings/home_binding.dart';
import '../../medicines/bindings/medicines_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../reminders/bindings/reminders_binding.dart';
import '../controller/shell_controller.dart';

class MainShellBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ShellController>()) {
      Get.put(ShellController(), permanent: true);
    }
    MedicinesBinding().dependencies();
    HomeBinding().dependencies();
    RemindersBinding().dependencies();
    ProfileBinding().dependencies();
    Get.find<ShellController>().syncIndexFromRoute(Get.currentRoute);
  }
}
