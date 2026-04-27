import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/weight_entry.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/soft_card.dart';

class WeightChart extends StatelessWidget {
  const WeightChart({
    super.key,
    required this.entries,
  });

  final List<WeightEntry> entries;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = [...entries]..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final spots = <FlSpot>[
      for (var index = 0; index < sortedEntries.length; index++)
        FlSpot(index.toDouble(), sortedEntries[index].weight),
    ];
    final weights = sortedEntries.map((entry) => entry.weight).toList();
    final minY = (weights.reduce((a, b) => a < b ? a : b) - 1).clamp(0.0, double.infinity);
    final maxY = weights.reduce((a, b) => a > b ? a : b) + 1;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader(
            title: 'Evolucao do peso',
            actionLabel: 'historico',
          ),
          const SizedBox(height: AppSpacing.x4),
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
                      interval: spots.length <= 1 ? 1 : (spots.length - 1) / 2,
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
                          '${entry.weight.toStringAsFixed(1)} kg\n${entry.recordedAt.asShortDate}',
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
}
