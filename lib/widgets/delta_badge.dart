import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_spacing.dart';

class DeltaBadge extends StatelessWidget {
  const DeltaBadge({
    super.key,
    required this.delta,
  });

  final double delta;

  @override
  Widget build(BuildContext context) {
    final isUp = delta > 0;
    final tone = isUp ? AppColors.danger : AppColors.success;
    final signal = delta > 0 ? '+' : '';

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        '$signal${delta.toStringAsFixed(1)} kg',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: tone),
      ),
    );
  }
}
