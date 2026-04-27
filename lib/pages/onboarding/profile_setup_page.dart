import 'package:flutter/material.dart';

import '../../widgets/soft_card.dart';
import '../../widgets/soft_text_field.dart';

class ProfileSetupPage extends StatelessWidget {
  const ProfileSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro inicial')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SoftTextField(label: 'Nome', hintText: 'Seu nome'),
                SizedBox(height: 12),
                SoftTextField(label: 'Peso inicial', hintText: '82.5'),
                SizedBox(height: 12),
                SoftTextField(label: 'Altura (cm)', hintText: '175'),
                SizedBox(height: 12),
                SoftTextField(label: 'Meta de peso', hintText: '75.0'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
