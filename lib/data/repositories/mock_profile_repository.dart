// lib/data/repositories/mock_profile_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/mock/mock_constants.dart';
import '../../core/mock/mock_image_urls.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import '../models/app_settings_model.dart';
import '../models/profile_model.dart';
import 'profile_repository.dart';

class MockProfileRepository implements ProfileRepository {
  static const _demoSecondaryId = 'p_demo_ramesh';

  @override
  Future<Either<ErrorDetailWrapper, List<ProfileModel>>> getAll() async {
    await Future<void>.delayed(mockNetworkDelay);
    await _ensureDemoSecondaryProfile();

    final ids = StorageManager.getProfileIds();
    final profiles = <ProfileModel>[];
    for (final id in ids) {
      final json = StorageManager.getProfileData(id);
      if (json != null) {
        profiles.add(ProfileModel.fromJson(json));
      }
    }

    profiles.sort((a, b) => a.name.compareTo(b.name));
    return Right(profiles);
  }

  @override
  Future<Either<ErrorDetailWrapper, ProfileModel?>> getActive() async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = StorageManager.getActiveProfile();
    if (id == null) {
      return const Right(null);
    }
    final json = StorageManager.getProfileData(id);
    if (json == null) {
      return const Right(null);
    }
    return Right(ProfileModel.fromJson(json));
  }

  @override
  Future<Either<ErrorDetailWrapper, ProfileModel>> save(
    ProfileModel profile,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    final saved = profile.copyWith(
      avatarUrl: profile.avatarUrl ?? MockImageUrls.avatar(profile.name.hashCode),
    );
    await StorageManager.saveProfileData(saved.id, saved.toJson());
    await StorageManager.registerProfileId(saved.id);
    await StorageManager.saveActiveProfile(saved.id);
    return Right(saved);
  }

  @override
  Future<Either<ErrorDetailWrapper, ProfileModel>> switchActive(
    String profileId,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    final json = StorageManager.getProfileData(profileId);
    if (json == null) {
      return Left(ErrorDetailWrapper.unknown('Profile not found.'));
    }
    await StorageManager.saveActiveProfile(profileId);
    return Right(ProfileModel.fromJson(json));
  }

  @override
  Future<Either<ErrorDetailWrapper, AppSettingsModel>> getSettings() async {
    await Future<void>.delayed(mockNetworkDelay);
    final raw = StorageManager.getAppSettings();
    if (raw.isEmpty) {
      final locale = StorageManager.getLocale() ?? 'en';
      return Right(AppSettingsModel.defaults().copyWith(languageCode: locale));
    }
    return Right(AppSettingsModel.fromJson(raw));
  }

  @override
  Future<Either<ErrorDetailWrapper, AppSettingsModel>> saveSettings(
    AppSettingsModel settings,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    await StorageManager.saveAppSettings(settings.toJson());
    return Right(settings);
  }

  Future<void> _ensureDemoSecondaryProfile() async {
    final ids = StorageManager.getProfileIds();
    if (ids.length > 1) {
      return;
    }

    final activeId = StorageManager.getActiveProfile();
    if (activeId != null && activeId.isNotEmpty) {
      await StorageManager.registerProfileId(activeId);
    }

    if (StorageManager.getProfileData(_demoSecondaryId) != null) {
      await StorageManager.registerProfileId(_demoSecondaryId);
      return;
    }

    final secondary = ProfileModel(
      id: _demoSecondaryId,
      name: 'Rameshbhai',
      age: 72,
      localeCode: 'gu',
      avatarUrl: MockImageUrls.avatar(1),
    );
    await StorageManager.saveProfileData(_demoSecondaryId, secondary.toJson());
    await StorageManager.registerProfileId(_demoSecondaryId);
  }
}
