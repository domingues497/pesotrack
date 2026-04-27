import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/profile_provider.dart';
import '../../providers/weight_provider.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/soft_card.dart';

class ImcPage extends ConsumerWidget {
  const ImcPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    final entries = ref.watch(weightProvider);
    if (profile == null || entries.isEmpty) {
      return const SizedBox.shrink();
    }

    final latest = entries.last;
    final result = ImcCalculator.calculate(
      weightKg: latest.weight,
      heightCm: profile.heightCm,
      sex: profile.sex,
      age: profile.age,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Resultado atual', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text(result.value.toStringAsFixed(1), style: Theme.of(context).textTheme.displaySmall),
              const SizedBox(height: 6),
              Text(result.classification),
              const SizedBox(height: 12),
              Text('Faixa estimada: ${result.idealWeightMin.toStringAsFixed(1)} - ${result.idealWeightMax.toStringAsFixed(1)} kg'),
            ],
          ),
        ),
      ],
    );
  }
}
