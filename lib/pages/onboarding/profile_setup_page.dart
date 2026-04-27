import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/routes.dart';
import '../../models/imc_result.dart';
import '../../models/user_profile.dart';
import '../../providers/profile_provider.dart';
import '../../providers/weight_provider.dart';
import '../../theme/app_spacing.dart';
import '../../utils/imc_calculator.dart';
import '../../widgets/app_toast.dart';
import '../../widgets/soft_button.dart';
import '../../widgets/soft_card.dart';
import '../../widgets/soft_text_field.dart';

class ProfileSetupPage extends ConsumerStatefulWidget {
  const ProfileSetupPage({super.key});

  @override
  ConsumerState<ProfileSetupPage> createState() => _ProfileSetupPageState();
}

class _ProfileSetupPageState extends ConsumerState<ProfileSetupPage> {
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _goalController = TextEditingController();

  BiologicalSex _sex = BiologicalSex.male;
  GoalStrategy _goalStrategy = GoalStrategy.suggestedByImc;
  DateTime? _birthDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  double? get _heightCm => _parseDouble(_heightController.text);
  double? get _initialWeight => _parseDouble(_weightController.text);

  int? get _age {
    final birthDate = _birthDate;
    if (birthDate == null) {
      return null;
    }

    final now = DateTime.now();
    var years = now.year - birthDate.year;
    final birthdayPassed = now.month > birthDate.month || (now.month == birthDate.month && now.day >= birthDate.day);
    if (!birthdayPassed) {
      years -= 1;
    }
    return years;
  }

  double? get _suggestedGoal {
    final result = _imcResult;
    if (result == null) {
      return null;
    }
    return ((result.idealWeightMin + result.idealWeightMax) / 2);
  }

  ImcResult? get _imcResult {
    final weight = _initialWeight;
    final height = _heightCm;
    final age = _age;
    if (weight == null || height == null || age == null) {
      return null;
    }

    return ImcCalculator.calculate(
      weightKg: weight,
      heightCm: height,
      sex: _sex,
      age: age,
    );
  }

