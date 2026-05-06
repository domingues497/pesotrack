import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/user_profile.dart';
import '../../../models/weight_entry.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/soft_card.dart';

enum _ChartRange {
  days7('7 dias', 7),
  days15('15 dias', 15),
  days30('30 dias', 30),
  days90('90 dias', 90),
  all('Tudo', null);

  const _ChartRange(this.label, this.days);

  final String label;
  final int? days;
}

class WeightChart extends StatefulWidget {
  const WeightChart({
    super.key,
    required this.entries,
    required this.goals,
  });

  final List<WeightEntry> entries;
  final List<GoalPlan> goals;

  @override
  State<WeightChart> createState() => _WeightChartState();
}

class _WeightChartState extends State<WeightChart> {
  _ChartRange _selectedRange = _ChartRange.days30;

  @override
  Widget build(BuildContext context) {
    final allDailyEntries = _dailyLastEntries(widget.entries);
    final sortedEntries = _filterEntries(allDailyEntries, _selectedRange);
    final spots = <FlSpot>[
      for (var index = 0; index < sortedEntries.length; index++)
        FlSpot(index.toDouble(), sortedEntries[index].weight),
    ];
    final weights = sortedEntries.map((entry) => entry.weight).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b) - 1).clamp(0.0, double.infinity);
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 1;
    final goalMarkers = _buildGoalMarkers(sortedEntries);

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Evolução do peso',
          ),
          const SizedBox(height: AppSpacing.x3),
          Wrap(
            spacing: AppSpacing.x2,
            runSpacing: AppSpacing.x2,
            children: _ChartRange.values.map((range) {
              return ChoiceChip(
                label: Text(range.label),
                selected: _selectedRange == range,
                onSelected: (_) {
                  setState(() {
                    _selectedRange = range;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.x2),
          if (_selectedRange != _ChartRange.all && sortedEntries.length == allDailyEntries.length)
            Text(
              'Mostrando todos os dados disponíveis porque ainda há poucos registros no período.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          const SizedBox(height: AppSpacing.x3),
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY,
                maxY: maxY,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: 1,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => const FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                extraLinesData: ExtraLinesData(
                  verticalLines: goalMarkers,
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: 1,
                      getTitlesWidget: (value, meta) => Text(
                        value.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: _bottomInterval(spots.length),
                      getTitlesWidget: (value, meta) {
                        final index = value.round();
                        if (index < 0 || index >= sortedEntries.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.x2),
                          child: Text(
                            sortedEntries[index].recordedAt.asShortDate,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (_) => AppColors.textPrimary,
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        final entry = sortedEntries[spot.x.round()];
                        return LineTooltipItem(
                          '${entry.weight.asKg}\n${entry.recordedAt.asShortDate}',
                          Theme.of(context).textTheme.bodySmall!.copyWith(
                                color: AppColors.white,
                              ),
                        );
                      }).toList();
                    },
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.accent,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.accent.withValues(alpha: 0.18),
                          AppColors.accent.withValues(alpha: 0.01),
                        ],
                      ),
                    ),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                        radius: 3.5,
                        color: AppColors.white,
                        strokeWidth: 2.5,
                        strokeColor: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<WeightEntry> _filterEntries(List<WeightEntry> allDailyEntries, _ChartRange range) {
    if (range == _ChartRange.all) {
      return allDailyEntries;
    }

    final days = range.days!;
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final filtered = allDailyEntries.where((entry) => entry.recordedAt.isAfter(cutoff)).toList();
    if (filtered.length < 3) {
      return allDailyEntries;
    }
    return filtered;
  }

  double _bottomInterval(int count) {
    if (count <= 1) {
      return 1;
    }
    if (count <= 4) {
      return 1;
    }
    return (count / 3).ceilToDouble();
  }

  List<VerticalLine> _buildGoalMarkers(List<WeightEntry> sortedEntries) {
    if (sortedEntries.isEmpty) {
      return const [];
    }

    final markers = <VerticalLine>[];
    for (final goal in widget.goals) {
      final goalIndex = sortedEntries.indexWhere((entry) {
        final entryDate = DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day);
        final goalDate = DateTime(goal.startDate.year, goal.startDate.month, goal.startDate.day);
        return !entryDate.isBefore(goalDate);
      });

      if (goalIndex == -1) {
        continue;
      }

      markers.add(
        VerticalLine(
          x: goalIndex.toDouble(),
          color: AppColors.textMuted.withValues(alpha: 0.45),
          strokeWidth: 1.5,
          dashArray: [6, 4],
          label: VerticalLineLabel(
            show: true,
            alignment: Alignment.topRight,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            labelResolver: (_) => 'Meta',
          ),
        ),
      );
    }

    return markers;
  }
}

List<WeightEntry> _dailyLastEntries(List<WeightEntry> entries) {
  final sortedEntries = [...entries]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
  final dailyEntries = <DateTime, WeightEntry>{};

  for (final entry in sortedEntries) {
    final day = DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day);
    dailyEntries[day] = entry;
  }

  return dailyEntries.values.toList()..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
}
