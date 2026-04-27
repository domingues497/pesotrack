import 'package:flutter/material.dart';

import '../../widgets/soft_card.dart';

class OcrPage extends StatelessWidget {
  const OcrPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: const [
        SoftCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('OCR via camera'),
              SizedBox(height: 12),
              Text('Estrutura inicial reservada para image_picker, ML Kit e confirmacao do peso.'),
            ],
          ),
        ),
      ],
    );
  }
}