  double? _parseDouble(String raw) {
    final normalized = raw.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  Future<void> _selectBirthDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30, now.month, now.day),
      firstDate: DateTime(1920),
      lastDate: DateTime(now.year - 10, now.month, now.day),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _birthDate = selected;
    });
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final height = _heightCm;
    final initialWeight = _initialWeight;
    final birthDate = _birthDate;
    final suggestedGoal = _suggestedGoal;
    final customGoal = _parseDouble(_goalController.text);

    if (name.isEmpty) {
      AppToast.show(context, 'Informe seu nome para continuar.');
      return;
    }
    if (height == null || height < 100 || height > 250) {
      AppToast.show(context, 'Informe uma altura valida em centimetros.');
      return;
    }
    if (initialWeight == null || initialWeight < 20 || initialWeight > 300) {
      AppToast.show(context, 'Informe um peso atual valido em kg.');
      return;
    }
    if (birthDate == null) {
      AppToast.show(context, 'Escolha sua data de nascimento.');
      return;
    }
    if (_goalStrategy == GoalStrategy.suggestedByImc && suggestedGoal == null) {
      AppToast.show(context, 'Preencha seus dados para gerar a meta sugerida.');
      return;
    }
    if (_goalStrategy == GoalStrategy.custom && (customGoal == null || customGoal < 20 || customGoal > 300)) {
      AppToast.show(context, 'Informe uma meta personalizada valida.');
      return;
    }

    final goalWeight = _goalStrategy == GoalStrategy.suggestedByImc ? suggestedGoal! : customGoal!;

    setState(() {
      _isSaving = true;
    });

    final profile = UserProfile(
      name: name,
      initialWeight: initialWeight,
      heightCm: height,
      sex: _sex,
      birthDate: birthDate,
      goalWeight: goalWeight,
      goalStrategy: _goalStrategy,
    );

    await ref.read(profileProvider.notifier).saveProfile(profile);
    ref.read(weightProvider.notifier).resetWithInitialWeight(initialWeight);

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.shell,
      (route) => false,
    );
  }

  String _birthDateLabel() {
    final birthDate = _birthDate;
    if (birthDate == null) {
      return 'Selecionar data de nascimento';
    }
    return '${birthDate.day.toString().padLeft(2, '0')}/${birthDate.month.toString().padLeft(2, '0')}/${birthDate.year}';
  }

  @override
  Widget build(BuildContext context) {
    final imcResult = _imcResult;
    final suggestedGoal = _suggestedGoal;

    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro inicial')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Seus dados', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.x4),
                SoftTextField(
                  controller: _nameController,
                  label: 'Nome',
                  hintText: 'Como voce quer ser chamado',
                ),
                const SizedBox(height: AppSpacing.x4),
                SoftTextField(
                  controller: _heightController,
                  label: 'Altura (cm)',
                  hintText: 'Ex.: 175',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.x4),
                SoftTextField(
                  controller: _weightController,
                  label: 'Peso atual (kg)',
                  hintText: 'Ex.: 82.5',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: AppSpacing.x4),
                Text('Sexo biologico', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.x2),
                SegmentedButton<BiologicalSex>(
                  segments: const [
                    ButtonSegment(
                      value: BiologicalSex.male,
                      label: Text('Masculino'),
                    ),
                    ButtonSegment(
                      value: BiologicalSex.female,
                      label: Text('Feminino'),
                    ),
                  ],
                  selected: {_sex},
                  onSelectionChanged: (values) {
                    setState(() {
                      _sex = values.first;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.x4),
                Text('Data de nascimento', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.x2),
                SoftButton.secondary(
                  label: _birthDateLabel(),
                  icon: Icons.calendar_month_rounded,
                  expand: true,
                  onPressed: _selectBirthDate,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Meta sugerida', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  'Depois de informar seus dados, calculamos seu IMC atual e sugerimos uma meta inicial mais coerente.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppSpacing.x4),
                if (imcResult == null)
                  Text(
                    'Preencha altura, peso atual e data de nascimento para gerar a sugestao.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  )
                else ...[
                  Text('IMC atual: ${imcResult.value.toStringAsFixed(1)}', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: AppSpacing.x1),
                  Text(imcResult.classification),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'Faixa de peso estimada: ${imcResult.idealWeightMin.toStringAsFixed(1)} a ${imcResult.idealWeightMax.toStringAsFixed(1)} kg',
                  ),
                  const SizedBox(height: AppSpacing.x2),
                  Text(
                    'Sugestao inicial de meta: ${suggestedGoal!.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
                const SizedBox(height: AppSpacing.x4),
                Text('Como voce quer definir a meta?', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.x2),
                SegmentedButton<GoalStrategy>(
                  segments: const [
                    ButtonSegment(
                      value: GoalStrategy.suggestedByImc,
                      label: Text('Meta IMC'),
                    ),
                    ButtonSegment(
                      value: GoalStrategy.custom,
                      label: Text('Meta propria'),
                    ),
                  ],
                  selected: {_goalStrategy},
                  onSelectionChanged: (values) {
                    setState(() {
                      _goalStrategy = values.first;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.x2),
                Text(
                  _goalStrategy == GoalStrategy.suggestedByImc
                      ? 'Usa a referencia calculada pelo IMC para criar uma meta inicial.'
                      : 'Permite informar manualmente o peso que voce deseja atingir.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (_goalStrategy == GoalStrategy.custom) ...[
                  const SizedBox(height: AppSpacing.x2),
                  SoftTextField(
                    controller: _goalController,
                    label: 'Meta personalizada (kg)',
                    hintText: 'Ex.: 75.0',
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.x5),
          SoftButton.primary(
            label: _isSaving ? 'Salvando...' : 'Salvar e entrar',
            icon: Icons.check_rounded,
            expand: true,
            onPressed: _isSaving ? null : _saveProfile,
          ),
        ],
      ),
    );
  }
}
