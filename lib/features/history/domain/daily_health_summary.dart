enum HistoryPeriod {
  sevenDays(7),
  thirtyDays(30);

  const HistoryPeriod(this.days);
  final int days;
}

enum HistoryMetric {
  stress,
  sleep,
  steps,
  restingHeartRate,
  hrv,
  activeCalories,
}

enum StressLevel {
  low(1),
  medium(2),
  high(3);

  const StressLevel(this.rank);
  final int rank;
}

class DailyHealthSummary {
  const DailyHealthSummary({
    required this.date,
    required this.stressLevel,
    required this.sleepMinutes,
    required this.steps,
    required this.restingHeartRate,
    required this.hrv,
    required this.activeCalories,
  });

  final DateTime date;
  final StressLevel stressLevel;
  final int sleepMinutes;
  final int steps;
  final int? restingHeartRate;
  final int? hrv;
  final int activeCalories;

  double? valueFor(HistoryMetric metric) {
    return switch (metric) {
      HistoryMetric.stress => stressLevel.rank.toDouble(),
      HistoryMetric.sleep => sleepMinutes / 60,
      HistoryMetric.steps => steps.toDouble(),
      HistoryMetric.restingHeartRate => restingHeartRate?.toDouble(),
      HistoryMetric.hrv => hrv?.toDouble(),
      HistoryMetric.activeCalories => activeCalories.toDouble(),
    };
  }
}
