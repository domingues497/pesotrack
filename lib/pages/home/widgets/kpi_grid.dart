import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
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
  final double? missingToGoal;
  final int streak;

  @override
  Widget build(BuildContext context) {
    final isLoss = variation <= 0;
    final variationLabel = isLoss ? 'Você perdeu' : 'Mudança total';
    final variationFootnote = isLoss ? 'kg desde o início' : 'kg desde o início';

    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.x2,
      crossAxisSpacing: AppSpacing.x2,
      childAspectRatio: 1.34,
      children: [
        KpiCard(
          label: variationLabel,
          value: variation.asSignedKg,
          footnote: variationFootnote,
          valueColor: isLoss ? AppColors.success : AppColors.danger,
        ),
        KpiCard(
          label: 'IMC atual',
          value: bmiValue.asDecimal,
          footnote: 'Faixa atual: $bmiLabel',
        ),
        KpiCard(
          label: 'Sequência',
          value: '$streak',
          footnote: streak == 1 ? 'dia seguido' : 'dias seguidos',
        ),
        KpiCard(
          label: 'Faltam',
          value: missingToGoal?.asKg ?? '--',
          footnote: missingToGoal == null ? 'crie uma meta ativa' : 'para sua meta',
        ),
      ],
    );
  }
}
