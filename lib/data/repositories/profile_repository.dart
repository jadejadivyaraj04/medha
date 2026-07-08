// lib/data/repositories/profile_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/network/error_detail_wrapper.dart';
import '../models/app_settings_model.dart';
import '../models/profile_model.dart';

abstract class ProfileRepository {
  Future<Either<ErrorDetailWrapper, List<ProfileModel>>> getAll();

  Future<Either<ErrorDetailWrapper, ProfileModel?>> getActive();

  Future<Either<ErrorDetailWrapper, ProfileModel>> save(ProfileModel profile);

  Future<Either<ErrorDetailWrapper, ProfileModel>> switchActive(String profileId);

  Future<Either<ErrorDetailWrapper, AppSettingsModel>> getSettings();

  Future<Either<ErrorDetailWrapper, AppSettingsModel>> saveSettings(
    AppSettingsModel settings,
  );
}
