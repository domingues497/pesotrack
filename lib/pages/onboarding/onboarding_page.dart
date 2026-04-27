import 'package:flutter/material.dart';

import '../../widgets/soft_card.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bem-vindo ao PesoTrack', style: Theme.of(context).textTheme.displaySmall),
                const SizedBox(height: 12),
                const Text('Tela inicial prevista para a primeira abertura do app.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
