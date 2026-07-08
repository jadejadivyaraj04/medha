// lib/data/repositories/adherence_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/models/adherence_month_stats.dart';
import '../../core/models/dose_model.dart';
import '../../core/network/error_detail_wrapper.dart';
import 'reminder_repository.dart';

abstract class AdherenceRepository {
  Future<Either<ErrorDetailWrapper, AdherenceMonthStats>> getMonthStats(
    int year,
    int month, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, List<AdherenceDaySummary>>> getDaySummaries(
    int year,
    int month, {
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, List<DoseModel>>> getDayDoses(
    DateTime date, {
    String? profileId,
  });
}
