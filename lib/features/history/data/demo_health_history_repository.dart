import '../domain/daily_health_summary.dart';
import 'health_history_repository.dart';

class DemoHealthHistoryRepository implements HealthHistoryRepository {
  DemoHealthHistoryRepository({
    DateTime? anchorDate,
    this.latency = const Duration(milliseconds: 350),
  }) : _anchorDate = _dateOnly(anchorDate ?? DateTime.now());

  final DateTime _anchorDate;
  final Duration latency;

  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);

  @override
  Future<List<DailyHealthSummary>> fetch(HistoryPeriod period) async {
    await Future<void>.delayed(latency);
    final allDays = List<DailyHealthSummary>.generate(30, (index) {
      final date = _anchorDate.subtract(Duration(days: 29 - index));
      final stress = switch (index % 7) {
        0 || 5 => StressLevel.low,
        3 => StressLevel.high,
        _ => StressLevel.medium,
      };
      return DailyHealthSummary(
        date: date,
        stressLevel: stress,
        sleepMinutes: 345 + ((index * 23) % 165),
        steps: 4200 + ((index * 1237) % 8600),
        restingHeartRate: index % 8 == 0 ? null : 60 + ((index * 3) % 15),
        hrv: index % 6 == 0 ? null : 36 + ((index * 5) % 27),
        activeCalories: 230 + ((index * 47) % 430),
      );
    });

    return allDays.reversed.take(period.days).toList(growable: false);
  }
}
