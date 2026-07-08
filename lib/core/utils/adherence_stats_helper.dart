// lib/core/utils/adherence_stats_helper.dart

import '../../data/repositories/reminder_repository.dart';
import '../models/adherence_month_stats.dart';

class AdherenceStatsHelper {
  AdherenceStatsHelper._();

  static AdherenceMonthStats monthStatsFromSummaries({
    required int year,
    required int month,
    required List<AdherenceDaySummary> summaries,
  }) {
    var total = 0;
    var taken = 0;
    var missed = 0;
    var skipped = 0;
    var perfectDays = 0;

    for (final summary in summaries) {
      total += summary.totalCount;
      taken += summary.takenCount;
      missed += summary.missedCount;
      skipped += summary.skippedCount;
      if (summary.totalCount > 0 && summary.takenCount == summary.totalCount) {
        perfectDays++;
      }
    }

    return AdherenceMonthStats(
      year: year,
      month: month,
      totalDoses: total,
      takenDoses: taken,
      missedDoses: missed,
      skippedDoses: skipped,
      scheduledDays: summaries.length,
      perfectDays: perfectDays,
      streakDays: _streakFromSummaries(summaries),
    );
  }

  static int _streakFromSummaries(List<AdherenceDaySummary> summaries) {
    final sorted = summaries.toList()
      ..sort((a, b) => b.dateKey.compareTo(a.dateKey));
    var streak = 0;
    for (final summary in sorted) {
      if (summary.totalCount > 0 && summary.takenCount == summary.totalCount) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
