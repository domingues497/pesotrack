import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/weight_entry.dart';
import '../add_weight/widgets/manual_weight_form.dart';
import '../../providers/weight_provider.dart';
import '../../utils/extensions.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/soft_card.dart';

class HistoryPage extends ConsumerWidget {
  const HistoryPage({super.key});

  Future<void> _openEditSheet(BuildContext context, WeightEntry entry) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: ManualWeightForm(
              entry: entry,
              onSaved: () => Navigator.of(context).pop(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, WeightEntry entry) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Excluir registro'),
          content: Text(
            'Deseja excluir o registro de ${entry.weight.asKg} em ${entry.recordedAt.asShortDateTime}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true || !context.mounted) {
      return;
    }

    ref.read(weightProvider.notifier).deleteEntry(entry.id);
    AppToast.show(context, 'Registro excluído com sucesso.');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(weightProvider).reversed.toList();

    if (entries.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: const [
          EmptyState(
            title: 'Nenhum registro ainda',
            message: 'Seus registros de peso vão aparecer aqui.',
          ),
        ],
      );
    }

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
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.weight.asKg,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _openEditSheet(context, entry),
                    icon: const Icon(Icons.edit_rounded),
                    tooltip: 'Editar registro',
                  ),
                  IconButton(
                    onPressed: () => _confirmDelete(context, ref, entry),
                    icon: const Icon(Icons.delete_outline_rounded),
                    tooltip: 'Excluir registro',
                  ),
                ],
              ),
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
