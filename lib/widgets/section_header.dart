import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppColors.textMuted,
              ),
        ),
        if (actionLabel != null)
          Padding(
            padding: const EdgeInsets.only(left: AppSpacing.x2),
            child: TextButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ),
      ],
    );
  }
}
