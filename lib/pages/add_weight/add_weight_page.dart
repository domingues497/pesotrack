import 'package:flutter/material.dart';

import '../../widgets/soft_card.dart';
import '../../widgets/soft_text_field.dart';

class AddWeightPage extends StatelessWidget {
  const AddWeightPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Registro manual'),
              SizedBox(height: 12),
              SoftTextField(label: 'Peso (kg)', hintText: '79.3'),
              SizedBox(height: 12),
              SoftTextField(label: 'Data', hintText: '27/04/2026'),
              SizedBox(height: 12),
              SoftTextField(label: 'Horario', hintText: '07:00'),
              SizedBox(height: 12),
              SoftTextField(label: 'Nota', hintText: 'Como voce esta hoje?', maxLines: 4),
            ],
          ),
        ),
      ],
    );
  }
}
