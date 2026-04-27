import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class SoftTextField extends StatelessWidget {
  const SoftTextField({
    super.key,
    required this.label,
    this.hintText,
    this.keyboardType,
    this.maxLines = 1,
    this.helperText,
    this.controller,
    this.suffixIcon,
  });

  final String label;
  final String? hintText;
  final TextInputType? keyboardType;
  final int maxLines;
  final String? helperText;
  final TextEditingController? controller;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.x2),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            suffixIcon: suffixIcon,
            helperStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textMuted,
                ),
          ),
        ),
      ],
    );
  }
}
