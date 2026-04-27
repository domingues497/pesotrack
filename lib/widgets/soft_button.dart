import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class SoftButton extends StatelessWidget {
  const SoftButton.primary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  }) : _variant = _SoftButtonVariant.primary;

  const SoftButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  }) : _variant = _SoftButtonVariant.secondary;

  const SoftButton.soft({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = false,
  }) : _variant = _SoftButtonVariant.soft;

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final _SoftButtonVariant _variant;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: AppSpacing.x2),
        ],
        Text(label),
      ],
    );

    switch (_variant) {
      case _SoftButtonVariant.primary:
        return DecoratedBox(
          decoration: BoxDecoration(
            boxShadow: AppShadows.soft,
            borderRadius: BorderRadius.circular(AppRadii.medium),
          ),
          child: FilledButton(
            onPressed: onPressed,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.white,
            ),
            child: content,
          ),
        );
      case _SoftButtonVariant.secondary:
        return OutlinedButton(onPressed: onPressed, child: content);
      case _SoftButtonVariant.soft:
        return FilledButton(
          onPressed: onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.surfaceAlt,
            foregroundColor: AppColors.accentDeep,
            elevation: 0,
            minimumSize: const Size.fromHeight(48),
            padding: AppSpacing.buttonPadding,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.medium),
            ),
          ),
          child: content,
        );
    }
  }
}

enum _SoftButtonVariant {
  primary,
  secondary,
  soft,
}
