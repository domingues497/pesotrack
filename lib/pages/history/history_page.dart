import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/weight_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/soft_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(weightProvider).reversed.toList();

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      itemCount: entries.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final entry = entries[index];
        return SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(entry.weight.asKg, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 6),
              Text('${entry.recordedAt.asShortDateTime} · ${entry.typeLabel}'),
              if (entry.note.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(entry.note),
              ],
            ],
          ),
        );
      },
    );
  }
}
