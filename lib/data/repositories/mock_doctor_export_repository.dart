// lib/data/repositories/mock_doctor_export_repository.dart

import 'package:dartz/dartz.dart';

import '../../core/mock/mock_constants.dart';
import '../../core/models/doctor_export_report.dart';
import '../../core/network/error_detail_wrapper.dart';
import 'doctor_export_repository.dart';
import 'doctor_export_repository_impl.dart';

class MockDoctorExportRepository implements DoctorExportRepository {
  MockDoctorExportRepository({DoctorExportRepositoryImpl? delegate})
      : _delegate = delegate ?? DoctorExportRepositoryImpl();

  final DoctorExportRepositoryImpl _delegate;

  @override
  Future<Either<ErrorDetailWrapper, DoctorExportReport>> buildReport({
    required int year,
    required int month,
    String? profileId,
  }) async {
    await Future<void>.delayed(mockNetworkDelay);
    return _delegate.buildReport(
      year: year,
      month: month,
      profileId: profileId,
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, String>> generatePdf(
    DoctorExportReport report,
  ) async {
    await Future<void>.delayed(mockNetworkDelay);
    return _delegate.generatePdf(report);
  }
}
