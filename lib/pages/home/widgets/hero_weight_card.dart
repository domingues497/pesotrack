import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/soft_button.dart';
import '../../../widgets/soft_card.dart';

class HeroWeightCard extends StatelessWidget {
  const HeroWeightCard({
    super.key,
    required this.currentWeight,
    required this.lastRecordedAt,
    required this.startWeight,
    required this.goalWeight,
    required this.progress,
    this.onScanPressed,
    this.onRegisterPressed,
  });

  final double currentWeight;
  final DateTime lastRecordedAt;
  final double startWeight;
  final double goalWeight;
  final double progress;
  final VoidCallback? onScanPressed;
  final VoidCallback? onRegisterPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SoftCard(
      radius: AppRadii.xLarge,
      gradient: AppGradients.hero,
      useMediumShadow: true,
      child: Stack(
        children: [
          Positioned(
            right: -18,
            top: -18,
            child: Container(
              width: 140,
              height: 140,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Color(0x2EE76F51),
                    Color(0x00E76F51),
                  ],
                ),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.x3,
                  vertical: AppSpacing.x2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.72),
                  border: Border.all(color: AppColors.white.withValues(alpha: 0.80)),
                  borderRadius: BorderRadius.circular(AppRadii.full),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.accentDeep),
                    const SizedBox(width: AppSpacing.x2),
                    Text(
                      'foco no progresso real',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.accentDeep,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.x3),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Peso atual'.toUpperCase(),
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.x1),
                        RichText(
                          text: TextSpan(
                            style: textTheme.displayMedium?.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            children: [
                              TextSpan(text: currentWeight.toStringAsFixed(1)),
                              TextSpan(
                                text: ' kg',
                                style: textTheme.titleLarge?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'ultimo registro',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                      const SizedBox(height: AppSpacing.x1),
                      Text(
                        lastRecordedAt.asShortDateTime,
                        style: textTheme.bodySmall,
                      ),
                      Text(
                        'meta ${goalWeight.toStringAsFixed(1)} kg',
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'inicio ${startWeight.toStringAsFixed(1)} kg',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    'meta ${goalWeight.toStringAsFixed(1)} kg',
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.x2),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadii.full),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.progressTrack,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                ),
              ),
              const SizedBox(height: AppSpacing.x4),
              Row(
                children: [
                  Expanded(
                    child: SoftButton.primary(
                      label: 'Escanear',
                      icon: Icons.camera_alt_rounded,
                      expand: true,
                      onPressed: onScanPressed,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x3),
                  Expanded(
                    child: SoftButton.secondary(
                      label: 'Registrar',
                      icon: Icons.add_rounded,
                      expand: true,
                      onPressed: onRegisterPressed,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
