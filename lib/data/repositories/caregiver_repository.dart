// lib/data/repositories/caregiver_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/network/error_detail_wrapper.dart';
import '../models/caregiver_model.dart';

abstract class CaregiverRepository {
  Future<Either<ErrorDetailWrapper, CaregiverModel?>> getForProfile(
    String profileId,
  );

  Future<Either<ErrorDetailWrapper, CaregiverModel>> save(
    CaregiverModel caregiver,
  );

  Future<Either<ErrorDetailWrapper, void>> delete(String profileId);
}
