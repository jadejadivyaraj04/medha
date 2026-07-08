// lib/ui/profile/controller/profile_controller.dart

import 'package:get/get.dart';

import '../../../app/routes.dart';
import '../../../core/ai/tts_service.dart';
import '../../../data/models/profile_model.dart';
import '../../../data/repositories/profile_repository.dart';
import '../../home/controller/home_controller.dart';
import '../../medicines/controller/medicines_controller.dart';
import '../../reminders/controller/reminders_controller.dart';
import '../../shell/controller/shell_controller.dart';

class ProfileController extends GetxController {
  ProfileController({required ProfileRepository repository})
      : _repository = repository;

  final ProfileRepository _repository;
  final _tts = Get.find<TtsService>();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final activeProfile = Rxn<ProfileModel>();
  final profiles = <ProfileModel>[].obs;

  String? get activeProfileId => activeProfile.value?.id;

  @override
  void onInit() {
    super.onInit();
    load();
    if (Get.isRegistered<ShellController>()) {
      ever(Get.find<ShellController>().currentIndex, (index) {
        if (index == 3) {
          load();
        }
      });
    }
  }

  Future<void> load() async {
    isLoading.value = true;
    errorMessage.value = '';

    final activeResult = await _repository.getActive();
    final listResult = await _repository.getAll();

    activeResult.fold(
      (error) => errorMessage.value = error.message,
      (profile) => activeProfile.value = profile,
    );

    listResult.fold(
      (error) => errorMessage.value = error.message,
      (data) => profiles.assignAll(data),
    );

    isLoading.value = false;
  }

  @override
  Future<void> refresh() => load();

  Future<void> switchProfile(ProfileModel profile) async {
    if (profile.id == activeProfileId) {
      Get.back<void>();
      return;
    }

    isLoading.value = true;
    final result = await _repository.switchActive(profile.id);
    result.fold(
      (error) => errorMessage.value = error.message,
      (switched) {
        activeProfile.value = switched;
        _reloadPatientData();
        Get.back<void>();
      },
    );
    isLoading.value = false;
  }

  void openSettings() => Get.toNamed(Routes.SETTINGS);

  void openDoubtQuery() => Get.toNamed(Routes.DOUBT_QUERY);

  void openCaregiver() => Get.toNamed(Routes.CAREGIVER);

  void openDoctorExport() => Get.toNamed(Routes.DOCTOR_EXPORT);

  void openAdherenceHistory() => Get.toNamed(Routes.ADHERENCE_HISTORY);

  void addProfile() {
    Get.toNamed(
      Routes.CREATE_PROFILE,
      arguments: {'fromProfile': true},
    )?.then((_) => load());
  }

  Future<void> speakProfile() async {
    final profile = activeProfile.value;
    if (profile == null) {
      return;
    }
    await _tts.speak(
      'profile.readout'.trParams({
        'name': profile.name,
        'age': '${profile.age}',
      }),
    );
  }

  void _reloadPatientData() {
    if (Get.isRegistered<MedicinesController>()) {
      Get.find<MedicinesController>().load();
    }
    if (Get.isRegistered<RemindersController>()) {
      Get.find<RemindersController>().load();
    }
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().load();
    }
  }
}
