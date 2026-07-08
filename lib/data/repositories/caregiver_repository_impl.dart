// lib/data/repositories/caregiver_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import '../models/caregiver_model.dart';
import 'caregiver_repository.dart';

class CaregiverRepositoryImpl implements CaregiverRepository {
  @override
  Future<Either<ErrorDetailWrapper, CaregiverModel?>> getForProfile(
    String profileId,
  ) async {
    try {
      final json = StorageManager.getCaregiverForProfile(profileId);
      if (json == null) {
        return const Right(null);
      }
      return Right(CaregiverModel.fromJson(json));
    } catch (error) {
      return Left(ErrorDetailWrapper.unknown(error.toString()));
    }
  }

  @override
  Future<Either<ErrorDetailWrapper, CaregiverModel>> save(
    CaregiverModel caregiver,
  ) async {
    try {
      await StorageManager.saveCaregiverForProfile(
        caregiver.profileId,
        caregiver.toJson(),
      );
      return Right(caregiver);
    } catch (error) {
      return Left(ErrorDetailWrapper.unknown(error.toString()));
    }
  }

  @override
  Future<Either<ErrorDetailWrapper, void>> delete(String profileId) async {
    try {
      await StorageManager.deleteCaregiverForProfile(profileId);
      return const Right(null);
    } catch (error) {
      return Left(ErrorDetailWrapper.unknown(error.toString()));
    }
  }
}
