import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../widgets/kpi_card.dart';

class KpiGrid extends StatelessWidget {
  const KpiGrid({
    super.key,
    required this.variation,
    required this.bmiValue,
    required this.bmiLabel,
    required this.count,
    required this.missingToGoal,
    required this.streak,
  });

  final double variation;
  final double bmiValue;
  final String bmiLabel;
  final int count;
  final double missingToGoal;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final isLoss = variation <= 0;

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.x3,
      crossAxisSpacing: AppSpacing.x3,
      childAspectRatio: 1.18,
      children: [
        KpiCard(
          label: 'Variacao total',
          value: variation.toStringAsFixed(1),
          footnote: isLoss ? 'kg perdidos' : 'kg ganhos',
          valueColor: isLoss ? AppColors.success : AppColors.danger,
        ),
        KpiCard(
          label: 'IMC atual',
          value: bmiValue.toStringAsFixed(1),
          footnote: bmiLabel,
        ),
        KpiCard(
          label: 'Streak',
          value: '$streak',
          footnote: streak == 1 ? 'dia seguido' : 'dias seguidos',
        ),
        KpiCard(
          label: 'Faltam',
          value: missingToGoal.toStringAsFixed(1),
          footnote: 'kg para sua meta',
        ),
      ],
    );
  }
}
