import 'package:flutter/material.dart';

import '../../../theme/app_spacing.dart';
import '../../../widgets/soft_button.dart';
import '../../../widgets/soft_text_field.dart';

class OcrConfirmSheet extends StatefulWidget {
  const OcrConfirmSheet({
    super.key,
    required this.initialWeight,
    required this.onConfirm,
  });

  final double initialWeight;
  final ValueChanged<double> onConfirm;

  @override
  State<OcrConfirmSheet> createState() => _OcrConfirmSheetState();
}

class _OcrConfirmSheetState extends State<OcrConfirmSheet> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialWeight.toStringAsFixed(1),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final parsed = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (parsed == null) {
      return;
    }
    widget.onConfirm(parsed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.x4,
        right: AppSpacing.x4,
        top: AppSpacing.x4,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.x4,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Peso detectado',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppSpacing.x2),
          Text(
            'A leitura ficou estavel. Confirme ou ajuste antes de salvar.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.x4),
          SoftTextField(
            controller: _controller,
            label: 'Peso em kg',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            hintText: 'Ex.: 79.5',
          ),
          const SizedBox(height: AppSpacing.x4),
          Row(
            children: [
              Expanded(
                child: SoftButton.secondary(
                  label: 'Cancelar',
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
              const SizedBox(width: AppSpacing.x3),
              Expanded(
                child: SoftButton.primary(
                  label: 'Salvar',
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
