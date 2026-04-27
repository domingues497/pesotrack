import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import 'scan_animation.dart';

class UploadZone extends StatelessWidget {
  const UploadZone({
    super.key,
    required this.controller,
    required this.detectedWeight,
    required this.statusText,
    required this.isProcessing,
  });

  final CameraController controller;
  final double? detectedWeight;
  final String statusText;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller),
            Container(color: Colors.black.withValues(alpha: 0.12)),
            Positioned.fill(
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.72,
                  height: 200,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.accent.withValues(alpha: 0.55), width: 2),
                    borderRadius: BorderRadius.circular(AppRadii.large),
                    color: AppColors.transparent,
                  ),
                ),
              ),
            ),
            const Positioned.fill(child: IgnorePointer(child: ScanAnimation())),
            Positioned(
              left: AppSpacing.x4,
              right: AppSpacing.x4,
              bottom: AppSpacing.x4,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.textPrimary.withValues(alpha: 0.70),
                  borderRadius: BorderRadius.circular(AppRadii.large),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.x4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detectedWeight == null
                            ? 'Aponte para o visor da balanca'
                            : 'Leitura detectada: ${detectedWeight!.toStringAsFixed(1)} kg',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.white,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.x2),
                      Row(
                        children: [
                          if (isProcessing)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                              ),
                            ),
                          if (isProcessing) const SizedBox(width: AppSpacing.x2),
                          Expanded(
                            child: Text(
                              statusText,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.white,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
