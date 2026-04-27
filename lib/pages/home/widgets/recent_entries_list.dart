import 'package:flutter/material.dart';

import '../../../models/weight_entry.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_gradients.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/delta_badge.dart';
import '../../../widgets/section_header.dart';
import '../../../widgets/soft_card.dart';

class RecentEntriesList extends StatelessWidget {
  const RecentEntriesList({
    super.key,
    required this.entries,
    required this.previousEntries,
    required this.trendText,
    this.onOpenHistory,
  });

  final List<WeightEntry> entries;
  final List<WeightEntry> previousEntries;
  final String trendText;
  final VoidCallback? onOpenHistory;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SoftCard(
          gradient: AppGradients.softWarm,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(title: 'Resumo'),
              const SizedBox(height: AppSpacing.x3),
              Text(
                'Tendencia',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                trendText,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: AppSpacing.x2),
              Text(
                'Seu ritmo recente esta consistente e o historico mostra a direcao mais importante do momento.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textMuted,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.x4),
        SectionHeader(
          title: 'Ultimos registros',
          actionLabel: 'ver tudo',
          onAction: onOpenHistory,
        ),
        const SizedBox(height: AppSpacing.x3),
        ...entries.map((entry) {
          final delta = _deltaFor(entry);
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.x3),
            child: SoftCard(
              radius: 20,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.x4,
                vertical: 15,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.weight.asKg,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.x1),
                        Text(
                          '${entry.recordedAt.asShortDateTime}  .  ${entry.typeLabel}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                        ),
                        if (entry.note.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.x1),
                          Text(
                            entry.note,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.x2),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      _EntryBadge(type: entry.type),
                      const SizedBox(height: AppSpacing.x2),
                      if (delta != null) DeltaBadge(delta: delta),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  double? _deltaFor(WeightEntry current) {
    final index = previousEntries.indexWhere((entry) => entry.id == current.id);
    if (index <= 0) {
      return null;
    }
    return current.weight - previousEntries[index - 1].weight;
  }
}

class _EntryBadge extends StatelessWidget {
  const _EntryBadge({required this.type});

  final WeightEntryType type;

  @override
  Widget build(BuildContext context) {
    final isOcr = type == WeightEntryType.ocr;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.x2,
        vertical: AppSpacing.x1,
      ),
      decoration: BoxDecoration(
        color: isOcr ? AppColors.surfaceAlt : AppColors.surfaceWarm,
        borderRadius: BorderRadius.circular(AppRadii.full),
      ),
      child: Text(
        isOcr ? 'OCR' : 'Manual',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isOcr ? AppColors.accentDeep : AppColors.textMuted,
            ),
      ),
    );
  }
}
