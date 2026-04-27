import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_shadows.dart';
import '../theme/app_spacing.dart';

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = AppSpacing.cardPadding,
    this.radius = AppRadii.large,
    this.color,
    this.gradient,
    this.useMediumShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Gradient? gradient;
  final bool useMediumShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? (color ?? Theme.of(context).colorScheme.surface)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: AppColors.border),
        boxShadow: useMediumShadow ? AppShadows.medium : AppShadows.soft,
      ),
      child: child,
    );
  }
}
