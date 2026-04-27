import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_provider.dart';
import '../../providers/weight_provider.dart';
import '../../utils/extensions.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/soft_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        Text('Seu peso, com calma.', style: Theme.of(context).textTheme.displaySmall),
        const SizedBox(height: 8),
        Text('Base inicial do app em Flutter, pronta para evoluir com pixel perfect.', style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Peso atual', style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(latest.weight.asKg, style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 8),
              Text('Ultimo registro: ${latest.recordedAt.asShortDateTime}'),
              Text('Meta: ${profile.goalWeight.toStringAsFixed(1)} kg'),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: ((first.weight - latest.weight) / (first.weight - profile.goalWeight)).clamp(0.0, 1.0), minHeight: 8),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resumo inicial', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Variacao total: ${delta.toStringAsFixed(1)} kg'),
              Text('IMC atual: ${imc.value.toStringAsFixed(1)}'),
              Text('Registros: ${entries.length}'),
            ],
          ),
        ),
      ],
    );
  }
}
