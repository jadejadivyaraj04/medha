// lib/data/repositories/mock_caregiver_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/mock/mock_constants.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../models/caregiver_model.dart';
import 'caregiver_repository.dart';
import 'caregiver_repository_impl.dart';

class MockCaregiverRepository implements CaregiverRepository {
  MockCaregiverRepository({CaregiverRepositoryImpl? delegate})
      : _delegate = delegate ?? CaregiverRepositoryImpl();

  final CaregiverRepositoryImpl _delegate;

  @override
  Future<Either<ErrorDetailWrapper, CaregiverModel?>> getForProfile(
    String profileId,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    return _delegate.getForProfile(profileId);
  }

  @override
  Future<Either<ErrorDetailWrapper, CaregiverModel>> save(
    CaregiverModel caregiver,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    return _delegate.save(caregiver);
  }

  @override
  Future<Either<ErrorDetailWrapper, void>> delete(String profileId) async {
    await Future<void>.delayed(mockNetworkDelay);
    return _delegate.delete(profileId);
  }
}
