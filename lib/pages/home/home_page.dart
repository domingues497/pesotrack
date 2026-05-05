import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/weight_entry.dart';
import '../../providers/profile_provider.dart';
import '../../providers/weight_provider.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/section_header.dart';
import 'widgets/hero_weight_card.dart';
import 'widgets/kpi_grid.dart';
import 'widgets/recent_entries_list.dart';
import 'widgets/weight_chart.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    this.onOpenRegister,
    this.onOpenHistory,
  });

  final VoidCallback? onOpenRegister;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    final entries = ref.watch(weightProvider);
    if (profile == null) {
      return const SizedBox.shrink();
    }

    if (entries.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [
          EmptyState(
            title: 'Sem registros ainda',
            message: 'Assim que você salvar o primeiro peso, o painel vai mostrar progresso, gráfico e resumo.',
          ),
        ],
      );
    }

    final latest = entries.last;
    final first = entries.first;
    final activeGoal = profile.activeGoal;
    final imc = ImcCalculator.calculate(
      weightKg: latest.weight,
      heightCm: profile.heightCm,
      sex: profile.sex,
      age: profile.age,
    );
    final delta = latest.weight - first.weight;
    final progress = activeGoal == null
        ? null
        : _goalProgress(
            startWeight: activeGoal.startWeight,
            currentWeight: latest.weight,
            goalWeight: activeGoal.targetWeight,
          );
    final missing = activeGoal == null ? null : (latest.weight - activeGoal.targetWeight).abs();
    final streak = _calculateStreak(entries);
    final trend = _buildTrendInsight(entries);
    final recentEntries = entries.reversed.take(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text(
          'Seu peso, com calma.',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Um diário mais humano, leve e claro.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        HeroWeightCard(
          currentWeight: latest.weight,
          lastRecordedAt: latest.recordedAt,
          startWeight: activeGoal?.startWeight,
          goalWeight: activeGoal?.targetWeight,
          targetDate: activeGoal?.targetDate,
          progress: progress,
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
        WeightChart(
          entries: entries,
          goals: profile.goals,
        ),
        const SizedBox(height: 20),
        RecentEntriesList(
          entries: recentEntries,
          previousEntries: entries,
          trendTitle: trend.title,
          trendDescription: trend.description,
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

class _TrendInsight {
  const _TrendInsight({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

_TrendInsight _buildTrendInsight(List<WeightEntry> entries) {
  final dailyEntries = _dailyLastEntries(entries);
  if (dailyEntries.length < 2) {
    return const _TrendInsight(
      title: 'Estável',
      description: 'Ainda há poucos registros para identificar uma tendência com segurança.',
    );
  }

  final now = DateTime.now();
  final cutoff = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 6));
  final window = dailyEntries.where((entry) {
    final date = DateTime(entry.recordedAt.year, entry.recordedAt.month, entry.recordedAt.day);
    return !date.isBefore(cutoff);
  }).toList();
  final recent = window.length >= 2 ? window : dailyEntries.takeLast(7);

  final latest = recent.last;
  final average = recent.map((entry) => entry.weight).reduce((a, b) => a + b) / recent.length;
  final first = recent.first;
  final days = latest.recordedAt.difference(first.recordedAt).inDays.abs().clamp(1, 365);
  final slopePerDay = (latest.weight - first.weight) / days;
  final diffFromAverage = latest.weight - average;

  final title = switch ((diffFromAverage, slopePerDay)) {
    (< -0.8, < -0.08) => 'Queda consistente',
    (< -0.3, < 0) => 'Queda leve',
    (> 0.8, > 0.08) => 'Alta consistente',
    (> 0.3, > 0) => 'Alta leve',
    _ => 'Estável',
  };

  final directionText = diffFromAverage < 0 ? 'abaixo' : diffFromAverage > 0 ? 'acima' : 'alinhado com';
  final diffText = diffFromAverage.abs().toStringAsFixed(1);
  final paceText = switch (title) {
    'Queda consistente' => 'O ritmo atual indica progresso contínuo.',
    'Queda leve' => 'Há redução recente, mas ainda em ritmo moderado.',
    'Alta consistente' => 'A sequência recente mostra alta clara e merece atenção.',
    'Alta leve' => 'Há aumento recente, mas ainda com intensidade moderada.',
    _ => 'As oscilações recentes estão dentro de uma faixa estável.',
  };

  if (diffText == '0.0') {
    return _TrendInsight(
      title: title,
      description: 'Seu último peso está alinhado com a média dos últimos 7 dias. $paceText',
    );
  }

  return _TrendInsight(
    title: title,
    description: 'Seu último peso está $diffText kg $directionText a média dos últimos 7 dias. $paceText',
  );
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

extension on List<WeightEntry> {
  List<WeightEntry> takeLast(int count) {
    if (length <= count) {
      return this;
    }
    return sublist(length - count);
  }
}
