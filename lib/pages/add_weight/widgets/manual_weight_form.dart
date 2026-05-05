import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/weight_entry.dart';
import '../../../providers/weight_provider.dart';
import '../../../theme/app_spacing.dart';
import '../../../utils/extensions.dart';
import '../../../widgets/app_toast.dart';
import '../../../widgets/soft_button.dart';
import '../../../widgets/soft_card.dart';
import '../../../widgets/soft_text_field.dart';

class ManualWeightForm extends ConsumerStatefulWidget {
  const ManualWeightForm({
    super.key,
    this.entry,
    this.onSaved,
  });

  final WeightEntry? entry;
  final VoidCallback? onSaved;

  @override
  ConsumerState<ManualWeightForm> createState() => _ManualWeightFormState();
}

class _ManualWeightFormState extends ConsumerState<ManualWeightForm> {
  late final TextEditingController _weightController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  late final TextEditingController _noteController;
  late DateTime _selectedAt;
  bool _isSaving = false;

  bool get _isEditing => widget.entry != null;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    _selectedAt = entry?.recordedAt ?? DateTime.now();
    _weightController = TextEditingController(
      text: entry?.weight.toStringAsFixed(1) ?? '',
    );
    _dateController = TextEditingController();
    _timeController = TextEditingController();
    _noteController = TextEditingController(text: entry?.note ?? '');
    _syncDateTimeLabels();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _syncDateTimeLabels() {
    _dateController.text = _selectedAt.asFullDate;
    _timeController.text = _selectedAt.asTime;
  }

  double? _parseWeight() {
    final normalized = _weightController.text.trim().replaceAll(',', '.');
    if (normalized.isEmpty) {
      return null;
    }
    return double.tryParse(normalized);
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      locale: const Locale('pt', 'BR'),
      initialDate: _selectedAt,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedAt = DateTime(
        selected.year,
        selected.month,
        selected.day,
        _selectedAt.hour,
        _selectedAt.minute,
      );
      _syncDateTimeLabels();
    });
  }

  Future<void> _pickTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedAt),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (selected == null) {
      return;
    }

    setState(() {
      _selectedAt = DateTime(
        _selectedAt.year,
        _selectedAt.month,
        _selectedAt.day,
        selected.hour,
        selected.minute,
      );
      _syncDateTimeLabels();
    });
  }

  Future<void> _submit() async {
    final weight = _parseWeight();
    if (weight == null || weight < 20 || weight > 300) {
      AppToast.show(context, 'Informe um peso válido entre 20 e 300 kg.');
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final entry = widget.entry;
    if (entry == null) {
      ref.read(weightProvider.notifier).saveEntry(
            weight: weight,
            recordedAt: _selectedAt,
            note: _noteController.text.trim(),
            type: WeightEntryType.manual,
          );
    } else {
      ref.read(weightProvider.notifier).updateEntry(
            id: entry.id,
            weight: weight,
            recordedAt: _selectedAt,
            note: _noteController.text.trim(),
            type: entry.type,
          );
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSaving = false;
    });

    AppToast.show(
      context,
      _isEditing ? 'Peso atualizado com sucesso.' : 'Peso salvo com sucesso.',
    );

    if (_isEditing) {
      widget.onSaved?.call();
      return;
    }

    _weightController.clear();
    _noteController.clear();
    _selectedAt = DateTime.now();
    _syncDateTimeLabels();
    widget.onSaved?.call();
  }

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isEditing ? 'Editar registro' : 'Registro manual',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            _isEditing
                ? 'Ajuste o peso, a data, o horário e a observação deste registro.'
                : 'Informe o peso e confirme a data e o horário do registro.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftTextField(
            controller: _weightController,
            label: 'Peso (kg)',
            hintText: 'Ex.: 79,3',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftTextField(
            controller: _dateController,
            label: 'Data',
            hintText: 'Selecione a data',
            readOnly: true,
            onTap: _pickDate,
            suffixIcon: const Icon(Icons.calendar_month_rounded),
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftTextField(
            controller: _timeController,
            label: 'Hora',
            hintText: 'Selecione a hora',
            readOnly: true,
            onTap: _pickTime,
            suffixIcon: const Icon(Icons.access_time_rounded),
            helperText: 'A hora atual é preenchida automaticamente, mas pode ser alterada.',
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftTextField(
            controller: _noteController,
            label: 'Observação',
            hintText: 'Como você está hoje?',
            maxLines: 4,
          ),
          const SizedBox(height: AppSpacing.x5),
          SoftButton.primary(
            label: _isSaving
                ? (_isEditing ? 'Salvando alterações...' : 'Salvando...')
                : (_isEditing ? 'Salvar alterações' : 'Salvar registro'),
            icon: Icons.save_rounded,
            expand: true,
            onPressed: _isSaving ? null : _submit,
          ),
        ],
      ),
    );
  }
}
