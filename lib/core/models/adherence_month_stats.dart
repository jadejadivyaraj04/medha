// lib/core/models/adherence_month_stats.dart

class AdherenceMonthStats {
  const AdherenceMonthStats({
    required this.year,
    required this.month,
    required this.totalDoses,
    required this.takenDoses,
    required this.missedDoses,
    required this.skippedDoses,
    required this.scheduledDays,
    required this.perfectDays,
    required this.streakDays,
  });

  final int year;
  final int month;
  final int totalDoses;
  final int takenDoses;
  final int missedDoses;
  final int skippedDoses;
  final int scheduledDays;
  final int perfectDays;
  final int streakDays;

  double get adherencePercent =>
      totalDoses == 0 ? 0 : (takenDoses / totalDoses) * 100;
}
