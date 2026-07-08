// lib/core/utils/adherence_date_helper.dart

import 'package:get/get.dart';

import '../models/dose_model.dart';

class AdherenceDateHelper {
  AdherenceDateHelper._();

  static String monthLabel(DateTime month) {
    return 'adherence.months.${month.month}'.trParams({
      'year': '${month.year}',
    });
  }

  static String todayLabel(DateTime date) {
    return 'adherence.day_label'.trParams({
      'weekday': 'adherence.weekdays.${date.weekday}'.tr,
      'day': '${date.day}',
      'month': 'adherence.month_short.${date.month}'.tr,
    });
  }

  static String dayLabel(String dateKey) {
    final parts = dateKey.split('-');
    if (parts.length != 3) {
      return dateKey;
    }

    final date = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );

    return 'adherence.day_label'.trParams({
      'weekday': 'adherence.weekdays.${date.weekday}'.tr,
      'day': '${date.day}',
      'month': 'adherence.month_short.${date.month}'.tr,
    });
  }

  static String timeLabel(DoseModel dose) {
    final time = dose.scheduledDateTime;
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
