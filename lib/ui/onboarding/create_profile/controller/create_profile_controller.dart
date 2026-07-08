// lib/ui/onboarding/create_profile/controller/create_profile_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../app/app_controller.dart';
import '../../../../app/routes.dart';
import '../../../../core/storage/storage_manager.dart';
import '../../../../data/models/profile_model.dart';
import '../../../../data/repositories/profile_repository.dart';

class CreateProfileController extends GetxController {
  CreateProfileController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;
  final _appController = Get.find<AppController>();

  final nameCtrl = TextEditingController();
  final ageCtrl = TextEditingController();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final nameError = ''.obs;

  @override
  void onClose() {
    nameCtrl.dispose();
    ageCtrl.dispose();
    super.onClose();
  }

  Future<void> saveProfile() async {
    final name = nameCtrl.text.trim();
    if (name.isEmpty) {
      nameError.value = 'onboarding.profile.name_required'.tr;
      return;
    }
    nameError.value = '';

    final age = int.tryParse(ageCtrl.text.trim()) ?? 0;
    isLoading.value = true;
    errorMessage.value = '';

    final profile = ProfileModel(
      id: 'p_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      age: age,
      localeCode: _appController.localeCode.value,
    );

    final result = await _repository.save(profile);
    result.fold(
      (error) => errorMessage.value = error.message,
      (_) async {
        final fromProfile = Get.arguments is Map &&
            (Get.arguments as Map)['fromProfile'] == true;
        if (fromProfile) {
          Get.back<void>();
          return;
        }
        await StorageManager.setOnboardingComplete(value: true);
        Get.offAllNamed(Routes.HOME);
      },
    );

    isLoading.value = false;
  }
}
