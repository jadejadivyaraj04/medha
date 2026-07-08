// lib/data/repositories/doctor_export_repository_impl.dart

import 'package:dartz/dartz.dart';

import '../../core/export/doctor_pdf_generator.dart';
import '../../core/models/doctor_export_report.dart';
import '../../core/network/error_detail_wrapper.dart';
import '../services/doctor_export_api_service.dart';
import 'doctor_export_repository.dart';

class DoctorExportRepositoryImpl implements DoctorExportRepository {
  DoctorExportRepositoryImpl({DoctorExportApiService? apiService})
      : _apiService = apiService ?? DoctorExportApiService();

  final DoctorExportApiService _apiService;

  @override
  Future<Either<ErrorDetailWrapper, DoctorExportReport>> buildReport({
    required int year,
    required int month,
    String? profileId,
  }) {
    return _apiService.buildReport(
      year: year,
      month: month,
      profileId: profileId,
    );
  }

  @override
  Future<Either<ErrorDetailWrapper, String>> generatePdf(
    DoctorExportReport report,
  ) async {
    try {
      final path = await DoctorPdfGenerator.generate(report);
      return Right(path);
    } catch (error) {
      return Left(ErrorDetailWrapper.unknown(error.toString()));
    }
  }
}
