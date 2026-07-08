// lib/ui/caregiver/controller/caregiver_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../core/interactions/interaction_helper.dart';
import '../../../data/models/caregiver_model.dart';
import '../../../data/repositories/caregiver_repository.dart';
import '../../../data/repositories/profile_repository.dart';

class CaregiverController extends GetxController {
  CaregiverController({
    required CaregiverRepository caregiverRepository,
    required ProfileRepository profileRepository,
    TtsService? tts,
  })  : _caregiverRepository = caregiverRepository,
        _profileRepository = profileRepository,
        _tts = tts ?? Get.find<TtsService>();

  final CaregiverRepository _caregiverRepository;
  final ProfileRepository _profileRepository;
  final TtsService _tts;

  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();

  final isLoading = false.obs;
  final isSaving = false.obs;
  final isRemoving = false.obs;
  final errorMessage = ''.obs;
  final nameError = ''.obs;
  final phoneError = ''.obs;
  final relationship = 'son'.obs;
  final shareAdherence = false.obs;
  final profileId = ''.obs;
  final savedCaregiver = Rxn<CaregiverModel>();

  static const relationshipOptions = ['son', 'daughter', 'spouse', 'other'];

  bool get hasSavedCaregiver => savedCaregiver.value?.hasContact == true;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  @override
  void onClose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    super.onClose();
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final activeResult = await _profileRepository.getActive();
    await activeResult.fold(
      (error) async {
        errorMessage.value = error.message;
      },
      (profile) async {
        if (profile == null) {
          errorMessage.value = 'caregiver.error_no_profile'.tr;
          return;
        }
        profileId.value = profile.id;
        final caregiverResult =
            await _caregiverRepository.getForProfile(profile.id);
        caregiverResult.fold(
          (error) => errorMessage.value = error.message,
          (caregiver) {
            savedCaregiver.value = caregiver;
            if (caregiver != null) {
              nameCtrl.text = caregiver.name;
              phoneCtrl.text = caregiver.phone;
              relationship.value = caregiver.relationship;
              shareAdherence.value = caregiver.shareAdherence;
            }
          },
        );
      },
    );

    isLoading.value = false;
  }

  void selectRelationship(String value) {
    relationship.value = value;
  }

  void toggleShareAdherence(bool value) {
    shareAdherence.value = value;
  }

  String relationshipLabel(String code) {
    return 'caregiver.relationship.$code'.tr;
  }

  Future<void> save() async {
    final name = nameCtrl.text.trim();
    final phone = phoneCtrl.text.trim();
    nameError.value = '';
    phoneError.value = '';

    if (name.isEmpty) {
      nameError.value = 'caregiver.error_name_required'.tr;
      return;
    }
    if (phone.length < 10) {
      phoneError.value = 'caregiver.error_phone_invalid'.tr;
      return;
    }
    if (profileId.value.isEmpty) {
      errorMessage.value = 'caregiver.error_no_profile'.tr;
      return;
    }

    isSaving.value = true;
    errorMessage.value = '';

    final caregiver = CaregiverModel(
      profileId: profileId.value,
      name: name,
      phone: phone,
      relationship: relationship.value,
      shareAdherence: shareAdherence.value,
    );

    final result = await _caregiverRepository.save(caregiver);
    result.fold(
      (error) => errorMessage.value = error.message,
      (saved) {
        savedCaregiver.value = saved;
        Get.snackbar(
          'caregiver.save_success_title'.tr,
          'caregiver.save_success_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    isSaving.value = false;
  }

  Future<void> removeCaregiver() async {
    if (profileId.value.isEmpty || isRemoving.value) {
      return;
    }

    isRemoving.value = true;
    errorMessage.value = '';

    final result = await _caregiverRepository.delete(profileId.value);
    result.fold(
      (error) => errorMessage.value = error.message,
      (_) {
        savedCaregiver.value = null;
        nameCtrl.clear();
        phoneCtrl.clear();
        relationship.value = 'son';
        shareAdherence.value = false;
        Get.snackbar(
          'caregiver.remove_success_title'.tr,
          'caregiver.remove_success_body'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      },
    );

    isRemoving.value = false;
  }

  Future<void> callCaregiver() async {
    final phone = phoneCtrl.text.trim();
    if (phone.length < 10) {
      phoneError.value = 'caregiver.error_phone_invalid'.tr;
      return;
    }
    await InteractionHelper.callPhone(phone);
  }

  void openDoctorExport() => Get.toNamed(Routes.DOCTOR_EXPORT);

  Future<void> speakPrivacySummary() async {
    await _tts.speak(
      '${'caregiver.privacy_title'.tr}. ${'caregiver.privacy_body'.tr}',
    );
  }
}
