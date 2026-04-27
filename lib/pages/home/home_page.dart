import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/weight_entry.dart';
import '../../providers/profile_provider.dart';
import '../../providers/weight_provider.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/section_header.dart';
import 'widgets/hero_weight_card.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/recent_entries_list.dart';
import 'widgets/weight_chart.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    this.onOpenRegister,
    this.onOpenOcr,
    this.onOpenHistory,
  });

  final VoidCallback? onOpenRegister;
  final VoidCallback? onOpenOcr;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final entries = ref.watch(weightProvider);
    final latest = entries.last;
    final first = entries.first;
    final imc = ImcCalculator.calculate(
      weightKg: latest.weight,
      heightCm: profile.heightCm,
      sex: profile.sex,
      age: profile.age,
    );
    final delta = latest.weight - first.weight;
    final progress = _goalProgress(
      startWeight: profile.initialWeight,
      currentWeight: latest.weight,
      goalWeight: profile.goalWeight,
    );
    final missing = (latest.weight - profile.goalWeight).clamp(0.0, double.infinity);
    final streak = _calculateStreak(entries);
    final trendText = _buildTrendText(entries);
    final recentEntries = entries.reversed.take(3).toList();
    final chartEntries = entries.where((entry) {
      final cutoff = DateTime.now().subtract(const Duration(days: 30));
      return entry.recordedAt.isAfter(cutoff);
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          'Seu peso, com calma.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Um diario diario mais humano, leve e claro.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        HeroWeightCard(
          currentWeight: latest.weight,
          lastRecordedAt: latest.recordedAt,
          startWeight: profile.initialWeight,
          goalWeight: profile.goalWeight,
          progress: progress,
          onScanPressed: onOpenOcr,
          onRegisterPressed: onOpenRegister,
        ),
        const SizedBox(height: 16),
        KpiGrid(
          variation: delta,
          bmiValue: imc.value,
          bmiLabel: imc.classification,
          count: entries.length,
          missingToGoal: missing,
          streak: streak,
        ),
        const SizedBox(height: 20),
        const SectionHeader(title: 'Resumo'),
        const SizedBox(height: 12),
        WeightChart(entries: chartEntries.isEmpty ? entries : chartEntries),
        const SizedBox(height: 20),
        RecentEntriesList(
          entries: recentEntries,
          previousEntries: entries,
          trendText: trendText,
          onOpenHistory: onOpenHistory,
        ),
      ],
    );
  }
}

double _goalProgress({
  required double startWeight,
  required double currentWeight,
  required double goalWeight,
}) {
  final totalDistance = (startWeight - goalWeight).abs();
  if (totalDistance == 0) {
    return 1;
  }

  final traveled = (startWeight - currentWeight).abs();
  return (traveled / totalDistance).clamp(0.0, 1.0);
}

int _calculateStreak(List<WeightEntry> entries) {
  if (entries.isEmpty) {
    return 0;
  }

  final uniqueDates = entries
      .map((entry) => DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day))
      .toSet()
      .toList()
    ..sort((a, b) => b.compareTo(a));

  var streak = 1;
  for (var index = 0; index < uniqueDates.length - 1; index++) {
    final difference = uniqueDates[index].difference(uniqueDates[index + 1]).inDays;
    if (difference == 1) {
      streak += 1;
    } else {
      break;
    }
  }
  return streak;
}

String _buildTrendText(List<WeightEntry> entries) {
  if (entries.length < 3) {
    return 'quase sem variacao';
  }

  final recent = entries.reversed.take(3).toList();
  final delta = recent.last.weight - recent.first.weight;
  if (delta <= -0.8) {
    return 'queda estavel';
  }
  if (delta < 0) {
    return 'queda suave';
  }
  if (delta >= 0.8) {
    return 'subida recente';
  }
  return 'quase sem variacao';
}
