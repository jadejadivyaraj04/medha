// lib/data/repositories/mock_medicine_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/mock/mock_constants.dart';
import '../../core/models/medicine_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../../core/storage/storage_manager.dart';
import 'medicine_repository.dart';

class MockMedicineRepository implements MedicineRepository {
  static const _seedPrescriptionId = 'rx_seed_1';

  static final List<MedicineModel> _seedMedicines = [
    MedicineModel(
      id: 'seed_m1',
      name: 'Crocin 500',
      dosageMg: 500,
      frequency: '1-0-1',
      withFood: 'after',
      durationDays: 5,
      confidence: 0.92,
      status: 'active',
      prescriptionId: _seedPrescriptionId,
      addedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ),
    MedicineModel(
      id: 'seed_m2',
      name: 'Pan-D 40',
      dosageMg: 40,
      frequency: '1-0-0',
      withFood: 'before',
      durationDays: 14,
      confidence: 0.88,
      status: 'active',
      prescriptionId: _seedPrescriptionId,
      addedAt: DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    ),
    MedicineModel(
      id: 'seed_m3',
      name: 'Telma 40',
      dosageMg: 40,
      frequency: '0-0-1',
      withFood: 'any',
      durationDays: 30,
      confidence: 0.95,
      status: 'completed',
      prescriptionId: 'rx_seed_0',
      addedAt: DateTime.now().subtract(const Duration(days: 40)).toIso8601String(),
    ),
    MedicineModel(
      id: 'seed_m4',
      name: 'Clopitab 75',
      dosageMg: 75,
      frequency: '0-0-1',
      withFood: 'after',
      durationDays: 30,
      confidence: 0.91,
      status: 'active',
      prescriptionId: 'rx_seed_2',
      addedAt: DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
    ),
    MedicineModel(
      id: 'seed_m5',
      name: 'Metformin 500',
      dosageMg: 500,
      frequency: '1-0-1',
      withFood: 'after',
      durationDays: 30,
      confidence: 0.93,
      status: 'active',
      addedAt: DateTime.now().subtract(const Duration(days: 28)).toIso8601String(),
    ),
  ];

  @override
  Future<Either<ErrorDetailWrapper, List<MedicineModel>>> getAll({
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return const Right([]);
    }
    final raw = StorageManager.getMedicinesForProfile(id);
    if (raw.isEmpty) {
      return Right(_seedMedicines);
    }
    return Right(raw.map(MedicineModel.fromJson).toList());
  }

  @override
  Future<Either<ErrorDetailWrapper, MedicineModel?>> getById(
    String id, {
    String? profileId,
  }) async {
    final result = await getAll(profileId: profileId);
    return result.fold(
      Left.new,
      (items) {
        for (final item in items) {
          if (item.id == id) {
            return Right(item);
          }
        }
        return const Right(null);
      },
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, List<MedicineModel>>> saveAll(
    List<MedicineModel> medicines, {
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    final id = profileId ?? StorageManager.getActiveProfile();
    if (id == null || id.isEmpty) {
      return Left(ErrorDetailWrapper.unknown('No active profile found.'));
    }

    final existing = StorageManager.getMedicinesForProfile(id);
    final existingIds = existing.map((e) => e['id'] as String).toSet();
    final merged = [...existing];

    for (final medicine in medicines) {
      final json = medicine.toJson();
      if (existingIds.contains(medicine.id)) {
        final index = merged.indexWhere((e) => e['id'] == medicine.id);
        if (index >= 0) {
          merged[index] = json;
        }
      } else {
        merged.add(json);
      }
    }

    await StorageManager.saveMedicinesForProfile(id, merged);
    return Right(medicines);
  }

  @override
  Future<Either<ErrorDetailWrapper, MedicineModel>> update(
    MedicineModel medicine, {
    String? profileId,
  }) async {
    final result = await saveAll([medicine], profileId: profileId);
    return result.fold(
      Left.new,
      (_) => Right(medicine),
    );
  }
}
