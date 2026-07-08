// lib/data/services/doctor_export_api_service.dart

import 'package:dartz/dartz.dart';
import 'package:get/get.dart';

import '../../core/models/doctor_export_report.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import '../models/caregiver_model.dart';
import '../models/profile_model.dart';
import '../repositories/adherence_repository.dart';
import '../repositories/caregiver_repository.dart';
import '../repositories/medicine_repository.dart';
import '../repositories/profile_repository.dart';

/// Local data gateway for doctor PDF reports — no network API (offline-only).
class DoctorExportApiService {
  DoctorExportApiService({
    ProfileRepository? profileRepository,
    MedicineRepository? medicineRepository,
    AdherenceRepository? adherenceRepository,
    CaregiverRepository? caregiverRepository,
  })  : _profileRepository =
            profileRepository ?? Get.find<ProfileRepository>(),
        _medicineRepository =
            medicineRepository ?? Get.find<MedicineRepository>(),
        _adherenceRepository =
            adherenceRepository ?? Get.find<AdherenceRepository>(),
        _caregiverRepository =
            caregiverRepository ?? Get.find<CaregiverRepository>();

  final ProfileRepository _profileRepository;
  final MedicineRepository _medicineRepository;
  final AdherenceRepository _adherenceRepository;
  final CaregiverRepository _caregiverRepository;

  Future<Either<ErrorDetailWrapper, DoctorExportReport>> buildReport({
    required int year,
    required int month,
    String? profileId,
  }) async {
    try {
      final id = profileId ?? StorageManager.getActiveProfile();
      if (id == null || id.isEmpty) {
        return Left(
          ErrorDetailWrapper.unknown('doctor_export.error_no_profile'.tr),
        );
      }

      final profileResult = await _resolveProfile(id);
      if (profileResult.isLeft()) {
        return profileResult.fold(
          Left.new,
          (_) => throw StateError('unreachable'),
        );
      }
      final profile = profileResult.getOrElse(() => throw StateError(''));

      final medicinesResult =
          await _medicineRepository.getAll(profileId: id);
      if (medicinesResult.isLeft()) {
        return medicinesResult.fold(
          Left.new,
          (_) => throw StateError('unreachable'),
        );
      }

      final statsResult =
          await _adherenceRepository.getMonthStats(year, month, profileId: id);
      if (statsResult.isLeft()) {
        return statsResult.fold(
          Left.new,
          (_) => throw StateError('unreachable'),
        );
      }

      final summariesResult = await _adherenceRepository.getDaySummaries(
        year,
        month,
        profileId: id,
      );
      if (summariesResult.isLeft()) {
        return summariesResult.fold(
          Left.new,
          (_) => throw StateError('unreachable'),
        );
      }

      CaregiverModel? caregiver;
      final caregiverResult = await _caregiverRepository.getForProfile(id);
      caregiverResult.fold(
        (_) => caregiver = null,
        (data) => caregiver = data,
      );

      final stats = statsResult.getOrElse(() => throw StateError(''));
      final includeAdherence =
          caregiver?.shareAdherence == true && stats.totalDoses > 0;

      return Right(
        DoctorExportReport(
          profile: profile,
          medicines: medicinesResult.getOrElse(() => []),
          monthStats: stats,
          daySummaries: includeAdherence
              ? summariesResult.getOrElse(() => [])
              : [],
          caregiver: caregiver,
          generatedAt: DateTime.now(),
        ),
      );
    } catch (error) {
      return Left(ErrorDetailWrapper.unknown(error.toString()));
    }
  }

  Future<Either<ErrorDetailWrapper, ProfileModel>> _resolveProfile(
    String profileId,
  ) async {
    final activeResult = await _profileRepository.getActive();
    return activeResult.fold(
      Left.new,
      (active) {
        if (active != null && active.id == profileId) {
          return Right(active);
        }
        final data = StorageManager.getProfileData(profileId);
        if (data == null) {
          return Left(
            ErrorDetailWrapper.unknown('doctor_export.error_no_profile'.tr),
          );
        }
        return Right(ProfileModel.fromJson(data));
      },
    );
  }
}
