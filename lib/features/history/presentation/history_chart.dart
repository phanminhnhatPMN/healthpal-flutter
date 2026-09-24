import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../domain/daily_health_summary.dart';

class HistoryChart extends StatelessWidget {
  const HistoryChart({
    super.key,
    required this.summaries,
    required this.metric,
    required this.period,
  });

  final List<DailyHealthSummary> summaries;
  final HistoryMetric metric;
  final HistoryPeriod period;

  @override
  Widget build(BuildContext context) {
    final chronological = summaries.reversed.toList(growable: false);
    return Semantics(
      label: _semanticLabel(chronological),
      image: true,
      child: SizedBox(
        key: Key('history-chart-${metric.name}'),
        height: 230,
        child:
            metric == HistoryMetric.restingHeartRate ||
                metric == HistoryMetric.hrv
            ? _lineChart(chronological)
            : _barChart(chronological),
      ),
    );
  }

  Widget _barChart(List<DailyHealthSummary> data) {
    final values = data.map((item) => item.valueFor(metric)).toList();
    final available = values.whereType<double>().toList();
    final maxValue = metric == HistoryMetric.stress
        ? 3.4
        : available.isEmpty
        ? 1.0
        : available.reduce(math.max) * 1.16;
    final interval = _gridInterval(maxValue);
    final width = period == HistoryPeriod.sevenDays ? 18.0 : 5.5;

    return BarChart(
      BarChartData(
        minY: 0,
        maxY: maxValue,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE8EAF1), strokeWidth: 1),
        ),
        titlesData: _titles(data, maxValue, interval),
        barGroups: List.generate(data.length, (index) {
          final item = data[index];
          final value = values[index];
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: value ?? 0,
                width: width,
                color: value == null
                    ? Colors.transparent
                    : metric == HistoryMetric.stress
                    ? item.stressLevel.color
                    : metric.color,
                borderRadius: BorderRadius.circular(width / 2),
              ),
            ],
          );
        }),
      ),
      duration: const Duration(milliseconds: 350),
    );
  }

  Widget _lineChart(List<DailyHealthSummary> data) {
    final available = data
        .map((item) => item.valueFor(metric))
        .whereType<double>()
        .toList();
    if (available.isEmpty) {
      return const Center(child: Text('Chưa có dữ liệu'));
    }
    final rawMin = available.reduce(math.min);
    final rawMax = available.reduce(math.max);
    final padding = math.max(4.0, (rawMax - rawMin) * 0.25);
    final minY = math.max(0.0, rawMin - padding);
    final maxY = rawMax + padding;
    final interval = _gridInterval(maxY - minY);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(1, data.length - 1).toDouble(),
        minY: minY,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: false),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          drawVerticalLine: false,
          horizontalInterval: interval,
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Color(0xFFE8EAF1), strokeWidth: 1),
        ),
        titlesData: _titles(data, maxY, interval, minY: minY),
        lineBarsData: _lineSegments(data),
      ),
      duration: const Duration(milliseconds: 350),
    );
  }

  List<LineChartBarData> _lineSegments(List<DailyHealthSummary> data) {
    final result = <LineChartBarData>[];
    var current = <FlSpot>[];

    void addCurrent() {
      if (current.isEmpty) return;
      result.add(
        LineChartBarData(
          spots: current,
          isCurved: current.length > 2,
          curveSmoothness: 0.25,
          color: metric.color,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(show: period == HistoryPeriod.sevenDays),
          belowBarData: BarAreaData(
            show: true,
            color: metric.color.withValues(alpha: 0.10),
          ),
        ),
      );
      current = <FlSpot>[];
    }

    for (var index = 0; index < data.length; index++) {
      final value = data[index].valueFor(metric);
      if (value == null) {
        addCurrent();
      } else {
        current.add(FlSpot(index.toDouble(), value));
      }
    }
    addCurrent();
    return result;
  }

  FlTitlesData _titles(
    List<DailyHealthSummary> data,
    double maxY,
    double interval, {
    double minY = 0,
  }) {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: metric == HistoryMetric.stress ? 42 : 45,
          interval: metric == HistoryMetric.stress ? 1 : interval,
          minIncluded: false,
          maxIncluded: false,
          getTitlesWidget: (value, meta) {
            final text = metric == HistoryMetric.stress
                ? switch (value.round()) {
                    1 => 'Thấp',
                    2 => 'TB',
                    3 => 'Cao',
                    _ => '',
                  }
                : _compact(value);
            return SideTitleWidget(
              meta: meta,
              space: 7,
              child: Text(
                text,
                style: const TextStyle(fontSize: 9, color: Color(0xFF777A88)),
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          interval: 1,
          getTitlesWidget: (value, meta) {
            final index = value.round();
            if (index < 0 ||
                index >= data.length ||
                !_showDateLabel(index, data.length)) {
              return const SizedBox.shrink();
            }
            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Text(
                _shortDate(data[index].date),
                style: const TextStyle(fontSize: 9, color: Color(0xFF777A88)),
              ),
            );
          },
        ),
      ),
    );
  }

  bool _showDateLabel(int index, int length) {
    if (period == HistoryPeriod.sevenDays) return true;
    return index == 0 || index == length - 1 || index % 5 == 0;
  }

  double _gridInterval(double span) {
    if (metric == HistoryMetric.stress) return 1;
    if (span <= 10) return 2;
    if (span <= 50) return 10;
    if (span <= 500) return 100;
    if (span <= 5000) return 1000;
    return 2500;
  }

  String _semanticLabel(List<DailyHealthSummary> data) {
    final values = data
        .map((item) => item.valueFor(metric))
        .whereType<double>();
    return 'Biểu đồ ${metric.label}, ${data.length} ngày, '
        '${values.length} ngày có dữ liệu.';
  }

  String _compact(double value) {
    if (value.abs() >= 1000) return '${(value / 1000).toStringAsFixed(0)}k';
    if (value.abs() < 10 && value != value.roundToDouble()) {
      return value.toStringAsFixed(1);
    }
    return value.toStringAsFixed(0);
  }

  String _shortDate(DateTime value) => '${value.day}/${value.month}';
}

