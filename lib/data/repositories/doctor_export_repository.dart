// lib/data/repositories/doctor_export_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/models/doctor_export_report.dart';
import '../../core/network/error_detail_wrapper.dart';

abstract class DoctorExportRepository {
  Future<Either<ErrorDetailWrapper, DoctorExportReport>> buildReport({
    required int year,
    required int month,
    String? profileId,
  });

  Future<Either<ErrorDetailWrapper, String>> generatePdf(
    DoctorExportReport report,
  );
}
