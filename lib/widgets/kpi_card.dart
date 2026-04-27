import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import 'soft_card.dart';

class KpiCard extends StatelessWidget {
  const KpiCard({
    super.key,
    required this.label,
    required this.value,
    this.footnote,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? footnote;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            value,
            style: textTheme.headlineMedium?.copyWith(
              color: valueColor,
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: AppSpacing.x1),
            Text(
              footnote!,
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
