import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/imc_result.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/weight_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/extensions.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/soft_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/soft_text_field.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  Future<void> _confirmEndGoal(
    BuildContext context,
    WidgetRef ref,
    GoalStatus status,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final isCompleted = status == GoalStatus.completed;
        return AlertDialog(
          title: Text(isCompleted ? 'Concluir meta' : 'Cancelar meta'),
          content: Text(
            isCompleted
                ? 'Deseja marcar a meta ativa como concluída?'
                : 'Deseja cancelar a meta ativa atual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(isCompleted ? 'Concluir' : 'Cancelar meta'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    await ref.read(profileProvider.notifier).endActiveGoal(status);
    if (!context.mounted) {
      return;
    }
    AppToast.show(
      context,
      status == GoalStatus.completed ? 'Meta concluída com sucesso.' : 'Meta cancelada com sucesso.',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider).profile;
    final entries = ref.watch(weightProvider);
    if (profile == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final currentWeight = entries.isEmpty ? profile.initialWeight : entries.last.weight;
    final activeGoal = profile.activeGoal;
    final missingToGoal = activeGoal == null ? null : (currentWeight - activeGoal.targetWeight).abs();

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(profile.name, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                Text('Altura: ${profile.heightCm.toStringAsFixed(0)} cm'),
                Text('Peso inicial: ${profile.initialWeight.toStringAsFixed(1)} kg'),
                Text('Peso atual: ${currentWeight.toStringAsFixed(1)} kg'),
                Text('Sexo: ${profile.sexLabel}'),
                Text('Idade: ${profile.age} anos'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta ativa', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.x3),
                if (activeGoal == null)
                  Text(
                    'Você não tem uma meta ativa no momento. Crie uma nova meta para retomar o acompanhamento.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  Text('Objetivo: ${activeGoal.targetWeight.toStringAsFixed(1)} kg'),
                  Text('Início da meta: ${activeGoal.startDate.asFullDate}'),
                  Text('Data-alvo: ${activeGoal.targetDate.asFullDate}'),
                  Text('Peso de partida: ${activeGoal.startWeight.toStringAsFixed(1)} kg'),
                  Text('Tipo: ${activeGoal.strategyLabel}'),
                  Text('Distância atual até a meta: ${missingToGoal!.toStringAsFixed(1)} kg'),
                ],
                const SizedBox(height: AppSpacing.x4),
                SoftButton.primary(
                  label: 'Criar nova meta',
                  icon: Icons.flag_rounded,
                  expand: true,
                  onPressed: () {
                    showModalBottomSheet<void>(
                      context: context,
                      isScrollControlled: true,
                      builder: (sheetContext) {
                        return Padding(
                          padding: EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                          ),
                          child: _NewGoalSheet(
                            currentWeight: currentWeight,
                          ),
                        );
                      },
                    );
                  },
                ),
                if (activeGoal != null) ...[
                  const SizedBox(height: AppSpacing.x3),
                  Row(
                    children: [
                      Expanded(
                        child: SoftButton.secondary(
                          label: 'Concluir meta',
                          icon: Icons.check_circle_outline_rounded,
                          expand: true,
                          onPressed: () => _confirmEndGoal(context, ref, GoalStatus.completed),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.x3),
                      Expanded(
                        child: SoftButton.secondary(
                          label: 'Cancelar meta',
                          icon: Icons.cancel_outlined,
                          expand: true,
                          onPressed: () => _confirmEndGoal(context, ref, GoalStatus.cancelled),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (profile.goalHistory.isNotEmpty) ...[
            const SizedBox(height: 16),
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Histórico de metas', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: AppSpacing.x3),
                  ...profile.goalHistory.map((goal) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.x3),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${goal.targetWeight.toStringAsFixed(1)} kg',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: AppSpacing.x1),
                          Text('Período: ${goal.startDate.asFullDate} até ${goal.targetDate.asFullDate}'),
                          Text('Partida: ${goal.startWeight.toStringAsFixed(1)} kg'),
                          Text('Tipo: ${goal.strategyLabel}'),
                          Text('Status: ${goal.statusLabel}'),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            child: const Text('Alternar tema'),
          ),
        ],
      ),
    );
  }
}

class _NewGoalSheet extends ConsumerStatefulWidget {
  const _NewGoalSheet({
    required this.currentWeight,
  });

  final double currentWeight;

  @override
  ConsumerState<_NewGoalSheet> createState() => _NewGoalSheetState();
}

class _NewGoalSheetState extends ConsumerState<_NewGoalSheet> {
  final _goalController = TextEditingController();
  GoalStrategy _goalStrategy = GoalStrategy.custom;
  late DateTime _targetDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _targetDate = DateTime.now().add(const Duration(days: 90));
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  double? get _customGoal {
    final normalized = _goalController.text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  ImcResult? get _imcResult {
    final profile = ref.read(profileProvider).profile;
    if (profile == null) {
      return null;
    }

    return ImcCalculator.calculate(
      weightKg: widget.currentWeight,
      heightCm: profile.heightCm,
      sex: profile.sex,
      age: profile.age,
    );
  }

  double? get _suggestedGoal {
    final result = _imcResult;
    if (result == null) {
      return null;
    }
    return (result.idealWeightMin + result.idealWeightMax) / 2;
  }

  Future<void> _selectTargetDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _targetDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _targetDate = selected;
    });
  }

  Future<void> _saveGoal() async {
    final targetWeight = _goalStrategy == GoalStrategy.suggestedByImc ? _suggestedGoal : _customGoal;
    if (targetWeight == null || targetWeight < 20 || targetWeight > 300) {
      AppToast.show(context, 'Informe uma meta válida entre 20 e 300 kg.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    await ref.read(profileProvider.notifier).startNewGoal(
          startWeight: widget.currentWeight,
          targetWeight: targetWeight,
          startDate: DateTime.now(),
          targetDate: _targetDate,
          strategy: _goalStrategy,
        );

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });
    AppToast.show(context, 'Nova meta criada com sucesso.');
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final suggestedGoal = _suggestedGoal;

    return SingleChildScrollView(
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nova meta', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.x2),
            Text(
              'A nova meta entra como ativa e a anterior vai para o histórico.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpacing.x4),
            Text('Como definir a meta?', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.x2),
            SegmentedButton<GoalStrategy>(
              segments: const [
                ButtonSegment(
                  value: GoalStrategy.suggestedByImc,
                  label: Text('Meta IMC'),
                ),
                ButtonSegment(
                  value: GoalStrategy.custom,
                  label: Text('Meta própria'),
                ),
              ],
              selected: {_goalStrategy},
              onSelectionChanged: (values) {
                setState(() {
                  _goalStrategy = values.first;
                });
              },
            ),
            const SizedBox(height: AppSpacing.x3),
            if (_goalStrategy == GoalStrategy.suggestedByImc)
              Text(
                suggestedGoal == null
                    ? 'Não foi possível calcular a meta sugerida neste momento.'
                    : 'Sugestão atual pelo IMC: ${suggestedGoal.toStringAsFixed(1)} kg',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              SoftTextField(
                controller: _goalController,
                label: 'Meta personalizada (kg)',
                hintText: 'Ex.: 75.0',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
            const SizedBox(height: AppSpacing.x4),
            Text('Data-alvo', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.x2),
            SoftButton.secondary(
              label: _targetDate.asFullDate,
              icon: Icons.event_rounded,
              expand: true,
              onPressed: _selectTargetDate,
            ),
            const SizedBox(height: AppSpacing.x4),
            SoftButton.primary(
              label: _isSaving ? 'Salvando...' : 'Salvar nova meta',
              icon: Icons.check_rounded,
              expand: true,
              onPressed: _isSaving ? null : _saveGoal,
            ),
          ],
        ),
      ),
    );
  }
}