extension HistoryMetricPresentation on HistoryMetric {
  IconData get icon => switch (this) {
    HistoryMetric.stress => Icons.psychology_alt_rounded,
    HistoryMetric.sleep => Icons.bedtime_rounded,
    HistoryMetric.steps => Icons.directions_walk_rounded,
    HistoryMetric.restingHeartRate => Icons.favorite_rounded,
    HistoryMetric.hrv => Icons.monitor_heart_rounded,
    HistoryMetric.activeCalories => Icons.local_fire_department_rounded,
  };

  String get label => switch (this) {
    HistoryMetric.stress => 'Stress',
    HistoryMetric.sleep => 'Giấc ngủ',
    HistoryMetric.steps => 'Số bước',
    HistoryMetric.restingHeartRate => 'Nhịp tim nghỉ',
    HistoryMetric.hrv => 'HRV',
    HistoryMetric.activeCalories => 'Calories',
  };

  String get unit => switch (this) {
    HistoryMetric.stress => '',
    HistoryMetric.sleep => 'giờ',
    HistoryMetric.steps => 'bước',
    HistoryMetric.restingHeartRate => 'bpm',
    HistoryMetric.hrv => 'ms',
    HistoryMetric.activeCalories => 'kcal',
  };

  Color get color => switch (this) {
    HistoryMetric.stress => const Color(0xFFF05D7B),
    HistoryMetric.sleep => const Color(0xFF6656D9),
    HistoryMetric.steps => const Color(0xFFEE7A35),
    HistoryMetric.restingHeartRate => const Color(0xFFEC4565),
    HistoryMetric.hrv => const Color(0xFF4B7BE5),
    HistoryMetric.activeCalories => const Color(0xFFEA9B23),
  };
}

extension StressLevelPresentation on StressLevel {
  String get label => switch (this) {
    StressLevel.low => 'Thấp',
    StressLevel.medium => 'Trung bình',
    StressLevel.high => 'Cao',
  };

  Color get color => switch (this) {
    StressLevel.low => const Color(0xFF2DA66E),
    StressLevel.medium => const Color(0xFFF0A52B),
    StressLevel.high => const Color(0xFFE04B59),
  };
}
