// lib/core/export/doctor_pdf_generator.dart

import 'dart:io';

import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/doctor_export_report.dart';
import '../utils/adherence_date_helper.dart';

class DoctorPdfGenerator {
  DoctorPdfGenerator._();

  static Future<String> generate(DoctorExportReport report) async {
    final doc = pw.Document();
    final monthLabel = AdherenceDateHelper.monthLabel(
      DateTime(report.monthStats.year, report.monthStats.month),
    );
    final generatedLabel = _formatDate(report.generatedAt);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          pw.Text(
            'doctor_export.pdf_title'.tr,
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            'doctor_export.pdf_subtitle'.tr,
            style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 20),
          _sectionTitle('doctor_export.pdf_patient'.tr),
          pw.Text(
            '${report.profile.name} · ${'doctor_export.pdf_age'.trParams({'age': '${report.profile.age}'})}',
            style: const pw.TextStyle(fontSize: 12),
          ),
          pw.Text(
            '${'doctor_export.pdf_generated'.tr}: $generatedLabel',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.SizedBox(height: 16),
          _sectionTitle('doctor_export.pdf_medicines'.tr),
          if (report.activeMedicines.isEmpty)
            pw.Text(
              'doctor_export.empty_medicines'.tr,
              style: const pw.TextStyle(fontSize: 11),
            )
          else
            pw.TableHelper.fromTextArray(
              headers: [
                'doctor_export.col_name'.tr,
                'doctor_export.col_dose'.tr,
                'doctor_export.col_frequency'.tr,
                'doctor_export.col_food'.tr,
                'doctor_export.col_duration'.tr,
              ],
              data: report.activeMedicines
                  .map(
                    (medicine) => [
                      medicine.name,
                      medicine.dosageMg != null ? '${medicine.dosageMg} mg' : '—',
                      medicine.frequency,
                      _foodLabel(medicine.withFood),
                      '${medicine.durationDays} ${'doctor_export.days'.tr}',
                    ],
                  )
                  .toList(),
              headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                fontSize: 10,
              ),
              cellStyle: const pw.TextStyle(fontSize: 9),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellAlignment: pw.Alignment.centerLeft,
              cellPadding: const pw.EdgeInsets.all(6),
            ),
          pw.SizedBox(height: 16),
          _sectionTitle('doctor_export.pdf_adherence'.tr),
          if (!report.hasAdherenceData)
            pw.Text(
              'doctor_export.empty_adherence'.tr,
              style: const pw.TextStyle(fontSize: 11),
            )
          else ...[
            pw.Text(
              '$monthLabel · ${report.monthStats.adherencePercent.round()}%',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              'doctor_export.pdf_stats_line'.trParams({
                'taken': '${report.monthStats.takenDoses}',
                'total': '${report.monthStats.totalDoses}',
                'missed': '${report.monthStats.missedDoses}',
                'skipped': '${report.monthStats.skippedDoses}',
                'streak': '${report.monthStats.streakDays}',
              }),
              style: const pw.TextStyle(fontSize: 10),
            ),
            if (report.daySummaries.isNotEmpty) ...[
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: [
                  'doctor_export.col_date'.tr,
                  'doctor_export.col_taken'.tr,
                  'doctor_export.col_total'.tr,
                  'doctor_export.col_percent'.tr,
                ],
                data: report.daySummaries
                    .map(
                      (day) => [
                        day.dateKey,
                        '${day.takenCount}',
                        '${day.totalCount}',
                        '${(day.ratio * 100).round()}%',
                      ],
                    )
                    .toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 9,
                ),
                cellStyle: const pw.TextStyle(fontSize: 8),
                headerDecoration:
                    const pw.BoxDecoration(color: PdfColors.grey300),
                cellPadding: const pw.EdgeInsets.all(4),
              ),
            ],
          ],
          if (report.hasCaregiver) ...[
            pw.SizedBox(height: 16),
            _sectionTitle('doctor_export.pdf_caregiver'.tr),
            pw.Text(
              report.includeAdherenceForCaregiver
                  ? 'doctor_export.pdf_caregiver_with_adherence'.trParams({
                      'name': report.caregiver!.name,
                      'phone': report.caregiver!.phone,
                    })
                  : 'doctor_export.pdf_caregiver_contact'.trParams({
                      'name': report.caregiver!.name,
                      'phone': report.caregiver!.phone,
                    }),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
          pw.SizedBox(height: 20),
          pw.Divider(color: PdfColors.grey400),
          pw.SizedBox(height: 8),
          pw.Text(
            'doctor_export.disclaimer'.tr,
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColors.grey700,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ],
      ),
    );

    final bytes = await doc.save();
    final dir = await getApplicationDocumentsDirectory();
    final safeName = report.profile.name
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .trim()
        .replaceAll(RegExp(r'\s+'), '_');
    final fileName =
        'medha_report_${safeName.isEmpty ? 'patient' : safeName}_${report.monthStats.year}_${report.monthStats.month}.pdf';
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static pw.Widget _sectionTitle(String title) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 13,
          fontWeight: pw.FontWeight.bold,
        ),
      ),
    );
  }

  static String _foodLabel(String withFood) {
    return switch (withFood) {
      'before' => 'doctor_export.food_before'.tr,
      'after' => 'doctor_export.food_after'.tr,
      _ => 'doctor_export.food_any'.tr,
    };
  }

  static String _formatDate(DateTime date) {
    final y = date.year;
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
