import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../theme/app_gradients.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/soft_button.dart';
import '../../widgets/soft_card.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            SoftCard(
              gradient: AppGradients.hero,
              useMediumShadow: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bem-vindo ao PesoTrack',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppSpacing.x3),
                  Text(
                    'Vamos configurar seu acompanhamento para calcular uma meta inteligente e registrar seu peso com a camera da balanca.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x4),
            const SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _OnboardingBullet(
                    icon: Icons.person_rounded,
                    title: 'Seu perfil basico',
                    description: 'Nome, altura, sexo e data de nascimento para calcular IMC e contexto.',
                  ),
                  SizedBox(height: AppSpacing.x4),
                  _OnboardingBullet(
                    icon: Icons.monitor_weight_rounded,
                    title: 'Seu peso atual',
                    description: 'Use o peso atual para sugerir uma meta coerente com a sua situacao de hoje.',
                  ),
                  SizedBox(height: AppSpacing.x4),
                  _OnboardingBullet(
                    icon: Icons.flag_rounded,
                    title: 'Sua escolha de meta',
                    description: 'Voce decide entre usar a meta sugerida pelo IMC ou informar uma meta propria.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.x5),
            SoftButton.primary(
              label: 'Comecar cadastro',
              icon: Icons.arrow_forward_rounded,
              expand: true,
              onPressed: () => Navigator.of(context).pushNamed(AppRoutes.profileSetup),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingBullet extends StatelessWidget {
  const _OnboardingBullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22),
        const SizedBox(width: AppSpacing.x3),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.x1),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }
}
