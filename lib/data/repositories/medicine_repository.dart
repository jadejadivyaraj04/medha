// lib/data/repositories/medicine_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/models/medicine_model.dart';
import '../../core/network/error_detail_wrapper.dart';

abstract class MedicineRepository {
  Future<Either<ErrorDetailWrapper, List<MedicineModel>>> getAll({
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, MedicineModel?>> getById(
    String id, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, List<MedicineModel>>> saveAll(
    List<MedicineModel> medicines, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, MedicineModel>> update(
    MedicineModel medicine, {
    String? profileId,
  });
}
